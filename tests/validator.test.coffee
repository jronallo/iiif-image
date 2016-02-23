test = require 'tape'
_ = require 'lodash'
Validator = require('../lib/validator').Validator

all_params =
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

###
Tests start here
###

test 'validation of params of the request', (assert) ->
  v = new Validator all_params, info
  assert.ok v.valid_region(), 'valid region'
  assert.ok v.valid_size(), 'valid size'
  assert.ok v.valid_rotation(), 'valid rotation'
  assert.ok v.valid_quality(), 'valid quality'
  assert.ok v.valid_params(), 'valid params'
  assert.ok v.valid(), 'all valid'
  assert.end()

test 'validate region with full', (assert) ->
  params = region: 'full'
  v = new Validator params
  assert.ok v.valid_region()
  assert.end()

test 'validate region with square', (assert) ->
  params = region: 'square'
  v = new Validator params
  assert.ok v.valid_region()
  assert.end()

test 'validate region with !square', (assert) ->
  params = region: '!square'
  v = new Validator params
  assert.ok v.valid_region()
  assert.end()

test 'validate region with square!', (assert) ->
  params = region: 'square!'
  v = new Validator params
  assert.ok v.valid_region()
  assert.end()

test 'validate region with x,y,w,h', (assert) ->
  params = region: {x: 0, y:0, w: 2, h: 2}
  v = new Validator params
  assert.ok v.valid_region()
  assert.end()

test 'validate region with pct:x,y,w,h', (assert) ->
  params = region: {pctx: 1.1, pcty: 2.2, pctw: 5.5, pcth: 6.6}
  v = new Validator params
  assert.ok v.valid_region()
  assert.end()

test 'region cannot be other than string or object', (assert) ->
  params = region: /regex/
  v = new Validator params
  assert.notOk v.valid_region()
  assert.end()

test 'region with zero width and height', (assert) ->
  params = region: {x: 0, y:0, w: 0, h: 0}
  v = new Validator params
  assert.notOk v.valid_region()
  assert.end()

test 'invalid region with NaN value for region object', (assert) ->
  params = region: {x:NaN, y:0, w:3, h:3}
  v = new Validator params
  assert.notOk v.valid_region()
  assert.end()

test 'size of full', (assert) ->
  params = size: 'full'
  v = new Validator params
  assert.ok v.valid_size()
  assert.end()

test 'size that is other than string or object ', (assert) ->
  params = size: /regex/
  v = new Validator params
  assert.notOk v.valid_size()
  assert.end()

test 'size with object with w,', (assert) ->
  params = size: {w:3,h:undefined}
  v = new Validator params
  assert.ok v.valid_size()
  assert.end()

test 'size with object with ,h', (assert) ->
  params = size: {w:undefined,h:3}
  v = new Validator params
  assert.ok v.valid_size()
  assert.end()

test 'size with object with w,h', (assert) ->
  params = size: {w:3,h:3}
  v = new Validator params
  assert.ok v.valid_size()
  assert.end()

test 'size with object with percentage pct', (assert) ->
  params = size: {pct:3}
  v = new Validator params
  assert.ok v.valid_size()
  assert.end()

test 'zero size invalid', (assert) ->
  params = size: {w:0, h:undefined}
  v = new Validator params
  assert.notOk v.valid_size()
  assert.end()

test 'valid rotation', (assert) ->
  params = rotation: {degrees: 90}
  v = new Validator params
  assert.ok v.valid_rotation()
  assert.end()

test 'invalid rotation', (assert) ->
  params = rotation: {degrees: 91}
  v = new Validator params
  assert.notOk v.valid_rotation()
  assert.end()

test 'valid default quality', (assert) ->
  params = quality: 'default'
  v = new Validator params
  assert.ok v.valid_quality()
  assert.end()

test 'valid color quality', (assert) ->
  params = quality: 'color'
  v = new Validator params
  assert.ok v.valid_quality()
  assert.end()

test 'valid gray quality', (assert) ->
  params = quality: 'gray'
  v = new Validator params
  assert.ok v.valid_quality()
  assert.end()

test 'valid bitonal quality', (assert) ->
  params = quality: 'bitonal'
  v = new Validator params
  assert.ok v.valid_quality()
  assert.end()

test 'invalid quality', (assert) ->
  params = quality: 'unitonal'
  v = new Validator params
  assert.notOk v.valid_quality()
  assert.end()

test 'valid formats', (assert) ->
  valid_formats = ['jpg', 'tif', 'png', 'gif', 'jp2', 'pdf', 'webp']
  for format in valid_formats
    params = format: format
    v = new Validator params
    assert.ok v.valid_format()
  assert.end()

test 'invalid format', (assert) ->
  params = format: 'asdf'
  v = new Validator params
  assert.notOk v.valid_format()
  assert.end()

test 'invalid request', (assert) ->
  params = _.clone(all_params)
  params.region = {x: 3907, y:3906, w:2, h:2 }
  v = new Validator params, info
  assert.notOk v.valid()
  assert.end()
