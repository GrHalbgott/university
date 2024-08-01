import os
from pathlib import Path
from typing import Optional

import numpy as np
import pandas as pd
import torch
from torch.utils.data import Dataset
from torchvision import transforms

from lulc.data.label import resolve_labels
from lulc.data.tx.tensor import ToTensor
from lulc.ops.imagery_store_operator import ImageryStore
from lulc.ops.osm_operator import OhsomeOps
from lulc.ops.road_network_operator import RoadNetwork


class AreaDataset(Dataset):

    def __init__(self, area_descriptor_ver: str,
                 label_descriptor_ver: str,
                 imagery_store: ImageryStore,
                 data_dir: Path,
                 cache_dir: Path,
                 deterministic_tx: transforms.Compose,
                 random_tx: Optional[transforms.Compose] = None
                 ):
        self.osm = OhsomeOps(cache_dir=cache_dir / 'osm' / label_descriptor_ver)
        self.imagery_store = imagery_store
        self.road_network = RoadNetwork(cache_dir=cache_dir / 'road_network' / label_descriptor_ver)

        self.area_descriptor = pd.read_csv(str(data_dir / 'area' / f'area_{area_descriptor_ver}.csv'))

        label_descriptors = resolve_labels(data_dir, label_descriptor_ver)
        self.labels = [d.name for d in label_descriptors]
        self.osm_lulc_mapping = dict([(d.name, d.osm_filter) for d in label_descriptors if d.osm_filter is not None])
        self.color_codes = [d.color for d in label_descriptors]

        self.item_cache = cache_dir / 'items' / area_descriptor_ver / label_descriptor_ver
        self.deterministic_tx = deterministic_tx
        self.random_tx = random_tx

    def __len__(self):
        return len(self.area_descriptor)

    def __getitem__(self, idx):
        item_path = self.item_cache / str(idx)
        x_path = f'{item_path}/x.pt'
        y_path = f'{item_path}/y.pt'

        if not item_path.exists() or len(os.listdir(item_path)) == 0:
            area = self.area_descriptor.iloc[idx]
            area_coords = tuple(area[['min_x', 'min_y', 'max_x', 'max_y']].values)
            imagery, imagery_size = self.imagery_store.imagery(area_coords, area['start_date'], area['end_date'])
            labels, bbox_id, utm = self.osm.labels(area_coords, area['end_date'], self.osm_lulc_mapping, imagery_size)

            # Load road network
            road_network = self.road_network.load_road_network(area_coords, area['end_date'], utm, imagery_size, bbox_id)

            # Extension 1: boolean rasterization of road network
            # rasterized_road_network = self.road_network.boolean_road_network(road_network)

            # Extension 2: rasterized road network with one-hot encoded road types
            # rasterized_road_network = self.road_network.encode_rasterize_category(road_network, self.road_network.road_types_optimized, 'highway')

            # Extension 3: rasterized road network with one-hot encoded speed limits
            # rasterized_road_network = self.road_network.encode_rasterize_category(road_network, self.road_network.speed_limit_classes['class_labels'], 'speed_limit_class')

            # Extension 4: rasterized road network with stacked one-hot encoded road types and speed limits
            rasterized_road_network_types = self.road_network.encode_rasterize_category(road_network, self.road_network.road_types_optimized, 'highway')
            rasterized_road_network_speeds = self.road_network.encode_rasterize_category(road_network, self.road_network.speed_limit_classes['class_labels'], 'speed_limit_class')
            rasterized_road_network = np.dstack((rasterized_road_network_types, rasterized_road_network_speeds))

            # Add road type channels to imagery dictionary
            input_data = {**imagery, 'road_network': rasterized_road_network}

            item = self.deterministic_tx({
                'x': input_data, # input_data | imagery
                'y': labels,
            })

            item_path.mkdir(parents=True, exist_ok=True)
            torch.save(item['x'], x_path)
            torch.save(item['y'], y_path)
        else:
            item = {
                'x': torch.load(x_path),
                'y': torch.load(y_path),
            }

        item = item if self.random_tx is None else self.random_tx(item)
        return ToTensor()(item)
