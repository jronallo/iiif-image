enrich_params = (params, info) ->
  # enrich the params
  # Only if we have a pct region do we need to do this calculation
  if params.region.pctx? && !params.region.x?
    # calculate x,y,w,h and enrich the params with what we find
    params.region.x = Math.round info.width * (params.region.pctx/100)
    params.region.y = Math.round info.height * (params.region.pcty/100)
    params.region.w = Math.round info.width * (params.region.pctw/100)
    params.region.h = Math.round info.height * (params.region.pcth/100)

  if params.size.pct?
    # determine size of original resulting image
    region_width = if params.region == 'full' then info.width else params.region.w
    # determine the final size that we want for the image
    percent_factor = params.size.pct / 100
    params.size.w = Math. round(region_width * percent_factor)

  params # return

exports.enrich_params = enrich_params
