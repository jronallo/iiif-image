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
Gauge = require("gauge")
child_process = require 'child_process'
packagejson = require '../package.json'
iiif = require('../lib/index')
Parser = iiif.ImageRequestParser
InfoJSONCreator = require('iiif-image').InfoJSONCreator
program = require 'commander'

usage = """
creates images suitable for a Level 0 IIIF image server.

Example of a single --input file and single --url:

iiif --input ./tests/images/trumpler14.jp2 --output ~/tmp/iiif-out/ \
  --url /0,0,500,500/100,/0/default.jpg

Example of a creating multiple images for multiple sources images.
The --profile YAML file specifies the different instructions (URL parts)
that should be used for each image in the directory as well as a host server
and IIIF conformance level.

iiif --input ~/path/to/directory-of-images --output ~/tmp/iiif-out/ \
  --profile ./config/profile.yml

Instructions for processing should be either --url or --profile

An example YAML profile could look like the following and can include any
number of key value pairs. The keys are simply mneumonic for humans.

---
host: http://example.org/iiif/
level: 1
urls:
  search_index_page: /square/300,/0/default.jpg
  index_show_view:   /full/600,/0/default.jpg
"""

# TODO: Handle prefixes for creating the full cache path. This could involved
# adding a --prefix option or just parsing the host for the prefix. For now
# the prefix should be added to the output path.

program
  .version packagejson.version
  .usage usage
  # Single image mode options
  .option '-i, --input [value]', '/path/to/image.jp2 or /path/to/directory/'
  .option '-u, --url [value]', 'URL or path to parse for generating image. Only include pieces other than the identifier e.g. /0,0,500,500/300/0/default.jpg'
  # All mode options
  .option '-o, --output [value]', 'Directory to output image. Directory must exist. If your URLs use a prefix value, you should add it to the end of the directory.'
  .option '-b, --binary [value]', 'JP2 binary to use. "kdu" or "opj"; Default "opj".'
  # batch mode options
  .option '-p, --profile [value]', 'path to profile for image processing'
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

stats = fs.statSync program.input
images = if stats.isFile()
  [program.input]
else if stats.isDirectory()
  # find all JP2s in a directory
  full_directory = path.normalize program.input
  search_path = path.join full_directory, '*.jp2'
  glob.sync(search_path, {realpath: true})
else
  console.log "You must include an input file or directory!"
  process.exit()

urls = if program.url?
  [program.url]
else if program.profile?
  profile = yaml.safeLoad(fs.readFileSync(program.profile, 'utf8'))
  _.values(profile.urls)
else
  console.log "You must include a URL or a profile.yml"
  process.exit()

gauge = new Gauge()
total = 0
completed = 0

queue = async.queue (task, queue_callback) ->
  console.log task if program.verbose
  # extractor is called last
  extractor_cb = (output_image, options) ->
    console.log util.inspect(options, false, null) if program.verbose
    mkdirp task.outfile_path, (err) ->
      fs.writeFile task.outfile, output_image, (err) ->
        if program.show
          child_process.spawn "exo-open", [task.outfile], {
            detached: true,
            stdio: 'ignore'
          }
        completed += 1
        percent_completed = completed/total
        gauge.show("#{completed} of #{total}", percent_completed)
        queue_callback()

  # prepare for extractor
  options =
    path: task.image
    params: task.params # from ImageRequestParser
    info: task.info
  extractor = new Extractor options, extractor_cb
  extractor.extract()

queue.concurrency = 1

queue.drain = ->
  console.log 'All done.'

cache_info_json = (info, basename) ->
  return unless profile?
  host = profile.host
  server_info =
    id: host + basename
    level: profile.level
  info_json_creator = new InfoJSONCreator info, server_info
  info_json = info_json_creator.info_json
  console.log info_json if program.verbose
  info_json_outfile = path.join program.output, basename, 'info.json'
  info_json_string = JSON.stringify info_json
  fs.writeFile info_json_outfile, info_json_string, (err) ->
    if !err
      console.log 'Wrote info.json' if program.verbose

urls_from_sizes = (sizes) ->
  _.map sizes, url_from_size

url_from_size = (size) ->
  "/full/#{size.width},#{size.height}/0/default.jpg"

for image in images
  do (image) ->
    basename = path.basename image, '.jp2'
    # info_cb is called after we get the information
    info_cb = (info) ->
      # cache the info.json
      cache_info_json(info, basename)

      # If there aren't any URLs and the level is zero then just use the
      # sizes from the JP2 levels.
      if urls.length == 0
        urls = urls_from_sizes(info.sizes)

      for url in urls
        task = {}
        full_url = path.join '/', basename, url
        parser = new Parser full_url
        task.params = parser.parse()
        task.outfile = path.join program.output, basename, url
        task.outfile_path = path.dirname task.outfile
        task.image = image
        task.info = _.cloneDeep info
        console.log task if program.verbose
        total += 1
        queue.push(task)

    informer = new Informer image, info_cb
    informer.inform(info_cb)
