tempfile = require 'tempfile'
child_process = require 'child_process'
async = require 'async'
fs = require 'fs'

class IIIFImageExtractorJP2Kakadu
  constructor: (@options, @final_callback) ->
    # console.log @options
    @path = @options.path
    @info = @options.info
    @params = @options.params
    @temp_bmp = tempfile('.bmp')
    @final_image = tempfile(".#{@params.format}")

  extract: =>
    kdu_expand_cmd = @kdu_expand_cmd()
    console.log kdu_expand_cmd
    resize_cmd = @resize_cmd()
    async.series [
      (seriescb) -> # kdu_expand
        child_process.exec kdu_expand_cmd, (err, stdout, stderr) =>
          seriescb()
      (seriescb) -> # convert
        child_process.exec resize_cmd, (err, stdout, stderr) =>
          seriescb()
      (seriescb) => # actual response
        @final_callback(@final_image)
        seriescb()
      (seriescb) => # clean up
        fs.unlink(@temp_bmp)
    ]

  kdu_expand_cmd: ->
    if @params.region == 'full'
      [top, left, height, width] = [0, 0, @info.height, @info.width]
    else
      [top, left, height, width] = [@params.region.y, @params.region.x, @params.region.h, @params.region.w]

    top_pct = top / @info.height
    left_pct = left / @info.width
    height_pct = height / @info.height
    width_pct = width / @info.width
    reduction = @pick_reduction()

    "kdu_expand
      -i #{@path}
      -o #{@temp_bmp}
      -region '{#{top_pct},#{left_pct}},{#{height_pct},#{width_pct}}'
      -reduce #{reduction}"

  resize_cmd: =>
    "convert #{@temp_bmp} -resize #{@params.size.w} #{@final_image}"

  pick_reduction: ->
    # FIXME: Use @info for this
    region_width = if @params.region == 'full' then @info.width else @params.region.w
    console.log [region_width, @params.size.w]
    reduction_factor = (region_width / @params.size.w)
    console.log "reduction_factor #{reduction_factor}"
    scale_factors = @info.tiles[0].scaleFactors.reverse()
    # TODO: How to do this without knowing number of scale_factors?
    switch
      when reduction_factor >= scale_factors[0] then 6
      when reduction_factor >= scale_factors[1] then 5
      when reduction_factor >= scale_factors[2] then 4
      when reduction_factor >= scale_factors[3] then 3
      when reduction_factor >= scale_factors[4] then 2
      when reduction_factor >= scale_factors[5] then 1
      else 0


exports.IIIFImageExtractorJP2Kakadu = IIIFImageExtractorJP2Kakadu
