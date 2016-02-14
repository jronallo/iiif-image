parsexml = require('xml2js').parseString
child_process = require 'child_process'
util = require('util')
fs = require 'fs'
async = require 'async'

class IIIFImageInformerJP2Kakadu
  # Accepts a callback that is only called after all the information is gathered
  constructor: (@path, @final_callback) ->
    @info = {}

  # Goes through the series of steps needed to extract information on the image
  # and then returns the information to the callback.
  inform: =>
    async.series [
      (seriescb) =>
        @extract_kinfo(seriescb)

      (seriescb) =>
        @extract_levels(seriescb)

      (seriescb) =>
        @calculate_sizes_for_levels(seriescb)

      (seriescb) =>
        @final_callback(@info)
    ]

  extract_kinfo: (cb) ->
    kdu_info_cmd = "kdu_jp2info -siz -boxes 1 -com -i #{@path}"
    child_process.exec kdu_info_cmd, (err, stdout, stderr) =>
      parsexml stdout, (err, kinfo) =>
        jpc = kinfo.JP2_family_file.jp2c[0]
        codestream = jpc.codestream[0]

        @info.width = parseInt codestream.width[0]
        @info.height = parseInt codestream.height[0]
        cb()

  extract_levels: (cb) =>
    fs.open @path, 'r', (status, fd) =>
      num = 0
      name = 'ff52'
      wind = [null, null]

      read_to_name = (callback) ->
        async.whilst(
          () ->
            wind.join('') != name
          (done) ->
            buffer = new Buffer 1
            fs.read fd, buffer, 0, 1, num, (err, bytesRead, buffer) ->
              wind.shift()
              hex = buffer.toString('hex')
              wind.push(hex)
              num += 1
              done(null, wind)
          (err, results) ->
            callback())

      read_levels = (callback) =>
        levels_buffer = new Buffer 1
        fs.read fd, levels_buffer, 0, 1, num+7, (err, bytesRead, buffer) =>
          levels = levels_buffer.readInt8()
          @info.levels = levels
          callback()

      async.series [
        (callback) ->
          read_to_name(callback)
        (callback) =>
          read_levels(callback)
      ],
      (err, results) =>
        fs.close(fd)
        cb()

  calculate_sizes_for_levels: (cb) =>
    sizes = []
    width = @info.width
    height = @info.height
    for [0..@info.levels]
      size =
        width: width
        height: height
      sizes.push size
      width = Math.ceil(width/2.0)
      height = Math.ceil(height/2.0)
    @info.sizes = sizes.reverse()
    cb()

exports.IIIFImageInformerJP2Kakadu = IIIFImageInformerJP2Kakadu
