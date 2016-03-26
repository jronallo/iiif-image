#! /usr/bin/env node
;

/*
CLI for iiif-image

iiif -i ./tests/images/trumpler14.jp2 -o ~/tmp/iiif-out/ -u /trumpler14/0,0,500,500/100,/0/default.jpg
 */
var Extractor, Gauge, InfoJSONCreator, Informer, Parser, _, async, binary, cache_info_json, child_process, completed, fn, fs, full_directory, gauge, glob, i, iiif, image, images, len, mkdirp, packagejson, path, profile, program, queue, search_path, stats, total, url_from_size, urls, urls_from_sizes, usage, util, yaml;

path = require('path');

fs = require('fs');

yaml = require('js-yaml');

mkdirp = require('mkdirp');

util = require('util');

glob = require('glob');

async = require('async');

_ = require('lodash');

Gauge = require("gauge");

child_process = require('child_process');

packagejson = require('../package.json');

iiif = require('../lib/index');

Parser = iiif.ImageRequestParser;

InfoJSONCreator = require('iiif-image').InfoJSONCreator;

program = require('commander');

usage = "creates images suitable for a Level 0 IIIF image server.\n\nExample of a single --input file and single --url:\n\niiif --input ./tests/images/trumpler14.jp2 --output ~/tmp/iiif-out/ --url /0,0,500,500/100,/0/default.jpg\n\nExample of a creating multiple images for multiple sources images.\nThe --profile YAML file specifies the different instructions (URL parts)\nthat should be used for each image in the directory as well as a host server\nand IIIF conformance level.\n\niiif --input ~/path/to/directory-of-images --output ~/tmp/iiif-out/ --profile ./config/profile.yml\n\nInstructions for processing should be either --url or --profile\n\nAn example YAML profile could look like the following and can include any\nnumber of key value pairs. The keys are simply mneumonic for humans.\n\n---\nhost: http://example.org/iiif/\nlevel: 1\nurls:\n  search_index_page: /square/300,/0/default.jpg\n  index_show_view:   /full/600,/0/default.jpg";

program.version(packagejson.version).usage(usage).option('-i, --input [value]', '/path/to/image.jp2 or /path/to/directory/').option('-u, --url [value]', 'URL or path to parse for generating image. Only include pieces other than the identifier e.g. /0,0,500,500/300/0/default.jpg').option('-o, --output [value]', 'Directory to output image. Directory must exist.').option('-b, --binary [value]', 'JP2 binary to use. "kdu" or "opj"; Default "opj".').option('-p, --profile [value]', 'path to profile for image processing').option('-s, --show', 'Show (currently with exo-open). Only works in single image mode.').option('-v, --verbose', 'Verbose output').parse(process.argv);

binary = program.binary != null ? program.binary : 'opj';

Informer = iiif.Informer(binary);

Extractor = iiif.Extractor(binary);

if (!program.input && !program.output && !program.url) {
  program.help();
}

stats = fs.statSync(program.input);

images = stats.isFile() ? [program.input] : stats.isDirectory() ? (full_directory = path.normalize(program.input), search_path = path.join(full_directory, '*.jp2'), glob.sync(search_path, {
  realpath: true
})) : (console.log("You must include an input file or directory!"), process.exit());

urls = program.url != null ? [program.url] : program.profile != null ? (profile = yaml.safeLoad(fs.readFileSync(program.profile, 'utf8')), _.values(profile.urls)) : (console.log("You must include a URL or a profile.yml"), process.exit());

gauge = new Gauge();

total = 0;

completed = 0;

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
        var percent_completed;
        if (program.show) {
          child_process.spawn("exo-open", [task.outfile], {
            detached: true,
            stdio: 'ignore'
          });
        }
        completed += 1;
        percent_completed = completed / total;
        gauge.show(completed + " of " + total, percent_completed);
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
  if (profile == null) {
    return;
  }
  host = profile.host;
  server_info = {
    id: host + basename,
    level: profile.level
  };
  info_json_creator = new InfoJSONCreator(info, server_info);
  info_json = info_json_creator.info_json;
  if (program.verbose) {
    console.log(info_json);
  }
  info_json_outfile = path.join(program.output, basename, 'info.json');
  info_json_string = JSON.stringify(info_json);
  return fs.writeFile(info_json_outfile, info_json_string, function(err) {
    if (!err) {
      if (program.verbose) {
        return console.log('Wrote info.json');
      }
    }
  });
};

urls_from_sizes = function(sizes) {
  return _.map(sizes, url_from_size);
};

url_from_size = function(size) {
  return "/full/" + size.width + "," + size.height + "/0/default.jpg";
};

fn = function(image) {
  var basename, info_cb, informer;
  basename = path.basename(image, '.jp2');
  info_cb = function(info) {
    var full_url, j, len1, parser, results, task, url;
    cache_info_json(info, basename);
    if (urls.length === 0) {
      urls = urls_from_sizes(info.sizes);
    }
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
        console.log(task);
      }
      total += 1;
      results.push(queue.push(task));
    }
    return results;
  };
  informer = new Informer(image, info_cb);
  return informer.inform(info_cb);
};
for (i = 0, len = images.length; i < len; i++) {
  image = images[i];
  fn(image);
}
