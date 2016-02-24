#! /usr/bin/env node
;

/*
CLI for iiif-image

iiif -i ./tests/images/trumpler14.jp2 -o ~/tmp/iiif-out/ -u /trumpler14/0,0,500,500/100,/0/default.jpg
 */
var Extractor, Informer, Parser, ProgressBar, _, all_work, async, bar, basename, binary, child_process, fn, fs, full_directory, full_url, glob, i, iiif, image, images, j, len, len1, mkdirp, outfile, outfile_path, packagejson, params, parser, path, profile, program, search_path, total, url, urls, usage, util, yaml;

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

program = require('commander');

usage = "creates images suitable for a Level 0 IIIF image server.\n\nExample of a single --input file and single --url:\n\niiif --input ./tests/images/trumpler14.jp2 --output ~/tmp/iiif-out/ -u /0,0,500,500/100,/0/default.jpg\n\nExample of a creating multiple images for multiple sources images.\nThe --profile YAML file specifies the different instructions (URL parts)\nthat should be used for each image in the directory.\n\niiif --directory ~/path/to/directory-of-images --output ~/tmp/iiif-out/ --profile ./config/profile.yml\n\nInput and instruction parameters can be mixed and matched.\nInput should be either --input or --directory\nInstructions for processing should be either --url or --profile\n\nAn example YAML profile could look like the following and can include any\nnumber of key value pairs. The keys are simply mneumonic for humans.\n---\nsearch_index_page: /square/300,/0/default.jpg\nindex_show_view:   /full/600,/0/default.jpg\n";

program.version(packagejson.version).usage(usage).option('-i, --input [value]', '/path/to/image.jp2').option('-u, --url [value]', 'URL or path to parse for generating image. Only include pieces other than the identifier e.g. /0,0,500,500/300/0/default.jpg').option('-o, --output [value]', 'Directory to output image. Directory must exist.').option('-b, --binary [value]', 'JP2 binary to use. "kdu" or "opj"; Default "opj".').option('-p, --profile [value]', 'path to profile for image processing').option('-d, --directory [value]', 'path to directory of JP2 images to process').option('-s, --show', 'Show (currently with exo-open). Only works in single image mode.').option('-v, --verbose', 'Verbose output').parse(process.argv);

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

all_work = [];

for (i = 0, len = images.length; i < len; i++) {
  image = images[i];
  basename = path.basename(image, '.jp2');
  fn = function(image, basename, params, outfile, outfile_path) {
    return all_work.push(function(done) {
      var extractor_cb, info_cb, informer;
      extractor_cb = function(output_image, options) {
        if (program.verbose) {
          console.log(util.inspect(options, false, null));
        }
        return mkdirp(outfile_path, function(err) {
          return fs.writeFile(outfile, output_image, function(err) {
            if (program.show) {
              child_process.spawn("exo-open", [outfile], {
                detached: true,
                stdio: 'ignore'
              });
            }
            bar.tick();
            return done(null, outfile);
          });
        });
      };
      info_cb = function(info) {
        var extractor, options;
        options = {
          path: image,
          params: params,
          info: info
        };
        extractor = new Extractor(options, extractor_cb);
        return extractor.extract();
      };
      informer = new Informer(image, info_cb);
      return informer.inform(info_cb);
    });
  };
  for (j = 0, len1 = urls.length; j < len1; j++) {
    url = urls[j];
    full_url = path.join('/', basename, url);
    parser = new Parser(full_url);
    params = parser.parse();
    outfile = path.join(program.output, basename, url);
    outfile_path = path.dirname(outfile);
    if (program.verbose) {
      console.log(params);
    }
    fn(image, basename, params, outfile, outfile_path);
  }
}

async.parallel(all_work, function(err, results) {
  if (program.verbose) {
    return console.log(results.join("\n"));
  }
});
