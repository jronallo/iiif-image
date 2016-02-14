tempfile = require('tempfile')

class IIIFImageExtractorJP2Kakadu
  constructor: (@options) ->
    console.log @options
    @path = @options.path
    @info = @options.info
    @params = @options.params
    @temp_bmp = tempfile('.bmp')

  extract: (cb) ->
    console.log @kdu_expand_cmd()
    cb()

  kdu_expand_cmd: ->
    if @params.region == 'full'
      [top, left, height, width] = [0, 0, @info.height, @info.width]
    else
      [top, left, height, width] = [@params.region.y, @params.region.x, @params.region.h, @params.region.w]

    reduction = @pick_reduction()
    "kdu_expand
      -i #{@path}
      -o #{@temp_bmp}
      -region '{#{top},#{left}},{#{height},#{width}}'
      -reduce #{reduction}"

  pick_reduction: ->
    # base this just on width
    reduction_factor = (@params.region.w / @params.size.w) - 1
    switch
      when reduction_factor >= 12 then 6
      when reduction_factor >= 10 then 5
      when reduction_factor >= 8 then 4
      when reduction_factor >= 6 then 3
      when reduction_factor >= 4 then 2
      when reduction_factor >= 2 then 1
      else 0


exports.IIIFImageExtractorJP2Kakadu = IIIFImageExtractorJP2Kakadu
