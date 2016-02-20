InformerJp2Kakadu = require('./informers/informer-jp2-kakadu').InformerJp2Kakadu
InformerJp2Openjpeg = require('./informers/informer-jp2-openjpeg').InformerJp2Openjpeg

informer_creator = (type) ->
  class Informer
    constructor: (@path, @final_callback) ->
      @informer = if type == 'kdu'
        new InformerJp2Kakadu @path, @final_callback
      else if type == 'opj'
        new InformerJp2Openjpeg @path, @final_callback

    inform: ->
      @informer.inform()

exports.Informer = informer_creator
