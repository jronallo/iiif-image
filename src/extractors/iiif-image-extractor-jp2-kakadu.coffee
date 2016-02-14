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
      [top, left, height, width] = [@info.region.y, @info.region.x, @info.region.h, @info.region.w]

    reduction = '3'
    "kdu_expand
      -i #{@path}
      -o #{@temp_bmp}
      -region '{#{top},#{left}},{#{height},#{width}}'
      -reduce #{reduction}"


exports.IIIFImageExtractorJP2Kakadu = IIIFImageExtractorJP2Kakadu
