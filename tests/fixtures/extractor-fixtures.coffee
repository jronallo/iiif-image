pather = require 'path'
path = pather.join __dirname, '/../images/trumpler14.jp2'

fixtures = ->
  params =
    identifier: 'trumpler14'
    region: 'full'
    size:
      w: 200
      h: undefined
    rotation:
      degrees: 0
      mirror: false
    quality: 'default'
    format: 'jpg'

  region_xywh =
    x: 0
    y: 0
    w: 300
    h: 300

  region_pct =
    pctx: 3.0
    pcty: 3.0
    pctw: 3.201
    pcth: 3.201

  info =
    width: 3906
    height: 3906
    levels: 6
    sizes: [
      { height: 62, width: 62 }, { height: 123, width: 123 },
      { height: 245, width: 245 }, { height: 489, width: 489 },
      { height: 977, width: 977 }, { height: 1953, width: 1953 },
      { height: 3906, width: 3906 }]
    tiles: [ { scaleFactors: [ 1, 2, 4, 8, 16, 32, 64 ], width: 1024 }]

  # This is what actually gets exported
  params: params
  info: info
  region_xywh: region_xywh
  region_pct: region_pct
  options:
    path: path
    params: params
    info: info

exports.fixtures = fixtures
