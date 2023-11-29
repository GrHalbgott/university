#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Calculate Betweenness Centrality"""

import sys
import logging.config
from pathlib import Path
from alive_progress import alive_bar

import network_analysis.utils as utils
import network_analysis.file_manager as fm
import network_analysis.graph as g
import network_analysis.centrality as cc


utils.init_logger("./src/assets/logging_config.json")
sys.tracebacklimit = 0


if __name__ == "__main__":  # noqa: C901
    """Main function to calculate betweenness centrality"""

    # Initialize progress bar
    with alive_bar(10, stats=False, bar="smooth", spinner="classic") as bar:
        logging.info("Preparing program...")
        # Check system arguments
        (
            n_routes,
            aoi,
            skip_aoi,
            use_pop,
            method,
            route_type,
            sys_outdir,
        ) = utils._check_system_arguments()
        # Assign paths
        datadir = Path("data")
        outdir = Path(sys_outdir)
        outname = fm.outname_creator(aoi, method, route_type, n_routes, use_pop)
        outfolder = fm.subfolder_creator(outdir, outname)
        # Show parameters
        logging.info(
            f"Used parameters: -aoi {aoi}, -skip {skip_aoi}, -pop {use_pop}, -n {n_routes}, -m {method}, -rt {route_type}, -out {sys_outdir}"
        )
        bar()

        # Directory management and file checking
        logging.info("Directory management and file checking...")
        if use_pop:
            pop_file_list = list(datadir.glob("*POP*.tif"))
            if len(pop_file_list) == 0:
                logging.error(
                    f"No population file found in {datadir}. Please provide one or remove the -pop flag."
                )
                sys.exit(1)
        else:
            pop_file_list = None
        try:
            outdir.mkdir(exist_ok=True)
            datadir.mkdir(exist_ok=True)
        except Exception as e:
            logging.exception(f"Error during folder creation: {e}")
            sys.exit(1)
        bar()

        # Get bounds from aoi
        logging.info("Get bounds from aoi...")
        aoi_path = datadir / aoi
        aoi_poly, aoi_bounds = g.get_bounds(aoi, skip_aoi, aoi_path)
        bar()

        # Query OSMnx for graph
        logging.info("Querying OSMnx for graph...")
        try:
            graph = g.get_graph(aoi_poly)
            logging.info("Saving as figure...")
            fm.save_graph(aoi, outdir, graph)
        except Exception as e:
            logging.error(f"Error when requesting OSMnx: {e}.")
            sys.exit(1)
        bar()

        # Query OSMnx for edges
        logging.info("Querying OSMnx for edges...")
        try:
            edges = g.extract_edges(graph)
        except Exception as e:
            logging.error(f"Error when querying OSMnx for edges: {e}")
            sys.exit(1)
        bar()

        # Preparing centrality calculation
        logging.info("Preparing centrality calculation...")
        if route_type == "shortest":
            weight = "length"
        else:
            weight = "travel_time"
            logging.info("Adding travel times to graph...")
            try:
                graph = g.add_travel_times(graph)
            except Exception as e:
                logging.error(f"Error when adding travel times to graph: {e}")
                sys.exit(1)
        bar()

        # Calculation of betweenness centrality
        centrality_df = cc.centrality_handler(
            datadir,
            n_routes,
            method,
            route_type,
            aoi_poly,
            aoi_bounds,
            graph,
            weight,
            use_pop,
            pop_file_list,
        )
        bar()

        # Join edges to centrality dataframe
        logging.info("Joining edges to centrality dataframe...")
        try:
            centrality_gdf = cc.join_edges(centrality_df, edges)
        except Exception as e:
            logging.error(f"Error when joining edges to centrality dataframe: {e}")
            sys.exit(1)
        bar()

        # Save results
        logging.info("Saving results...")
        try:
            if use_pop:
                fm.save_population_rater(datadir, outdir, aoi)
            fm.write_gdf(centrality_gdf, outfolder, outname)
            fm.save_figure(centrality_gdf, outfolder, outname, n_routes)
        except Exception as e:
            logging.error(f"Error when saving results: {e}")
            sys.exit(1)
        bar()

        # Clean up
        logging.info("Cleaning up...")
        try:
            fm.cleanup_temp(datadir)
        except Exception:
            pass
        bar()

        logging.info("Finished!")
