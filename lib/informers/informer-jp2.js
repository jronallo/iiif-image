// Generated by CoffeeScript 1.10.0
(function() {
  var InformerJp2,
    bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  InformerJp2 = (function() {
    function InformerJp2() {
      this.calculate_sizes_for_levels = bind(this.calculate_sizes_for_levels, this);
    }

    InformerJp2.prototype.calculate_sizes_for_levels = function(cb) {
      var height, i, ref, size, sizes, width;
      sizes = [];
      width = this.info.width;
      height = this.info.height;
      for (i = 0, ref = this.info.levels; 0 <= ref ? i <= ref : i >= ref; 0 <= ref ? i++ : i--) {
        size = {
          width: width,
          height: height
        };
        sizes.push(size);
        width = Math.ceil(width / 2.0);
        height = Math.ceil(height / 2.0);
      }
      this.info.sizes = sizes.reverse();
      if (cb) {
        return cb();
      }
    };

    return InformerJp2;

  })();

  exports.InformerJp2 = InformerJp2;

}).call(this);