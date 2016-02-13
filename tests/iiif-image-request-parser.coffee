test = require 'tape'
Parser = require('../lib/iiif-image-request-parser').IIIFImageRequestParser

# {scheme}://{server}{/prefix}/{identifier}/{region}/{size}/{rotation}/{quality}.{format}

test 'parsing simple URL', (assert) ->
  url = 'http://www.example.org/image-service/abcd1234/full/full/0/default.jpg'
  parser = new Parser(url)
  params = parser.parse()
  console.log params
  assert.equal params.identifier, 'abcd1234', 'Should parse identifier'
  assert.equal params.region, 'full', 'Should parse region'
  assert.equal params.size, 'full', 'Should parse size'
  assert.equal params.rotation, '0', 'Should parse rotation'
  assert.equal params.quality, 'default', 'Should parse quality'
  assert.equal params.format, 'jpg', 'Should parse format'
  assert.end()

test 'parsing x,y,w,h region', (assert) ->
  url = 'http://www.example.org/image-service/abcd1234/0,1,2,3/full/0/default.jpg'
  parser = new Parser(url)
  params = parser.parse()
  region =
    x: 0
    y: 1
    w: 2
    h: 3
  console.log params
  assert.deepEqual params.region, region, 'Should parse x,y,w,h regions'
  assert.equal params.region_type, 'regionByPx', 'Should be regionByPx'
  assert.end()

test 'parsing pct:x,y,w,h region', (assert) ->
  url = 'http://www.example.org/image-service/abcd1234/pct:10,20,30,40/full/0/default.jpg'
  parser = new Parser(url)
  params = parser.parse()
  region =
    x: 10
    y: 20
    w: 30
    h: 40
  console.log params
  assert.deepEqual params.region, region, 'Should parse pct:x,y,w,h regions'
  assert.equal params.region_type, 'regionByPct', 'Should be regionByPct'
  assert.end()

test 'parsing size by w,h', (assert) ->
  url = 'http://www.example.org/image-service/abcd1234/full/100,200/0/default.jpg'
  parser = new Parser(url)
  params = parser.parse()
  size =
    w: 100
    h: 200
  console.log params
  assert.deepEqual params.size, size, 'Should parse w,h size'
  assert.equal params.size_type, 'sizeByWh', 'Should be sizeByWh'
  assert.end()

test 'parsing size by w,', (assert) ->
  url = 'http://www.example.org/image-service/abcd1234/full/100,/0/default.jpg'
  parser = new Parser(url)
  params = parser.parse()
  size =
    w: 100
    h: undefined
  console.log params
  assert.deepEqual params.size, size, 'Should parse w, size'
  assert.equal params.size_type, 'sizeByWh', 'Should be sizeByW'
  assert.end()
