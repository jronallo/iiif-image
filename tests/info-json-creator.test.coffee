test = require 'tape'
InfoJSONCreator = require('../lib/info-json-creator').InfoJSONCreator

info =
  width: 6000
  height: 4000
  levels: 3
  sizes: [{width: 150, height: 100},
        {width: 600, height: 400},
        {width: 3000, height: 2000}]
  tiles: [ {width: 512, scaleFactors: [1,2,4,8,16]}]

server_info =
  id: "http://www.example.org/image-service/abcd1234/1E34750D-38DB-4825-A38A-B60A345E591C"
  level: 2

valid_json = {
  "@context" : "http://iiif.io/api/image/2/context.json",
  "@id" : "http://www.example.org/image-service/abcd1234/1E34750D-38DB-4825-A38A-B60A345E591C",
  "protocol" : "http://iiif.io/api/image",
  "width" : 6000,
  "height" : 4000,
  "sizes" : [
    {"width" : 150, "height" : 100},
    {"width" : 600, "height" : 400},
    {"width" : 3000, "height": 2000}
  ],
  "tiles": [
    {"width" : 512, "scaleFactors" : [1,2,4,8,16]}
  ],
  "profile" : [ "http://iiif.io/api/image/2/level2.json" ]
}

test 'test creation of json', (assert) ->
  info_json_creator = new InfoJSONCreator info, server_info
  info_json = info_json_creator.info_json
  assert.deepEqual info_json, valid_json
  assert.end()
