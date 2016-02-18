test = require 'tape'
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

###
Tests start here
###

test 'validation of format of the request', (assert) ->
  v = new Validator all_params
  assert.ok v.valid_region(), 'valid region'
  assert.ok v.valid_size(), 'valid size'
  assert.ok v.valid_rotation(), 'valid rotation'
  assert.ok v.valid_quality(), 'valid quality'
  assert.ok v.valid_format(), 'valid format'
  assert.end()

test 'validate region with full', (assert) ->
  params = region: 'full'
  v = new Validator params
  assert.ok v.valid_region()
  assert.end()

test 'validate region with x,y,w,h', (assert) ->
  params = region: {x: 0, y:0, w: 2, h: 2}
  v = new Validator params
  assert.ok v.valid_region()
  assert.end()

test 'region cannot be other than string or object', (assert) ->
  params = region: /regex/
  v = new Validator params
  assert.notOk v.valid_region()
  assert.end()

test 'region width and height ', (assert) ->
  params = region: {x: 0, y:0, w: 0, h: 0}
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

test 'size with object with percentage', (assert) ->
  params = size: {pct:3}
  v = new Validator params
  assert.ok v.valid_size()
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
