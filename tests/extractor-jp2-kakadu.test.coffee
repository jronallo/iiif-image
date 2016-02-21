test = require 'tape'
Extractor = require('../lib/extractors/extractor-jp2-kakadu').ExtractorJp2Kakadu
fs = require 'fs-extra'
pather = require 'path'
tempfile = require 'tempfile'
fixtures = require('./fixtures/extractor-fixtures').fixtures

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

test 'KDU: extract image with full region and w, size', (assert) ->
  # assert.plan(2)
  data = fixtures()
  tester = (output_image) ->
    test_assertions_and_cleanup(assert, output_image, data.params.format)
  extractor = new Extractor data.options, tester
  extractor.extract()

test 'KDU: extract image with xywh region', (assert) ->
  # assert.plan(2)
  data = fixtures()
  data.options.params['region'] = data.region_xywh
  tester = (output_image) ->
    test_assertions_and_cleanup(assert, output_image, data.params.format)
  extractor = new Extractor data.options, tester
  extractor.extract()

test 'KDU: extract image with small region and full size', (assert) ->
  data = fixtures()
  data.options.params['region'] = data.region_xywh
  data.options.params['size'] = 'full'
  tester = (output_image) ->
    test_assertions_and_cleanup(assert, output_image, data.params.format)
  extractor = new Extractor data.options, tester
  extractor.extract()

test 'KDU: extract image with pct: size', (assert) ->
  data = fixtures()
  data.options.params['region'] = data.region_xywh
  data.options.params['size'] = {pct: 50}
  tester = (output_image) ->
    test_assertions_and_cleanup(assert, output_image, data.params.format)
  extractor = new Extractor data.options, tester
  extractor.extract()

test 'KDU: extract image with small region and w,h size', (assert) ->
  data = fixtures()
  data.options.params['region'] = data.region_xywh
  data.options.params['size'] = {w: 200, h: 200}
  tester = (output_image) ->
    test_assertions_and_cleanup(assert, output_image, data.params.format)
  extractor = new Extractor data.options, tester
  extractor.extract()

test 'KDU: extract image with small region and ,h size', (assert) ->
  data = fixtures()
  data.options.params['region'] = data.region_xywh
  data.options.params['size'] = {w: undefined, h: 200}
  tester = (output_image) ->
    test_assertions_and_cleanup(assert, output_image, data.params.format)
  extractor = new Extractor data.options, tester
  extractor.extract()

test 'KDU: extract full image with small size but rotated 90 degrees', (assert) ->
  data = fixtures()
  data.options.params['rotation'] = {degrees: 90, mirror: false}
  tester = (output_image) ->
    test_assertions_and_cleanup(assert, output_image, data.params.format)
  extractor = new Extractor data.options, tester
  extractor.extract()

test 'KDU: extract and convert to png', (assert) ->
  data = fixtures()
  data.options.params['format'] = 'png'
  tester = (output_image) ->
    test_assertions_and_cleanup(assert, output_image, data.params.format)
  extractor = new Extractor data.options, tester
  extractor.extract()
