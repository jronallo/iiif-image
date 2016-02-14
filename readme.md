# iiif-image

Node modules for working with the IIIF Image API

## Modules

The iiif-image package will provide a few different helpers for working with the IIIF Image API.

- `IIIFImageRequestParser`: Parses incoming IIIF Image Request URLs and returns
- `IIIFImageInformer`: Given a path on the filesystem to an image provides information about the image required for responding to a IIIF Image Information Request. This information is also used for properly extracting an image. Note that currently this just gathers information like width and height. (Optional attributes like sizes and tiles will be done too.) It does not format a complete appropriate response to a IIIF Image Information Request.
  - `IIIFImageInformerJP2Kakadu`: Currently only information from JP2 images are provided via Kakadu. Other information providers may be added in the future.
- `IIIFImageExtractor`: Given a path to an image on the filesystem, information about the image (from `IIIFImageInfo`), and request parameters (from `IIIFImageRequestParser`), it extracts the requested image. Any scaling and rotation is done via sharp.
  - `IIIFImageExtractorJP2Kakadu`: Currently only JP2 images can be extracted via Kakadu.

## Currently Provided Modules

### `IIIFImageRequestParser`

```coffee
Parser = require('iiif-image').IIIFImageRequestParser
parser = new Parser 'http://www.example.org/image-service/abcd1234/full/full/0/default.jpg'
params = parser.parse()
console.log params
```

### `IIIFImageInformer`

```coffee
Informer = require('iiif-image').IIIFImageInformer
informer = new Info '/path/to/image/file.jp2'
cb = (info) ->
  console.log info
informer.inform(cb)
```

### `IIIFImageExtractor`

In the simplest case the extractor can run as a callback within getting image information. In many image servers the information for the image will be cached and retrieved from the cache instead of needing to be retrieved like the following when a request comes in.

```coffee
Informer = require('iiif-image').IIIFImageInformer
informer = new Info '/path/to/image/file.jp2'

extractor_cb = (output_image_path) ->
  console.log output_image_path

info_cb = (info) ->
  Extractor = require('iiif-image').IIIFImageExtractor
  options =
    path: '/path/to/image/file.jp2'
    params: params # from IIIFImageRequestParser
    info: info
  extractor = new Extractor options
  extractor.extract(extractor_cb)

informer.inform(info_cb)  
```

## Author

Jason Ronallo

## License and Copyright

See MIT-LICENSE
