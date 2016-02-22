sharp = require('sharp')

class SharpManipulator
  constructor: (@temp_bmp, @params, @info, @final_image) ->

  manipulate: (callback) =>
    image = sharp(@temp_bmp)
    # resize
    if @params.size != 'full'
      if @params.size.w?
        image.resize(@params.size.w)

      # If we have a size defined by pct we need to calculate the width
      # and then enrich the @params with it.
      else if @params.size.pct?
        region_width = if @params.region == 'full' then @info.width else @params.region.w
        percent_factor = @params.size.pct / 100
        # Is it correct to just round this?
        calculated_width = Math.round region_width * percent_factor
        @params.size.w = calculated_width
        image.resize(calculated_width)

      else
        image.resize(null, @params.size.h)
    # do we need to rotate too?
    degrees = @params.rotation.degrees
    if degrees != 0 && degrees in [90, 180, 270]
      image.rotate(degrees)

    if @params.format == 'jpg'
      image.toFormat('jpeg')
    else
      image.toFormat(@params.format)
    image.toBuffer (err, buffer, info) =>
      callback(null, buffer, @params, info)

exports.SharpManipulator = SharpManipulator
