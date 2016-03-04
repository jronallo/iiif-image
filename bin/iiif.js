#! /usr/bin/env node
;

/*
CLI for iiif-image

iiif -i ./tests/images/trumpler14.jp2 -o ~/tmp/iiif-out/ -u /trumpler14/0,0,500,500/100,/0/default.jpg
 */
var Extractor, InfoJSONCreator, Informer, Parser, ProgressBar, _, async, bar, basename, binary, cache_info_json, child_process, fs, full_directory, glob, i, iiif, image, images, info_cb, informer, len, mkdirp, packagejson, path, profile, program, queue, search_path, total, urls, usage, util, yaml;

path = require('path');

fs = require('fs');

yaml = require('js-yaml');

mkdirp = require('mkdirp');

util = require('util');

glob = require('glob');

async = require('async');

_ = require('lodash');

ProgressBar = require('progress');

child_process = require('child_process');

packagejson = require('../package.json');

iiif = require('../lib/index');

Parser = iiif.ImageRequestParser;

InfoJSONCreator = require('iiif-image').InfoJSONCreator;

program = require('commander');

usage = "creates images suitable for a Level 0 IIIF image server.\n\nExample of a single --input file and single --url:\n\niiif --input ./tests/images/trumpler14.jp2 --output ~/tmp/iiif-out/ -u /0,0,500,500/100,/0/default.jpg\n\nExample of a creating multiple images for multiple sources images.\nThe --profile YAML file specifies the different instructions (URL parts)\nthat should be used for each image in the directory.\n\niiif --directory ~/path/to/directory-of-images --output ~/tmp/iiif-out/ --profile ./config/profile.yml\n\nInput and instruction parameters can be mixed and matched.\nInput should be either --input or --directory\nInstructions for processing should be either --url or --profile\n\nAn example YAML profile could look like the following and can include any\nnumber of key value pairs. The keys are simply mneumonic for humans.\n---\nsearch_index_page: /square/300,/0/default.jpg\nindex_show_view:   /full/600,/0/default.jpg\n";

program.version(packagejson.version).usage(usage).option('-i, --input [value]', '/path/to/image.jp2').option('-u, --url [value]', 'URL or path to parse for generating image. Only include pieces other than the identifier e.g. /0,0,500,500/300/0/default.jpg').option('-o, --output [value]', 'Directory to output image. Directory must exist.').option('-b, --binary [value]', 'JP2 binary to use. "kdu" or "opj"; Default "opj".').option('-p, --profile [value]', 'path to profile for image processing').option('-d, --directory [value]', 'path to directory of JP2 images to process').option('-t, --host [value]', 'Base URL host for info.json').option('-l, --level [value]', 'IIIF level. Defaults to 0').option('-s, --show', 'Show (currently with exo-open). Only works in single image mode.').option('-v, --verbose', 'Verbose output').parse(process.argv);

binary = program.binary != null ? program.binary : 'opj';

Informer = iiif.Informer(binary);

Extractor = iiif.Extractor(binary);

if (!program.input && !program.output && !program.url) {
  program.help();
}

images = program.input != null ? [program.input] : program.directory != null ? (full_directory = path.normalize(program.directory), search_path = path.join(full_directory, '*.jp2'), glob.sync(search_path, {
  realpath: true
})) : void 0;

urls = program.url != null ? [program.url] : program.profile != null ? (profile = yaml.safeLoad(fs.readFileSync(program.profile, 'utf8')), _.values(profile)) : void 0;

total = urls.length * images.length;

bar = new ProgressBar(':current of :total [:bar] :percent', {
  total: total
});

queue = async.queue(function(task, queue_callback) {
  var extractor, extractor_cb, options;
  if (program.verbose) {
    console.log(task);
  }
  extractor_cb = function(output_image, options) {
    if (program.verbose) {
      console.log(util.inspect(options, false, null));
    }
    return mkdirp(task.outfile_path, function(err) {
      return fs.writeFile(task.outfile, output_image, function(err) {
        if (program.show) {
          child_process.spawn("exo-open", [task.outfile], {
            detached: true,
            stdio: 'ignore'
          });
        }
        bar.tick();
        return queue_callback();
      });
    });
  };
  options = {
    path: task.image,
    params: task.params,
    info: task.info
  };
  extractor = new Extractor(options, extractor_cb);
  return extractor.extract();
});

queue.concurrency = 1;

queue.drain = function() {
  return console.log('All done.');
};

cache_info_json = function(info, basename) {
  var host, info_json, info_json_creator, info_json_outfile, info_json_string, server_info;
  host = program.host || 'http://example.org';
  server_info = {
    id: path.join(host, basename),
    level: program.level || 0
  };
  info_json_creator = new InfoJSONCreator(info, server_info);
  info_json = info_json_creator.info_json;
  console.log(info_json);
  info_json_outfile = path.join(program.output, basename, 'info.json');
  info_json_string = JSON.stringify(info_json);
  return fs.writeFile(info_json_outfile, info_json_string, function(err) {
    if (!err) {
      return console.log('Wrote info.json');
    }
  });
};

for (i = 0, len = images.length; i < len; i++) {
  image = images[i];
  basename = path.basename(image, '.jp2');
  info_cb = function(info) {
    var full_url, j, len1, parser, results, task, url;
    cache_info_json(info, basename);
    results = [];
    for (j = 0, len1 = urls.length; j < len1; j++) {
      url = urls[j];
      task = {};
      full_url = path.join('/', basename, url);
      parser = new Parser(full_url);
      task.params = parser.parse();
      task.outfile = path.join(program.output, basename, url);
      task.outfile_path = path.dirname(task.outfile);
      task.image = image;
      task.info = _.cloneDeep(info);
      if (program.verbose) {
        console.log(task.params);
      }
      results.push(queue.push(task));
    }
    return results;
  };
  informer = new Informer(image, info_cb);
  informer.inform(info_cb);
}
