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
  cb = (info) ->
    assert.deepEqual info, expected_info
  informer = new Informer path, cb
  informer.inform()
