IIIFImageInformerJP2Kakadu = require('./informers/iiif-image-informer-jp2-kakadu').IIIFImageInformerJP2Kakadu

class IIIFImageInformer
  constructor: (@path, @final_callback) ->
    @informer = new IIIFImageInformerJP2Kakadu @path, @final_callback

  inform: ->
    @informer.inform()

exports.IIIFImageInformer = IIIFImageInformer
