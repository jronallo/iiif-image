tempfile = require 'tempfile'
child_process = require 'child_process'
async = require 'async'
fs = require 'fs'
_ = require 'lodash'

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

  ###
  TODO: optimize pick_reduction
  This could be improved to be more exact in the reduction to pick. In some cases
  where the image requested is the same as the size of on of the quality layers
  it will pick a larger layer than it needs to.
  ###
  pick_reduction: ->
    region_width = if @params.region == 'full' then @info.width else @params.region.w

    reduction_factor = (region_width / @params.size.w)
    scale_factors = @info.tiles[0].scaleFactors.reverse()

    reduction_scale_matches = []
    current_level = @info.levels
    for scale_factor, index in scale_factors
      scale_factor_reduction =
        scale_factor: scale_factor
        reduction: current_level
      reduction_scale_matches.push scale_factor_reduction
      current_level -= 1

    # select every reduction_scale_match that is the same or larger than our
    # reduction_factor
    same_or_bigger = _.filter reduction_scale_matches, (rsm) ->
      reduction_factor >= rsm.scale_factor
    # Pick the first one that matches
    same_or_bigger[0].reduction

exports.IIIFImageExtractorJP2Kakadu = IIIFImageExtractorJP2Kakadu
