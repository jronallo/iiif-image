#! /usr/bin/env node
;

/*
CLI for iiif-image

iiif -i ./tests/images/trumpler14.jp2 -o ~/tmp/iiif-out/ -u /trumpler14/0,0,500,500/100,/0/default.jpg
 */
var Extractor, Informer, Parser, binary, child_process, extractor_cb, fs, iiif, info_cb, informer, mkdirp, packagejson, params, parser, path, program, util;

path = require('path');

fs = require('fs');

mkdirp = require('mkdirp');

util = require('util');

child_process = require('child_process');

packagejson = require('../package.json');

iiif = require('../lib/index');

Parser = iiif.ImageRequestParser;

program = require('commander');

program.version(packagejson.version).usage("-i ./tests/images/trumpler14.jp2 -o ~/tmp/iiif-out/ -u /trumpler14/0,0,500,500/100,/0/default.jpg").option('-i, --input [value]', '/path/to/image.jp2').option('-o, --output [value]', 'Directory to output image. Directory must exist.').option('-u, --url [value]', 'URL or path to parse for generating image e.g. /trumpler14/0,0,500,500/300/0/default.jpg').option('-b, --binary [value]', 'JP2 binary to use. "kdu" or "opj"; Default "opj".').option('-v, --verbose', 'Verbose output').option('-s, --show', 'Show (currently with exo-open)').parse(process.argv);

binary = program.binary != null ? program.binary : 'opj';

Informer = iiif.Informer(binary);

Extractor = iiif.Extractor(binary);

if (!program.input && !program.output && !program.url) {
  program.help();
}

extractor_cb = function(output_image, options) {
  var outfile, outfile_path;
  if (program.verbose) {
    console.log(util.inspect(options, false, null));
  }
  outfile = path.join(program.output, program.url);
  outfile_path = path.dirname(outfile);
  return mkdirp(outfile_path, function(err) {
    return fs.writeFile(outfile, output_image, function(err) {
      console.log(outfile);
      if (program.show) {
        return child_process.spawn("exo-open", [outfile], {
          detached: true,
          stdio: 'ignore'
        });
      }
    });
  });
};

info_cb = function(info) {
  var extractor, options;
  options = {
    path: program.input,
    params: params,
    info: info
  };
  extractor = new Extractor(options, extractor_cb);
  return extractor.extract();
};

parser = new Parser(program.url);

params = parser.parse();

if (program.verbose) {
  console.log(params);
}

informer = new Informer(program.input, info_cb);

informer.inform(info_cb);
