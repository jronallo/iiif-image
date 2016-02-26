sharp = require('sharp')
enrich_params = require('../helpers').enrich_params

class SharpManipulator
  constructor: (@temp_bmp, @params, @info, @final_image) ->


  manipulate: (callback) =>
    @params = enrich_params(@params, @info)
    image = sharp(@temp_bmp)
    # resize only if not full
    if @params.size != 'full'
      # If we have a size width and size height then we have one of two ways
      # to resize it.
      if @params.size.w? && @params.size.h?
        image.resize(@params.size.w, @params.size.h)
        # If we had a bang then we resize in order to have the resulting image
        # confined within the given width and height sizes
        if @params.size.type == 'sizeByConfinedWh'
          # maintain aspect ratio but fit within the given width and height
          image.max()
        else
          image.ignoreAspectRatio()

      # if we only have a width parameter we just resize based on that
      else if @params.size.w?
        image.resize(@params.size.w)

      # if we only have a size height
      else if @params.size.h?
        image.resize(null, @params.size.h)

      # If we have a size defined by pct we need to calculate the width
      # and then enrich the @params with it.
      else if @params.size.pct?
        region_width = if @params.region == 'full' then @info.width else @params.region.w
        percent_factor = @params.size.pct / 100
        # Is it correct to just round this?
        calculated_width = Math.round region_width * percent_factor
        @params.size.w = calculated_width
        image.resize(calculated_width)

    degrees = @params.rotation.degrees

    # For sharp rotation happens before flip() so this won't work
    if @params.rotation.mirror
      if degrees == 0 || degrees == 180
        image.flop()
      else if degrees == 90 || degrees == 270
        image.flip()

    # do we need to rotate too?
    if degrees != 0 && degrees in [90, 180, 270]
      image.rotate(degrees)

    if @params.format == 'jpg'
      image.toFormat('jpeg')
    else
      image.toFormat(@params.format)
    image.toBuffer (err, buffer, info) =>
      callback(null, buffer, @params, info)

exports.SharpManipulator = SharpManipulator
