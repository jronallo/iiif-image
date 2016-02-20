ExtractorJp2Kakadu = require('./extractors/extractor-jp2-kakadu').ExtractorJp2Kakadu
ExtractorJp2Openjpeg = require('./extractors/extractor-jp2-openjpeg').ExtractorJp2Openjpeg

extractor_creator = (type) ->
  class Extractor
    constructor: (@options, @final_callback) ->
      @extractor = if type == 'kdu'
        new ExtractorJp2Kakadu @options, @final_callback
      else if type == 'opj'
        new ExtractorJp2Openjpeg @options, @final_callback

    extract: ->
      @extractor.extract()

exports.Extractor = extractor_creator
