fs = require 'fs'
async = require 'async'
path = '/home/jnronall/code/iiif-image/tests/images/trumpler14.jp2'

log_levels = (levels, callback) ->
  console.log levels
  callback()

fs.open path, 'r', (status, fd) ->
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

  read_levels = (callback) ->
    levels_buffer = new Buffer 1
    fs.read fd, levels_buffer, 0, 1, num+7, (err, bytesRead, buffer) ->
      levels = levels_buffer.readInt8()
      log_levels(levels, callback)

  async.series [
    (callback) ->
      read_to_name(callback)
    (callback) ->
      read_levels(callback)
  ],
  (err, results) ->
    fs.close(fd)
