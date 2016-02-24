`#! /usr/bin/env node
`

###
CLI for iiif-image

iiif -i ./tests/images/trumpler14.jp2 -o ~/tmp/iiif-out/ -u /trumpler14/0,0,500,500/100,/0/default.jpg
###

path = require 'path'
fs = require 'fs'
yaml = require 'js-yaml'
mkdirp = require 'mkdirp'
util = require 'util'
glob = require 'glob'
async = require 'async'
_ = require 'lodash'
child_process = require 'child_process'
packagejson = require '../package.json'
iiif = require('../lib/index')
Parser = iiif.ImageRequestParser
program = require 'commander'

usage = """
creates images suitable for a Level 0 IIIF image server.

Example of a single --input file and single --url:

iiif --input ./tests/images/trumpler14.jp2 --output ~/tmp/iiif-out/ \
 -u /0,0,500,500/100,/0/default.jpg

Example of a creating multiple images for multiple sources images.
The --profile YAML file that specifies the different instructoins (URL parts)
that should be used for each image in the directory.

iiif --directory ~/path/to/directory-of-images --output ~/tmp/iiif-out/ \
--profile ./config/profile.yml

Input and instruction parameters can be mixed and matched.
Input should be either --input or --directory
Instructions for processing should be either --url or --profile

An example YAML profile could look like the following and can include any
number of key value pairs. The keys are simply mneumonic for humans.
---
search_index_page: /square/300,/0/default.jpg
index_show_view:   /full/600,/0/default.jpg

"""

program
  .version packagejson.version
  .usage usage
  # Single image mode options
  .option '-i, --input [value]', '/path/to/image.jp2'
  .option '-u, --url [value]', 'URL or path to parse for generating image. Only include pieces other than the identifier e.g. /0,0,500,500/300/0/default.jpg'
  # All mode options
  .option '-o, --output [value]', 'Directory to output image. Directory must exist.'
  .option '-b, --binary [value]', 'JP2 binary to use. "kdu" or "opj"; Default "opj".'
  # batch mode options
  .option '-p, --profile [value]', 'path to profile for image processing'
  .option '-d, --directory [value]', 'path to directory of JP2 images to process'
  # output options
  .option '-s, --show', 'Show (currently with exo-open). Only works in single image mode.'
  .option '-v, --verbose', 'Verbose output'
  .parse process.argv

# By default use the opj binary.
binary = if program.binary? then program.binary else 'opj'
Informer = iiif.Informer(binary)
Extractor = iiif.Extractor(binary)

if !program.input && !program.output && !program.url
  program.help()

images = if program.input?
  [program.input]
else if program.directory?
  # find all JP2s in a directory
  full_directory = path.normalize program.directory
  search_path = path.join full_directory, '*.jp2'
  glob.sync(search_path, {realpath: true})

urls = if program.url?
  [program.url]
else if program.profile?
  profile = yaml.safeLoad(fs.readFileSync(program.profile, 'utf8'))
  _.values(profile)

all_work = []

for image in images
  basename = path.basename image, '.jp2'
  for url in urls
    full_url = path.join '/', basename, url
    parser = new Parser full_url
    params = parser.parse()
    outfile = path.join program.output, basename, url
    outfile_path = path.dirname outfile
    console.log params if program.verbose

    # At this point we have the data we need so we form a closure to wrap it
    # all up and keep these values stable for each function that gets passed
    # to all_work for later processing.
    do (image, basename, params, outfile, outfile_path) ->
      all_work.push (done) ->
        # extractor is called last
        extractor_cb = (output_image, options) ->
          console.log util.inspect(options, false, null)# if program.verbose
          mkdirp outfile_path, (err) ->
            fs.writeFile outfile, output_image, (err) ->
              if program.show
                child_process.spawn "exo-open", [outfile], {
                  detached: true,
                  stdio: 'ignore'
                }
              done(null, outfile)
        # info_cb is called after we get the information
        # TODO: cache the information for speed or run the info once and then
        # do the multiple extractions.
        info_cb = (info) ->
          options =
            path: image
            params: params # from ImageRequestParser
            info: info
          extractor = new Extractor options, extractor_cb
          extractor.extract()

        informer = new Informer image, info_cb
        informer.inform(info_cb)

async.parallel all_work, (err, results) ->
  console.log results.join("\n")
