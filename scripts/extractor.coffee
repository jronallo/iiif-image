###
run with:
coffee scripts/extractor.coffee /trumpler14/full/pct:10/0/default.jpg /path/to/iiif-image/tests/images/trumpler14.jp2 ~/tmp/out.jpg
###

path = require 'path'
fs = require 'fs'

iiif = require('../src/index')

Informer = iiif.Informer('opj')
Parser = iiif.ImageRequestParser
Extractor = iiif.Extractor('opj')

extractor_cb = (output_image, options) ->
  outfile = process.argv[4]
  fs.writeFile outfile, output_image, (err) ->
    console.log outfile
  # Do something with the output_image Buffer like send the response and cache the image

info_cb = (info) ->
  options =
    path: image_path
    params: params # from ImageRequestParser
    info: info
  extractor = new Extractor options, extractor_cb
  extractor.extract()

url = process.argv[2]
console.log url

parser = new Parser url
params = parser.parse()
console.log params

image_path = process.argv[3]
console.log image_path

informer = new Informer image_path, info_cb
informer.inform(info_cb)
