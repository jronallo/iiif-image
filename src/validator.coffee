###
Validates Image Request URL parameters as well as whether the
requested region is out of bounds (if image info is given as well).
Except for rotation values it will determine whether the request is
valid according to the specification and not necessarily whether
any image server supports particular values. For instance the specification
lists webp as a valid format though

TODO: extend the validations to allow for support levels to be given to more accurately reflect what any particular image server might actually support.
###
_ = require 'lodash'

###
From
###
type = do ->
  classToType = {}
  for name in "Boolean Number String Function Array Date RegExp Undefined Null".split(" ")
    classToType["[object " + name + "]"] = name.toLowerCase()

  (obj) ->
    strType = Object::toString.call(obj)
    classToType[strType] or "object"

class Validator
  constructor: (@params, @info) ->

  valid: ->
    if @valid_params() && !@out_of_bounds() then true else false

  ###
  Only checks that the format of the request params is correct. Does not check
  for whether is matches up with the image information in a way that can be
  successful.
  ###
  valid_params: ->
    if @valid_region() && @valid_size() && @valid_rotation() && @valid_quality() && @valid_format() then true else false

  valid_region: ->
    region = @params.region
    if type(region) == 'string'
      if region == 'full' then true else false
    else if type(region) == 'object'
      if @valid_region_xywh()
        if region.w > 0 && region.h > 0
          true
        else
          false
      else if @valid_region_pct_xywh()
        if region.pctw > 0 && region.pcth > 0
          true
        else
          false
      else
        false
    else
      false

  valid_region_xywh: ->
    region = @params.region
    type(region.x) == 'number' && !isNaN(region.x) && type(region.y) == 'number' && !isNaN(region.y) && type(region.w) == 'number' && !isNaN(region.w) && type(region.h) == 'number' && !isNaN(region.h)

  valid_region_pct_xywh: ->
    region = @params.region
    type(region.pctx) == 'number' && !isNaN(region.pctx) && type(region.pcty) == 'number' && !isNaN(region.pcty) && type(region.pctw) == 'number' && !isNaN(region.pctw) && type(region.pcth) == 'number' && !isNaN(region.pcth)

  valid_size: ->
    size = @params.size
    if type(size) == 'string'
      if size == 'full' then true else false
    else if type(size) == 'object'
      # could be some w and h combination or a percentage
      if size.w == 0 || size.h == 0
        false
      else if type(size.w) == 'number' && type(size.h) == 'number'
        true
      else if type(size.w) == 'number' && !size.h?
        true
      else if !size.w? && type(size.h) == 'number'
        true
      else if type(size.pct) == 'number'
        true
      else
        false
    else # not a string or an object
      false

  valid_rotation: ->
    rotation = @params.rotation
    if type(rotation.degrees) == 'number'
      if _.includes [0, 90, 180, 270], rotation.degrees
        true
      else
        false
    else # not a number
      false

  valid_quality: ->
    valid_qualities = ['color', 'gray', 'bitonal', 'default']
    if _.includes valid_qualities, @params.quality then true else false

  valid_format: ->
    valid_formats = ['jpg', 'tif', 'png', 'gif', 'jp2', 'pdf', 'webp']
    if _.includes valid_formats, @params.format then true else false

  out_of_bounds: ->
    region = @params.region
    if (region.x? && region.x > @info.width) ||
      (region.y? && region.y > @info.height) then true else false


exports.Validator = Validator
