IIIFImageExtractorJP2Kakadu = require('./extractors/iiif-image-extractor-jp2-kakadu').IIIFImageExtractorJP2Kakadu

class IIIFImageExtractor
  constructor: (@options, @final_callback) ->
    @extractor = new IIIFImageExtractorJP2Kakadu @options, @final_callback

  extract: ->
    @extractor.extract()

exports.IIIFImageExtractor = IIIFImageExtractor
