InformerJp2Kakadu = require('./informers/informer-jp2-kakadu').InformerJp2Kakadu

class Informer
  constructor: (@path, @final_callback) ->
    @informer = new InformerJp2Kakadu @path, @final_callback

  inform: ->
    @informer.inform()

exports.Informer = Informer
