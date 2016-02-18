// Generated by CoffeeScript 1.10.0
(function() {
  var ImageRequestParser;

  ImageRequestParser = (function() {
    function ImageRequestParser(url) {
      this.url = url;
    }


    /*
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
     */

    ImageRequestParser.prototype.parse = function() {
      var format, identifier, quality, quality_format, ref, region, region_string, rotation, rotation_string, size, size_string, url_parts;
      url_parts = this.url.split('/');
      quality_format = url_parts.pop();
      ref = quality_format.split('.'), quality = ref[0], format = ref[1];
      rotation_string = url_parts.pop();
      size_string = url_parts.pop();
      region_string = url_parts.pop();
      identifier = url_parts.pop();
      region = this.parse_region(region_string);
      size = this.parse_size(size_string);
      rotation = this.parse_rotation(rotation_string);
      return {
        identifier: identifier,
        region: region,
        size: size,
        rotation: rotation,
        quality: quality,
        format: format
      };
    };

    ImageRequestParser.prototype.parse_region = function(region_string) {
      var h, pct, ref, region_parts, region_type, w, x, x_string, y;
      if (region_string.match(/,/)) {
        region_parts = region_string.split(',');
        h = parseInt(region_parts.pop());
        w = parseInt(region_parts.pop());
        y = parseInt(region_parts.pop());
        if (region_string.match(/pct:/)) {
          region_type = 'regionByPct';
          ref = region_parts.pop().split(':'), pct = ref[0], x_string = ref[1];
        } else {
          region_type = 'regionByPx';
          x_string = region_parts.pop();
        }
        x = parseInt(x_string);
        return {
          x: x,
          y: y,
          w: w,
          h: h,
          type: region_type
        };
      } else {
        return region_string;
      }
    };

    ImageRequestParser.prototype.parse_size = function(size_string) {
      var h, pct, ref, size_type, w;
      if (size_string.match(/pct:/)) {
        pct = parseInt(size_string.split('pct:')[1]);
        return {
          pct: pct,
          type: 'sizeByPct'
        };
      } else if (size_string.match(/,/)) {
        ref = size_string.split(','), w = ref[0], h = ref[1];
        if (w.match(/!/)) {
          size_type = 'sizeByForcedWh';
          w = w.replace('!', '');
        }
        w = w === '' ? void 0 : parseInt(w);
        h = h === '' ? void 0 : parseInt(h);
        if (size_type == null) {
          size_type = this.determine_size_type(w, h);
        }
        return {
          w: w,
          h: h,
          type: size_type
        };
      } else {
        return size_string;
      }
    };

    ImageRequestParser.prototype.determine_size_type = function(w, h) {
      if ((w != null) && (h != null)) {
        return 'sizeByWh';
      } else if (w != null) {
        return 'sizeByW';
      } else if (h != null) {
        return 'sizeByH';
      }
    };

    ImageRequestParser.prototype.parse_rotation = function(rotation_string) {
      if (rotation_string.match(/!/)) {
        return {
          degrees: parseInt(rotation_string.replace('!', '')),
          mirror: true
        };
      } else {
        return {
          degrees: parseInt(rotation_string),
          mirror: false
        };
      }
    };

    return ImageRequestParser;

  })();

  exports.ImageRequestParser = ImageRequestParser;

}).call(this);