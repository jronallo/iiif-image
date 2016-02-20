tempfile = require 'tempfile'
ExtractorJp2 = require('./extractor-jp2').ExtractorJp2

class ExtractorJp2Kakadu extends ExtractorJp2
  set_temp_out_image: ->
    @temp_out_image = tempfile('.bmp')

  extract_cmd: ->
    if @params.region == 'full'
      [top, left, height, width] = [0, 0, @info.height, @info.width]
    else
      [top, left, height, width] = [@params.region.y, @params.region.x, @params.region.h, @params.region.w]

    top_pct = top / @info.height
    left_pct = left / @info.width
    height_pct = height / @info.height
    width_pct = width / @info.width

    cmd = "kdu_expand
      -i #{@path}
      -o #{@temp_out_image}
      -region '{#{top_pct},#{left_pct}},{#{height_pct},#{width_pct}}'"

    reduction = if @params.size == 'full'
      0
    else
      @pick_reduction()
    cmd + " -reduce #{reduction}"



exports.ExtractorJp2Kakadu = ExtractorJp2Kakadu
