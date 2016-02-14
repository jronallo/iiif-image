test = require 'tape'
Extractor = require('../lib/iiif-image-extractor').IIIFImageExtractor
pather = require 'path'
path = pather.join __dirname, '/images/trumpler14.jp2'

params =
  identifier: 'trumpler14'
  region: 'full'
  size:
    w: 100
    h: undefined
  rotation:
    degrees: 0
    mirror: false
  quality: 'default'
  format: 'jpg'

info =
  width: 3906
  height: 3906

test 'extract image', (assert) ->
  assert.plan(1)

  options =
    path: path
    params: params
    info: info

  extractor = new Extractor options
  extractor.extract (output_image) ->
    assert.fail()
