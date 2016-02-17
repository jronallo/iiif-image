InformerJP2Kakadu = require('./informers/informer-jp2-kakadu').InformerJP2Kakadu

class Informer
  constructor: (@path, @final_callback) ->
    @informer = new InformerJP2Kakadu @path, @final_callback

  inform: ->
    @informer.inform()

exports.Informer = Informer
