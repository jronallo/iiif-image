ExtractorJP2Kakadu = require('./extractors/extractor-jp2-kakadu').ExtractorJP2Kakadu

class Extractor
  constructor: (@options, @final_callback) ->
    @extractor = new ExtractorJP2Kakadu @options, @final_callback

  extract: ->
    @extractor.extract()

exports.Extractor = Extractor
