class ImageRequestParser
  constructor: (@url) ->

  ###
  parse the URL and return an object
  @return {Object}
  Object will be in the format
  identifier: String
  region: 'full' || Object
  size: 'full' || Object
  rotation: Object
  quality: String
  format: String

  If region or size return an Object, then type will give information on the
  feature name required to serve the request.

  The rotation Object includes the degrees and a boolean for whether to mirror the image or not first.
  ###
  parse: ->
    # Split the URL and then begin popping parts of the end
    url_parts = @url.split '/'
    console.log url_parts
    quality_format = url_parts.pop()
    [quality, format] = quality_format.split '.'
    rotation_string = url_parts.pop()
    size_string = url_parts.pop()
    region_string = url_parts.pop()
    identifier = url_parts.pop()

    region = @parse_region(region_string)
    size = @parse_size(size_string)
    rotation = @parse_rotation(rotation_string)

    # return an object with the parameters
    identifier: identifier
    region: region
    size: size
    rotation: rotation
    quality: quality
    format: format

  parse_region: (region_string) ->
    # If region has a comma it is not a "full" or "square" region
    if region_string.match /,/
      region_parts = region_string.split ','
      # If the region has a "pct:" then it is a percentage region
      string_h = region_parts.pop()
      string_w = region_parts.pop()
      string_y = region_parts.pop()
      if region_string.match /^pct:/
        region_type = 'regionByPct'
        pcth = parseFloat string_h
        pctw = parseFloat string_w
        pcty = parseFloat string_y
        [pct, x_string] = region_parts.pop().split ':'
        pctx = parseFloat x_string
        # return
        pctx: pctx
        pcty: pcty
        pctw: pctw
        pcth: pcth
        type: region_type
      else # region by pixels
        region_type = 'regionByPx'
        h = parseInt string_h
        w = parseInt string_w
        y = parseInt string_y
        x_string = region_parts.pop()
        x = parseInt x_string
        # return
        x: x
        y: y
        w: w
        h: h
        type: region_type
    else
      region_string

  parse_size: (size_string) ->
    if size_string.match /pct:/
      pct = parseInt size_string.split('pct:')[1]

      pct: pct
      type: 'sizeByPct'
    else if size_string.match /,/
      [w, h] = size_string.split ','
      if w.match /!/
        size_type = 'sizeByForcedWh'
        w = w.replace '!', ''
      w = if w == '' then undefined else parseInt w
      h = if h == '' then undefined else parseInt h
      size_type ?= @determine_size_type(w, h)

      w: w
      h: h
      type: size_type
    else
      size_string

  determine_size_type: (w, h) ->
    if w? && h?
      'sizeByWh'
    else if w?
      'sizeByW'
    else if h?
      'sizeByH'

  parse_rotation: (rotation_string) ->
    if rotation_string.match /!/
      degrees: parseInt rotation_string.replace('!', '')
      mirror: true
    else
      degrees: parseInt rotation_string
      mirror: false

exports.ImageRequestParser = ImageRequestParser
