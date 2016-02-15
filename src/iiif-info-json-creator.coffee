class IIIFInfoJSONCreator
  constructor: (@info, @server_info) ->
    @info_json = @info
    delete @info_json['levels']
    @info_json['protocol'] = "http://iiif.io/api/image"
    profile = "http://iiif.io/api/image/2/level#{@server_info.level}.json"
    @info_json['profile'] = [ profile ]
    @info_json['@id'] = @server_info.id
    @info_json["@context"] = "http://iiif.io/api/image/2/context.json"
    @info_json

exports.IIIFInfoJSONCreator = IIIFInfoJSONCreator
