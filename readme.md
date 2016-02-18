# iiif-image

Node modules for working with the IIIF Image API

## Modules

The iiif-image package will provide a few different helpers for working with the IIIF Image API.

- `ImageRequestParser`: Parses incoming IIIF Image Request URLs and returns
- `Informer`: Given a path on the filesystem to an image provides information about the image required for responding to a IIIF Image Information Request. This information is also used for properly extracting an image. Note that currently this just gathers information like width and height. (Optional attributes like sizes and tiles will be done too.) It does not format a complete appropriate response to a IIIF Image Information Request.
  - `InformerJP2Kakadu`: Currently only information from JP2 images are provided via Kakadu. Other information providers may be added in the future.
- `InfoJSONCreator`: Given the output of `Informer` and some other information it will create a nice JSON or JSON-LD representation in response to an IIIF Image Information request.
- `Extractor`: Given a path to an image on the filesystem, information about the image (from `Informer`), and request parameters (from `ImageRequestParser`), it extracts the requested image. Any scaling and rotation is done via Imagemagic `convert`.
  - `ExtractorJP2Kakadu`: Currently only JP2 images can be extracted via Kakadu.
    - While there are multiple manipulators only the `SharpManipulator` is hooked up to work with this extractor. The Imagemagick-based `ConvertManipulator` was known to have been working at some point in the past. These could eventually be configurable, but in most cases the `SharpManipulator` ought to be preferred as it will return the image as a Buffer which can be sent directly back to the client.

## Requirements

Currently the Kakadu binary `kdu_expand` and the Imagemagick `convert` command ought to be in the path of the user who is running this code.

## Currently Provided Modules

### `ImageRequestParser`

```coffee
Parser = require('iiif-image').ImageRequestParser
parser = new Parser 'http://www.example.org/image-service/abcd1234/full/full/0/default.jpg'
params = parser.parse()
console.log params
```

### `Informer`

```coffee
Informer = require('iiif-image').Informer
cb = (info) ->
  console.log info
informer = new Informer '/path/to/image/file.jp2', cb
informer.inform()
```

### `InfoJSONCreator`

```coffee
InfoJSONCreator = require('iiif-image').InfoJSONCreator
info_json_creator = new InfoJSONCreator info, server_info
info_json = info_json_creator.info_json
```

### `Extractor`

In the simplest case the extractor can run as a callback within getting image information. In many image servers the information for the image will be cached and retrieved from the cache instead of needing to be retrieved like the following when a request comes in.

```coffee
iiif = require 'iiif-image'
Informer = iiif.Informer
Extractor = iiif.Extractor
image_path = '/path/to/image/file.jp2'

extractor_cb = (output_image_path) ->
  console.log output_image_path

info_cb = (info) ->
  options =
    path: image_path
    params: params # from ImageRequestParser
    info: info
  extractor = new Extractor options, extractor_cb
  extractor.extract()

informer = new Informer image_path, info_cb
informer.inform(info_cb)  
```

## Compliance

The goal is to have `iiif-image` be compliant with all levels of [version 2.1](http://iiif.io/api/image/2.1/compliance/) of the API. It is not there yet. The following is what I believe to be the current compliance level.

`ImageRequestParser` should be able to extract parameters from all valid Image Request URLs. It does not enforce any quality or format as this is left up to the server to determine what it wants to support. This also means that qualities and formats not mentioned in the specification will be treated like any other value.

`InformerJP2Kakadu` ought to provide most (all?) of the information needed about an image without having to know about the particulars of the image server.

`ExtractorJP2Kakadu` is believed to comply with Level 0 in all aspects but some parameters at a higher level.

- Region: Level 1
- Size: Level 1 (except sizeByPct)
- Rotation: Level 2 (does not do mirroring yet)
- Quality: Level 1 (unlikely that options other than 'default' will be supported without a pull request)
- Format: Level 2. Since the format is just passed through from the parameters it receives to Imagemagick, other formats beyond the Level 2 required ones could work.
- HTTP Features and Indicating Compliance: Left to the individual image server to implement.

## Development

You'll want to have both of the following running.

To compile the Coffeescript:

```sh
npm run compile
```

To watch for changes and run the tests:

```sh
npm run watch
```

Tests are written using tape.

### TODO
- Test individual extractors and informers.
- Separate tests for each manipulator. Currently only sharp is turned on.
- Module for taking parameters and creating a valid IIIF Image Request URI.
- Better tests for output images

## Author

Jason Ronallo

## License and Copyright

See MIT-LICENSE
