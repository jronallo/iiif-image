class InformerJp2
  calculate_sizes_for_levels: (cb) =>
    sizes = []
    width = @info.width
    height = @info.height
    for [0..@info.levels]
      size =
        width: width
        height: height
      sizes.push size
      width = Math.ceil(width/2.0)
      height = Math.ceil(height/2.0)
    @info.sizes = sizes.reverse()
    cb() if cb

exports.InformerJp2 = InformerJp2
