# iiif-image

Node modules for working with the IIIF Image API

## Modules

The iiif-image package will provide a few different helpers for working with the IIIF Image API.

- `IIIFImageRequestParser`: Parses incoming IIIF Image Request URLs and returns
- `IIIFImageInformer`: Given a path on the filesystem to an image provides information about the image required for responding to a IIIF Image Information Request. This information is also used for properly extracting an image. Note that currently this just gathers information like width and height. (Optional attributes like sizes and tiles will be done too.) It does not format a complete appropriate response to a IIIF Image Information Request.
  - `IIIFImageInformerJP2Kakadu`: Currently only information from JP2 images are provided via Kakadu. Other information providers may be added in the future.
- `IIIFImageExtractor`: Given a path to an image on the filesystem, information about the image (from `IIIFImageInfo`), and request parameters (from `IIIFImageRequestParser`), it extracts the requested image. Any scaling and rotation is done via Imagemagic `convert`.
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
iiif = require 'iiif-image'
Informer = iiif.IIIFImageInformer
Extractor = iiif.IIIFImageExtractor
image_path = '/path/to/image/file.jp2'

extractor_cb = (output_image_path) ->
  console.log output_image_path

info_cb = (info) ->
  options =
    path: image_path
    params: params # from IIIFImageRequestParser
    info: info
  extractor = new Extractor options, extractor_cb
  extractor.extract()

informer = new Informer image_path, info_cb
informer.inform(info_cb)  
```

## Compliance

The goal is to have `iiif-image` be compliant with all levels of [version 2.1](http://iiif.io/api/image/2.1/compliance/) of the API. It is not there yet. The following is what I believe to be the current compliance level.

`IIIFImageRequestParser` should be able to extract parameters from all valid Image Request URLs. It does not enforce any quality or format as this is left up to the server to determine what it wants to support. This also means that qualities and formats not mentioned in the specification will be treated like any other value.

`IIIFImageInformerJP2Kakadu` ought to provide most (all?) of the information needed about an image without having to know about the particulars of the image server.

`IIIFImageExtractorJP2Kakadu` is believed to comply with Level 0 in all aspects but some parameters at a higher level.

- Region: Level 1
- Size: Level 1 (except sizeByPct)
- Rotation: Level 2 (does not do mirroring yet)
- Quality: Level 1 (unlikely that options other than 'default' will be supported without a pull request)
- Format: Level 2. Since the format is just passed through from the parameters it receives to Imagemagick, other formats beyond the Level 2 required ones could work.
- HTTP Features and Indicating Compliance: Left to the individual image server to implement.

## Author

Jason Ronallo

## License and Copyright

See MIT-LICENSE
