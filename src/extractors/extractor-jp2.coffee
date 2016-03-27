_ = require 'lodash'
tempfile = require 'tempfile'
async = require 'async'
child_process = require 'child_process'
fs = require 'fs'
enrich_params = require('../helpers').enrich_params

ConvertManipulator = require('../manipulators/convert-manipulator').ConvertManipulator
SharpManipulator = require('../manipulators/sharp-manipulator').SharpManipulator

class ExtractorJp2
  # TODO: create way to allow choosing a manipulator in the constructor
  constructor: (@options, @final_callback) ->
    @path = @options.path
    @info = @options.info
    @params = @options.params
    @final_image = tempfile(".#{@params.format}")
    @set_temp_out_image()
    @manipulator = new SharpManipulator @temp_out_image, @params, @info, @final_image

    @params = enrich_params(@params, @info)

  extract: =>
    cmd = @extract_cmd()
    async.waterfall [
      (seriescb) -> # extract_cmd
        child_process.exec cmd, (err, stdout, stderr) =>
          seriescb()
      (seriescb) => # convert (resize, rotate, etc.)
        @manipulator.manipulate(seriescb)
      (image_buffer, params, info, seriescb) => # actual response
        seriescb()
        options =
          path: @path
          info: @info
          params: params
        @final_callback(image_buffer, options)
      (seriescb) => # clean up
        fs.unlink @temp_out_image, (err) ->
          return
    ]

  ###
  TODO: optimize pick_reduction
  This could be improved to be more exact in the reduction to pick. In some cases
  where the image requested is the same as the size of on of the quality layers
  it will pick a larger layer than it needs to.
  ###
  pick_reduction: ->
    if @params.size.w?
      region_width = if @params.region == 'full' then @info.width else @params.region.w
      reduction_factor = (region_width / @params.size.w)

    else
      region_height = if @params.region == 'full' then @info.height else @params.region.h
      reduction_factor = (region_height / @params.size.h)

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
    # Pick the first one that matches as the reduction. But if there is none
    # that are bigger then our size
    if same_or_bigger.length > 0
      same_or_bigger[0].reduction
    else
      0

exports.ExtractorJp2 = ExtractorJp2
