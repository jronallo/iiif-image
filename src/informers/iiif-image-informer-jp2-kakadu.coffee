parsexml = require('xml2js').parseString
child_process = require 'child_process'
util = require('util')
fg = require 'fs'

class IIIFImageInformerJP2Kakadu
  constructor: (@path) ->

  inform: (cb) ->
    kdu_info_cmd = "kdu_jp2info -siz -boxes 1 -com -i #{@path}"
    child_process.exec kdu_info_cmd, (err, stdout, stderr) =>
      parsexml stdout, (err, kinfo) =>
        console.log util.inspect(kinfo, false, null)
        info = @extract_kinfo(kinfo)
        levels = @extract_levels()
        cb(info)

  extract_kinfo: (kinfo) ->
    jpc = kinfo.JP2_family_file.jp2c[0]
    codestream = jpc.codestream[0]

    width: parseInt codestream.width[0]
    height: parseInt codestream.height[0]

  extract_levels: ->
    


exports.IIIFImageInformerJP2Kakadu = IIIFImageInformerJP2Kakadu
