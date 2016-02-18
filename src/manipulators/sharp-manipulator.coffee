sharp = require('sharp')

class SharpManipulator
  constructor: (@temp_bmp, @params, @final_image) ->

  manipulate: (callback) =>
    image = sharp(@temp_bmp)
    # resize
    if @params.size != 'full'
      if @params.size.w?
        image.resize(@params.size.w)
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
      callback(null, buffer, info)




exports.SharpManipulator = SharpManipulator
