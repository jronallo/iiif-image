test = require 'tape'
Extractor = require('../lib/extractors/extractor-jp2-openjpeg').ExtractorJp2Openjpeg
fs = require 'fs-extra'
pather = require 'path'
tempfile = require 'tempfile'
fixtures = require('./fixtures/extractor-fixtures').fixtures
sharp = require 'sharp'

test_assertions_and_cleanup = (assert, output_image, format, tests) ->
  assert.ok output_image
  if tests?
    sharp(output_image).metadata (err, metadata) ->
      assert.equal metadata.width, tests.w if tests.w
      assert.equal metadata.height, tests.h if tests.h
      assert.end()
  else
    assert.end()

###
Tests start here:
###

test 'OPJ: extract image with full region and w, size', (assert) ->
  # assert.plan(2)
  data = fixtures()
  tester = (output_image, options) ->
    test_assertions_and_cleanup(assert, output_image, data.params.format)
  extractor = new Extractor data.options, tester
  extractor.extract()

test 'OPJ: extract image with xywh region', (assert) ->
  # assert.plan(2)
  data = fixtures()
  data.options.params['region'] = data.region_xywh
  tester = (output_image, options) ->
    test_assertions_and_cleanup(assert, output_image, data.params.format)
  extractor = new Extractor data.options, tester
  extractor.extract()

test 'OPJ: extract image with small region and full size', (assert) ->
  data = fixtures()
  data.options.params['region'] = data.region_xywh
  data.options.params['size'] = 'full'
  tester = (output_image, options) ->
    test_assertions_and_cleanup(assert, output_image, data.params.format)
  extractor = new Extractor data.options, tester
  extractor.extract()

test 'OPJ: extract image with pct region', (assert) ->
  data = fixtures()
  data.options.params['region'] = data.region_pct
  data.options.params['size'] = 'full'
  expected_region =
    pctx: 3.0
    pcty: 3.0
    pctw: 3.201
    pcth: 3.201
    x: 117
    y: 117
    w: 125
    h: 125
  tester = (output_image, options) ->
    assert.deepEqual options.params.region, expected_region
    test_assertions_and_cleanup(assert, output_image, data.params.format)
  extractor = new Extractor data.options, tester
  extractor.extract()

test 'OPJ: extract image with pct: size and enrich params with w,', (assert) ->
  data = fixtures()
  data.options.params['region'] = data.region_xywh
  data.options.params['size'] = {pct: 50}
  expected_size =
    pct: 50
    w: 150
  tester = (output_image, options) ->
    assert.deepEqual options.params.size, expected_size
    test_assertions_and_cleanup(assert, output_image, data.params.format)
  extractor = new Extractor data.options, tester
  extractor.extract()

test 'OPJ: extract image with small region and w,h size', (assert) ->
  data = fixtures()
  data.options.params['region'] = data.region_xywh
  data.options.params['size'] = {w: 200, h: 200}
  tests = {w:200, h:200}
  tester = (output_image, options) ->
    test_assertions_and_cleanup(assert, output_image, data.params.format, tests)
  extractor = new Extractor data.options, tester
  extractor.extract()

test 'OPJ: extract image with small region and w,h distorted size', (assert) ->
  data = fixtures()
  data.options.params['region'] = data.region_xywh
  data.options.params['size'] = {w: 200, h: 100}
  tests = {w:200, h:100}
  tester = (output_image, options) ->
    test_assertions_and_cleanup(assert, output_image, data.params.format, tests)
  extractor = new Extractor data.options, tester
  extractor.extract()

test 'OPJ: extract image with !w,h size', (assert) ->
  data = fixtures()
  data.options.params['region'] = {x: 0, y: 0 , w: 200, h: 100}
  data.options.params['size'] = {w: 100, h: 100, type: 'sizeByConfinedWh'}
  tests = {w:100, h:50}
  tester = (output_image, options) ->
    test_assertions_and_cleanup(assert, output_image, data.params.format, tests)
  extractor = new Extractor data.options, tester
  extractor.extract()

test 'OPJ: extract image with !w,h size', (assert) ->
  data = fixtures()
  data.options.params['region'] = {x: 0, y: 0 , w: 100, h: 200}
  data.options.params['size'] = {w: 50, h: 50, type: 'sizeByConfinedWh'}
  tests = {w:25, h:50}
  tester = (output_image, options) ->
    test_assertions_and_cleanup(assert, output_image, data.params.format, tests)
  extractor = new Extractor data.options, tester
  extractor.extract()

test 'OPJ: extract image with !w,h size', (assert) ->
  data = fixtures()
  data.options.params['region'] = 'full'
  data.options.params['size'] = {w: 100, h: 90, type: 'sizeByConfinedWh'}
  tests = {w:90, h:90}
  tester = (output_image, options) ->
    test_assertions_and_cleanup(assert, output_image, data.params.format, tests)
  extractor = new Extractor data.options, tester
  extractor.extract()

test 'OPJ: extract image with !w,h size', (assert) ->
  data = fixtures()
  data.options.params['region'] = 'full'
  data.options.params['size'] = {w: 90, h: 100, type: 'sizeByConfinedWh'}
  tests = {w:90, h:90}
  tester = (output_image, options) ->
    test_assertions_and_cleanup(assert, output_image, data.params.format, tests)
  extractor = new Extractor data.options, tester
  extractor.extract()

test 'OPJ: extract image with small region and ,h size', (assert) ->
  data = fixtures()
  data.options.params['region'] = data.region_xywh
  data.options.params['size'] = {w: undefined, h: 200}
  tester = (output_image, options) ->
    test_assertions_and_cleanup(assert, output_image, data.params.format)
  extractor = new Extractor data.options, tester
  extractor.extract()

test 'OPJ: extract full image with small size but rotated 90 degrees', (assert) ->
  data = fixtures()
  data.options.params['rotation'] = {degrees: 90, mirror: false}
  tester = (output_image, options) ->
    test_assertions_and_cleanup(assert, output_image, data.params.format)
  extractor = new Extractor data.options, tester
  extractor.extract()

test 'OPJ: extract and convert to png', (assert) ->
  data = fixtures()
  data.options.params['format'] = 'png'
  tester = (output_image, options) ->
    test_assertions_and_cleanup(assert, output_image, data.params.format)
  extractor = new Extractor data.options, tester
  extractor.extract()

test 'OPJ: resize above extracted size', (assert) ->
  # /trumpler14/0,0,100,100/101,/0/default.jpg
  data = fixtures()
  params =
    identifier: 'trumpler14'
    region: {x:0, y:0, w: 100, h: 100}
    size: {w: 101, h: undefined}
    rotation: {degrees: 0, mirror: false}
    quality: 'default'
    format: 'jpg'
  data.params = params
  tester = (output_image, options) ->
    test_assertions_and_cleanup(assert, output_image, data.params.format)
  extractor = new Extractor data.options, tester
  extractor.extract()
