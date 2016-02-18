fs = require 'fs'
path = '/home/jnronall/code/iiif-image/tests/images/trumpler14.jp2'

fs.open path, 'r', (status, fd) ->
  num = 0
  name = 'ff52'
  wind = [null, null]
  while wind.join('') != name
    buffer = new Buffer 1
    fs.readSync(fd, buffer, 0, 1, num)
    wind.shift()
    hex = buffer.toString('hex')
    wind.push(hex)
    num += 1
  buffer = new Buffer 7
  fs.readSync(fd, buffer, 0, 7, num)
  levels_buffer = new Buffer 1
  fs.readSync(fd, levels_buffer, 0, 1, num+7)
  console.log levels_buffer.readInt8()
  fs.close(fd)
