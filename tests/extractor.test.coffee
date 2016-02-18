test = require 'tape'
Extractor = require('../lib/extractor').Extractor
pather = require 'path'
path = pather.join __dirname, '/images/trumpler14.jp2'
fs = require 'fs-extra'
tempfile = require 'tempfile'

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
    h: 300
    w: 300

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

  params: params
  info: info
  region_xywh: region_xywh
  options:
    path: path
    params: params
    info: info

test_assertions_and_cleanup = (assert, output_image, format) ->
  assert.ok output_image
  # TODO: save the image and do some test of it
  tmp_path = pather.join(__dirname, "/../tmp/out.#{format}")
  fs.writeFile tmp_path, output_image, (err) ->
    # TODO: Run `identify` on the resulting image and test it?
    assert.end()

###
Tests start here:
###

test 'extract image with full region and w, size', (assert) ->
  # assert.plan(2)
  data = fixtures()
  tester = (output_image) ->
    test_assertions_and_cleanup(assert, output_image, data.params.format)
  extractor = new Extractor data.options, tester
  extractor.extract()

test 'extract image with xywh region', (assert) ->
  # assert.plan(2)
  data = fixtures()
  data.options.params['region'] = data.region_xywh
  tester = (output_image) ->
    test_assertions_and_cleanup(assert, output_image, data.params.format)
  extractor = new Extractor data.options, tester
  extractor.extract()

test 'extract image with small region and full size', (assert) ->
  data = fixtures()
  data.options.params['region'] = data.region_xywh
  data.options.params['size'] = 'full'
  tester = (output_image) ->
    test_assertions_and_cleanup(assert, output_image, data.params.format)
  extractor = new Extractor data.options, tester
  extractor.extract()

test 'extract image with small region and w,h size', (assert) ->
  data = fixtures()
  data.options.params['region'] = data.region_xywh
  data.options.params['size'] = {w: 200, h: 200}
  tester = (output_image) ->
    test_assertions_and_cleanup(assert, output_image, data.params.format)
  extractor = new Extractor data.options, tester
  extractor.extract()

test 'extract image with small region and ,h size', (assert) ->
  data = fixtures()
  data.options.params['region'] = data.region_xywh
  data.options.params['size'] = {w: undefined, h: 200}
  tester = (output_image) ->
    test_assertions_and_cleanup(assert, output_image, data.params.format)
  extractor = new Extractor data.options, tester
  extractor.extract()

test 'extract full image with small size but rotated 90 degrees', (assert) ->
  data = fixtures()
  data.options.params['rotation'] = {degrees: 90, mirror: false}
  tester = (output_image) ->
    test_assertions_and_cleanup(assert, output_image, data.params.format)
  extractor = new Extractor data.options, tester
  extractor.extract()

test 'extract and convert to png', (assert) ->
  data = fixtures()
  data.options.params['format'] = 'png'
  tester = (output_image) ->
    test_assertions_and_cleanup(assert, output_image, data.params.format)
  extractor = new Extractor data.options, tester
  extractor.extract()
