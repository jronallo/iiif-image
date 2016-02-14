test = require 'tape'
Extractor = require('../lib/iiif-image-extractor').IIIFImageExtractor
pather = require 'path'
path = pather.join __dirname, '/images/trumpler14.jp2'
fs = require 'fs-extra'

params =
  identifier: 'trumpler14'
  region: 'full'
    # x: 0
    # y: 0
    # h: 1600
    # w: 1600
  size:
    w: 200
    h: undefined
  rotation:
    degrees: 0
    mirror: false
  quality: 'default'
  format: 'jpg'

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

test 'extract image', (assert) ->
  assert.plan(2)

  options =
    path: path
    params: params
    info: info

  callback = (output_image_path) ->
    assert.ok output_image_path
    assert.ok fs.existsSync(output_image_path)
    # now clean up
    tmp_path = pather.join(__dirname, '/../tmp/out.jpg')
    fs.copySync(output_image_path, tmp_path)
    fs.unlink(output_image_path)
  extractor = new Extractor options, callback
  extractor.extract()
