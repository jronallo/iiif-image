child_process = require 'child_process'
InformerJp2 = require('./informer-jp2').InformerJp2

class InformerJp2Openjpeg extends InformerJp2
  # Accepts a callback that is only called after all the information is gathered
  constructor: (@path, @final_callback) ->
    @info = null

  inform: =>
    cmd = "opj_dump -i #{@path}"
    child_process.exec cmd, (err, out, stderr) =>
      width_match = out.match /x1=(.*),/
      width = parseInt width_match[1]

      height_match = out.match /, y1=(.*)/
      height = parseInt height_match[1]

      levels_match = out.match /numresolutions=(.*)/
      levels = parseInt(levels_match[1]) - 1

      tiles_match_width = out.match /tdx=(.*),/
      tiles_width = parseInt tiles_match_width[1]

      tiles_match_height = out.match /tdy=(.*)/
      tiles_height = parseInt tiles_match_height[1]

      @info =
        width: width
        height: height
        levels: levels
        tiles: [
          width: tiles_width
          height: tiles_height
        ]

      sizes = @calculate_sizes_for_levels()

      scale_factors = []
      for level in [0..@info.levels]
        scale_factors.push 2**level
      @info.tiles[0]['scaleFactors'] = scale_factors

      @final_callback(@info)

exports.InformerJp2Openjpeg = InformerJp2Openjpeg
