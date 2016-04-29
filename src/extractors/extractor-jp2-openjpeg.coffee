tempfile = require 'tempfile'
child_process = require 'child_process'

SharpManipulator = require('../manipulators/sharp-manipulator').SharpManipulator
ExtractorJp2 = require('./extractor-jp2').ExtractorJp2

class ExtractorJp2Openjpeg extends ExtractorJp2
  set_temp_out_image: ->
    @temp_out_image = tempfile('.tif')

  extract_cmd: ->
    cmd = "opj_decompress
          -i #{@path}
          -o #{@temp_out_image} "

    if @params.region != 'full'
      region = @params.region
      cmd += """ -d "#{region.x},#{region.y},#{region.x+region.w},#{region.y+region.h}"
               """

    reduction = if @params.size == 'full'
      0
    else
      @pick_reduction()
    cmd + " -r #{reduction}"

exports.ExtractorJp2Openjpeg = ExtractorJp2Openjpeg
