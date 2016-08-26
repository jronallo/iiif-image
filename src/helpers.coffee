enrich_params = (params, info) ->
  # enrich the params
  # Only if we have a pct region do we need to do this calculation
  if params.region.pctx? && !params.region.x?
    # calculate x,y,w,h and enrich the params with what we find
    params.region.x = Math.round info.width * (params.region.pctx/100)
    params.region.y = Math.round info.height * (params.region.pcty/100)
    params.region.w = Math.round info.width * (params.region.pctw/100)
    params.region.h = Math.round info.height * (params.region.pcth/100)

  if params.region == 'square' || params.region == '!square' || params.region == 'square!'
    if info.width == info.height
      # If the image is square then:
      # - x will be 0
      # - y will be 0
      # - w will be the image width
      # - h will be the image height
      x = 0
      y = 0
      w = info.width
      h = info.height
    else if info.width < info.height
      # If orientation is portrait (width < height) then:
      # - x will be 0
      # - w will be the image width.
      # - h will be the image width
      x = 0
      w = info.width
      h = info.width
      if params.region == 'square'
        # y will be minus half the width from the centerpoint
        centery = Math.round info.height/2
        halfwidth = Math.round info.width/2
        y = centery - halfwidth
      else if params.region == '!square'
        # top gravity
        y = 0
      else if params.region == 'square!'
        # bottom gravity
        y = info.height - info.width

    else if info.width > info.height
      # If orientation is landscape (width > height) then:
      # - y will be 0
      # - w will be the image height
      # - h will be the image height
      y = 0
      w = info.height
      h = info.height
      if params.region == 'square'
        # x will be minus half the height from the centerpoint
        centerx = Math.round info.width/2
        halfheight = Math.round info.height/2
        x = centerx - halfheight
      else if params.region == '!square'
        # left gravity
        x = 0
      else if params.region == 'square!'
        # right gravity
        x = info.width - info.height

    params.region = {region_type: 'regionSquare'}
    params.region.x = x
    params.region.y = y
    params.region.w = w
    params.region.h = h

  if params.size.pct?
    # determine size of original resulting image
    region_width = if params.region == 'full' then info.width else params.region.w
    # determine the final size that we want for the image
    percent_factor = params.size.pct / 100
    params.size.w = Math.round(region_width * percent_factor)

  params # return

exports.enrich_params = enrich_params
