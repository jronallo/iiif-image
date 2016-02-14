test = require 'tape'
Informer = require('../lib/iiif-image-informer').IIIFImageInformer
pather = require 'path'
path = pather.join __dirname, '/images/trumpler14.jp2'

test 'get height and width from JP2 with Kakadu', (assert) ->
  assert.plan(1)
  expected_info =
    width: 3906
    height: 3906
    levels: 6
    sizes: [{ height: 62, width: 62 }, { height: 123, width: 123 },
      { height: 245, width: 245 }, { height: 489, width: 489 },
      { height: 977, width: 977 }, { height: 1953, width: 1953 },
      { height: 3906, width: 3906 }]
    tiles: [ { scaleFactors: [ 1, 2, 4, 8, 16, 32, 64 ], width: 1024 } ]

  cb = (info) ->
    assert.deepEqual info, expected_info
  informer = new Informer path, cb
  informer.inform()
