IIIFImageExtractorJP2Kakadu = require('./extractors/iiif-image-extractor-jp2-kakadu').IIIFImageExtractorJP2Kakadu

class IIIFImageExtractor
  constructor: (@options) ->
    @extractor = new IIIFImageExtractorJP2Kakadu @options

  extract: (cb) ->
    @extractor.extract(cb)

exports.IIIFImageExtractor = IIIFImageExtractor
