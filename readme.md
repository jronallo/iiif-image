# iiif-image

Node modules for working with the IIIF Image API

## Modules

The iiif-image package will provide a few different helpers for working with the IIIF Image API.

- `IIIFImageRequestParser`: Parses incoming IIIF Image Request URLs and returns
- `IIIFImageInfo`: Given a path on the filesystem to an image provides information about the image required for responding to a IIIF Image Information Request. This information is also used for properly extracting an image. Uses
  - `IIIFImageInfoJP2Kakadu`: Currently only information from JP2 images are provided via Kakadu. Other information providers may be added in the future.
- `IIIFImageExtractor`: Given a path to an image on the filesystem, information about the image (from `IIIFImageInfo`), and request parameters (from `IIIFImageRequestParser`), it extracts the requested image. Any scaling and rotation is done via sharp.
  - `IIIFImageExtractorJP2Kakadu`: Currently only JP2 images can be extracted via Kakadu.

## Currently Provided Modules

### `IIIFImageRequestParser`

```coffee
Parser = require('iiif-image').IIIFImageRequestParser
parser = new Parser 'http://www.example.org/image-service/abcd1234/full/full/0/default.jpg'
console.log parser.parse()
```

## Author

Jason Ronallo

## License and Copyright

See MIT-LICENSE
