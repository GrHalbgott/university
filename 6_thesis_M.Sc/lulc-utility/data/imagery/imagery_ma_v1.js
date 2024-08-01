//VERSION=3

function setup() {
    return {
        input: [
            {
                datasource: "s2",
                bands: ["B02", "B03", "B04", "B08"]
            },
            {
                datasource: "dem",
                bands: ["DEM"]
            }
        ],
        output: [{
            id: "s2",
            bands: 4,
            resx: 10,
            resy: 10,
            sampleType: "UINT8"
        }, {
            id: "dem",
            bands: 1,
            resx: 10,
            resy: 10,
            sampleType: "FLOAT32"
        }]
    }
}

function evaluatePixel(samples) {
    let s2_sample = samples.s2[0]
    let dem_sample = samples.dem[0]

    return {
        "s2": [
            s2_sample.B04 * 255,
            s2_sample.B03 * 255,
            s2_sample.B02 * 255,
            s2_sample.B08 * 255,
        ],
        "dem": [
            dem_sample.DEM
        ]
    }
}