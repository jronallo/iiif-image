`#! /usr/bin/env node
`

###
CLI for iiif-image

iiif -i ./tests/images/trumpler14.jp2 -o ~/tmp/iiif-out/ -u /trumpler14/0,0,500,500/100,/0/default.jpg
###

path = require 'path'
fs = require 'fs'
mkdirp = require 'mkdirp'
util = require 'util'
iiif = require('../lib/index')
Informer = iiif.Informer('opj')
Parser = iiif.ImageRequestParser
Extractor = iiif.Extractor('opj')
packagejson = require '../package.json'

program = require 'commander'

program
  .version packagejson.version
  .usage "-i ./tests/images/trumpler14.jp2 -o ~/tmp/iiif-out/ -u /trumpler14/0,0,500,500/100,/0/default.jpg"
  .option '-i, --input [value]', '/path/to/image.jp2'
  .option '-o, --output [value]', 'Directory to output image. Directory must exist.'
  .option '-u, --url [value]', 'URL or path to parse for generating image e.g. /trumpler14/0,0,500,500/300/0/default.jpg'
  .option '-v, --verbose', 'Verbose output'
  .parse process.argv


if !program.input && !program.output && !program.url
  program.help()

extractor_cb = (output_image, options) ->
  console.log util.inspect(options, false, null) if program.verbose
  outfile = path.join program.output, program.url
  outfile_path = path.dirname outfile
  mkdirp outfile_path, (err) ->
    fs.writeFile outfile, output_image, (err) ->
      console.log outfile


info_cb = (info) ->
  options =
    path: program.input
    params: params # from ImageRequestParser
    info: info
  extractor = new Extractor options, extractor_cb
  extractor.extract()

parser = new Parser program.url
params = parser.parse()
console.log params if program.verbose

informer = new Informer program.input, info_cb
informer.inform(info_cb)
