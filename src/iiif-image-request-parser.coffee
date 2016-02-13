class IIIFImageRequestParser
  constructor: (@url) ->

  # parse the URL and return an object
  parse: ->
    # Split the URL and then begin popping parts of the end
    url_parts = @url.split '/'
    quality_format = url_parts.pop()
    [quality, format] = quality_format.split '.'
    rotation = url_parts.pop()
    size = url_parts.pop()
    region = url_parts.pop()
    identifier = url_parts.pop()

    # If region has a comma it is not a "full" region
    if region.match /,/
      region_parts = region.split ','
      h = parseInt region_parts.pop()
      w = parseInt region_parts.pop()
      y = parseInt region_parts.pop()
      # If the region has a "pct:" then it is a percentage region
      if region.match /pct:/
        region_type = 'regionByPct'
        [pct, x_string] = region_parts.pop().split ':'
      else # region by pixels
        region_type = 'regionByPx'
        x_string = region_parts.pop()
      x = parseInt x_string
      region =
        x: x
        y: y
        w: w
        h: h

    if size.match /,/
      [w, h] = size.split ','
      console.log [w, h]
      w = if w == '' then undefined else parseInt w
      h = if h == '' then undefined else parseInt h
      console.log [w, h]
      size_type = @determine_size_type(size)
      size =
        w: w
        h: h

    # return an object with the parameters
    identifier: identifier
    region: region
    size: size
    rotation: rotation
    quality: quality
    format: format
    region_type: region_type
    size_type: size_type

  determine_size_type: (size) ->
    [w, h] = size.split ','
    if w? && h?
      'sizeByWh'
    else if w?
      'sizeByW'

exports.IIIFImageRequestParser = IIIFImageRequestParser
