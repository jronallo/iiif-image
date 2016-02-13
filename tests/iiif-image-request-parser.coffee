test = require 'tape'
Parser = require('../lib/iiif-image-request-parser').IIIFImageRequestParser

# {scheme}://{server}{/prefix}/{identifier}/{region}/{size}/{rotation}/{quality}.{format}

test 'parsing simple URL', (assert) ->
  url = 'http://www.example.org/image-service/abcd1234/full/full/0/default.jpg'
  parser = new Parser(url)
  params = parser.parse()
  # console.log params
  assert.equal params.identifier, 'abcd1234', 'Should parse identifier'
  assert.equal params.region, 'full', 'Should parse region'
  assert.equal params.size, 'full', 'Should parse size'
  # rotation tested later in this file
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
    type: 'regionByPx'
  # console.log params
  assert.deepEqual params.region, region
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
    type: 'regionByPct'
  # console.log params
  assert.deepEqual params.region, region
  assert.end()

test 'parsing size by w,h', (assert) ->
  url = 'http://www.example.org/image-service/abcd1234/full/100,200/0/default.jpg'
  parser = new Parser(url)
  params = parser.parse()
  size =
    w: 100
    h: 200
    type: 'sizeByWh'
  # console.log params
  assert.deepEqual params.size, size
  assert.end()

test 'parsing size by w,', (assert) ->
  url = 'http://www.example.org/image-service/abcd1234/full/100,/0/default.jpg'
  parser = new Parser(url)
  params = parser.parse()
  size =
    w: 100
    h: undefined
    type: 'sizeByW'
  # console.log params
  assert.deepEqual params.size, size
  assert.end()

test 'parsing size by ,h', (assert) ->
  url = 'http://www.example.org/image-service/abcd1234/full/,100/0/default.jpg'
  parser = new Parser(url)
  params = parser.parse()
  size =
    w: undefined
    h: 100
    type: 'sizeByH'
  # console.log params
  assert.deepEqual params.size, size
  assert.end()

test 'parsing size by pct:n', (assert) ->
  url = 'http://www.example.org/image-service/abcd1234/full/pct:10/0/default.jpg'
  parser = new Parser(url)
  params = parser.parse()
  size =
    pct: 10
    type: 'sizeByPct'
  # console.log params
  assert.deepEqual params.size, size
  assert.end()

test 'parsing size by !w,h', (assert) ->
  url = 'http://www.example.org/image-service/abcd1234/full/!10,20/0/default.jpg'
  parser = new Parser(url)
  params = parser.parse()
  size =
    w: 10
    h: 20
    type: 'sizeByForcedWh'
  # console.log params
  assert.deepEqual params.size, size
  assert.end()

test 'parsing rotation', (assert) ->
  url = 'http://www.example.org/image-service/abcd1234/full/full/90/default.jpg'
  parser = new Parser(url)
  params = parser.parse()
  rotation =
    degrees: 90
    mirror: false
  assert.deepEqual params.rotation, rotation
  assert.end()

test 'parsing mirrored rotation', (assert) ->
  url = 'http://www.example.org/image-service/abcd1234/full/full/!90/default.jpg'
  parser = new Parser(url)
  params = parser.parse()
  rotation =
    degrees: 90
    mirror: true
  assert.deepEqual params.rotation, rotation
  assert.end()
