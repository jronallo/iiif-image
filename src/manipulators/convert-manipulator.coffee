child_process = require 'child_process'

# Use Imagemagick's convert command to manipulate an image based on params
class ConvertManipulator
  constructor: (@image_path, @params, @info, @final_image_path) ->

  manipulate: (callback) =>
    convert_cmd = @convert_cmd()
    child_process.exec convert_cmd, (err, stdout, stderr) =>
      callback()

  convert_cmd: =>
    cmd = "convert #{@image_path} "
    #resize
    if @params.size != 'full'
      if @params.size.w?
        cmd += " -resize #{@params.size.w} "
      else
        cmd += " -resize x#{@params.size.h} "
    # do we need to rotate too?
    degrees = @params.rotation.degrees
    if degrees != 0 && degrees in [90, 180, 270]
      cmd += " -rotate #{degrees} "
    cmd + " #{@final_image_path}"

exports.ConvertManipulator = ConvertManipulator
