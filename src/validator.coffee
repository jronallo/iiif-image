###

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

  ###
  Only checks that the format of the request params is correct. Does not check
  for whether is matches up with the image information in a way that can be
  successful.
  ###
  valid_format: ->
    if @valid_region() && @valid_size() && @valid_rotation() && @valid_quality() then true else false

  valid_region: ->
    region = @params.region
    if type(region) == 'string'
      if region == 'full' then true else false
    else if type(region) == 'object'
      if type(region.x) == 'number' && type(region.y) == 'number' && type(region.w) == 'number' && type(region.h) == 'number'
        if region.w > 0 && region.h > 0
          true
        else
          false
      else
        false
    else
      false

  valid_size: ->
    size = @params.size
    if type(size) == 'string'
      if size == 'full' then true else false
    else if type(size) == 'object'
      # could be some w and h combination or a percentage
      if type(size.w) == 'number' && type(size.h) == 'number'
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



exports.Validator = Validator
