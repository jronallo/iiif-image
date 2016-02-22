# iiif-image

Node modules for working with the [International Image Interoperability Framework (IIIF) Image API](http://iiif.io/api/image/).

## Nota bene

This is not an offical implementation of the [IIIF Image API](http://iiif.io/api/image/). For other image servers and applications that implement the standard see <http://iiif.io/apps-demos/> and the [IIIF github organization](https://github.com/iiif).

## Modules

The iiif-image package provides a few different helpers for working with the IIIF Image API.

- `ImageRequestParser`: Parses incoming IIIF Image Request URLs and returns
- Informers: Given a path on the filesystem to an image provides information about the image required for responding to a IIIF Image Information Request. This information is also used for properly extracting an image. Note that currently this just gathers information like width and height. (Optional attributes like sizes and tiles will be done too.) It does not format a complete appropriate response to a IIIF Image Information Request.
  - `InformerJP2Kakadu`: Uses `kdu_jp2info`
  - `InformerJp2Openjpeg`: Uses `opj_dump`
- `InfoJSONCreator`: Given the output of `Informer` and some other information it will create a nice JSON or JSON-LD representation in response to an IIIF Image Information request.
- Extractors:
  - `Extractor`: Is just a wrapper to select an underlying extractor implementation. Every extractor when given a path to an image on the filesystem, information about the image (from `Informer`), and request parameters (from `ImageRequestParser`), it extracts the requested image.
    - `ExtractorJP2Kakadu`: Uses `kdu_expand`
    - `ExtractorJp2Openjpeg`: Uses `opj_decompress`
- Manipulators: While there are multiple manipulators only the `SharpManipulator` is hooked up to work with the current JP2 extractors. The Imagemagick-based `ConvertManipulator` was known to have been working at some point in the past. These could eventually be configurable, but in most cases the `SharpManipulator` ought to be preferred as it will return the image as a Buffer which can be sent directly back to the client.

## Requirements

Image manipulation relies on the [sharp](http://sharp.dimens.io/en/stable/) module which relies on libvips.

In order to handle JP2 files you'll need to install OpenJPEG (`opj_decompress` & `opj_dump`) or the more performant but proprietary Kakadu executables (`kdu_expand` & `kdu_jp2info`).

Note: We do not distribute the Kakadu executables. See the Kakadu copyright notice and disclaimer below.

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
Informer = require('iiif-image').InformerJp2Openjpeg
# or Informer = require('iiif-image').Informer('opj')
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

In the simplest case like the following the extractor can run as a callback from an `Informer` after getting the image information. In many image servers the image information will be cached and retrieved from the cache in which case only `info_cb` would need to be called without invoking an `Informer`.

```coffee
iiif = require 'iiif-image'
Informer = iiif.Informer
Extractor = iiif.Extractor('opj')
image_path = '/path/to/image/file.jp2'

extractor_cb = (output_image) ->
  # Do something with the output_image Buffer like send the response and cache the image

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

`ImageRequestParser` should be able to extract parameters from all valid Image Request URLs. It does not enforce anything like quality or format as this is left up to the server to determine what it wants to support. This also means that qualities and formats not mentioned in the specification will be treated like any other value from the perspective of the parser. A `Validator` is provided which can check the validity of the request parameters that a parser creates. This allows for validity checks early on in a request. A `Validator` if it also has image information can also check whether the requested region is out of bounds.

`InformerJP2Kakadu` ought to provide most (all?) of the information needed about an image without having to know about the particulars of the image server. To create a full Image Information Response this needs to be combined with data about the server. A `InfoJSONCreator` can be used to create a full info.json response.

`ExtractorJP2Kakadu` is believed to comply with Level 0 in all aspects but some parameters at a higher level.

- Region: Level 1
- Size: Level 1
- Rotation: Level 2 (does not do mirroring yet)
- Quality: Level 1 (unlikely that options other than 'default' will be supported without a pull request)
- Format: Level 2. Since the format is just passed through from the parameters it receives to sharp, other formats beyond the Level 2 required ones that sharp supports could work. The `ConvertManipulator` which uses Imagemagick could probably create even more still.
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
- Oops. pct: values should be read in as floats. These should be parsed into the params as pctx, pcty, pctw, and pcth.
- Error handling.
- Test output image is the correct dimensions.
- Separate tests for each manipulator. Currently only sharp is turned on.
- Module for taking parameters and creating a valid IIIF Image Request URI.

## Kakadu Copyright Notice and Disclaimer
You will need to install the Kakadu binaries/executables available [here](http://kakadusoftware.com/downloads/). The executables available there are made available for demonstration purposes only. Neither the author, Dr. Taubman, nor UNSW Australia accept any liability arising from their use or re-distribution.

That site states:

> Copyright is owned by NewSouth Innovations Pty Limited, commercial arm of the UNSW Australia in Sydney. **You are free to trial these executables and even to re-distribute them, so long as such use or re-distribution is accompanied with this copyright notice and is not for commercial gain. Note: Binaries can only be used for non-commercial purposes.** If in doubt please contact the Kakadu Team at info@kakadusoftware.com.

## Author

Jason Ronallo

## License and Copyright

See MIT-LICENSE
