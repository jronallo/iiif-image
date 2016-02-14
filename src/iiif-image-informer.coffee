IIIFImageInformerJP2Kakadu = require('./informers/iiif-image-informer-jp2-kakadu').IIIFImageInformerJP2Kakadu

class IIIFImageInformer
  constructor: (@path) ->
    @informer = new IIIFImageInformerJP2Kakadu @path

  inform: (cb) ->
    @informer.inform(cb)

exports.IIIFImageInformer = IIIFImageInformer
