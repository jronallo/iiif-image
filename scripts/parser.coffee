# script to see parsing and validity of different URLs

Parser = require('../src/image-request-parser').ImageRequestParser
Validator = require('../src/validator').Validator
url = 'http://www.example.org/image-service/abcd1234/full/full/0/default.jpg'
parser = new Parser url
params = parser.parse()
console.log params
validator = new Validator params
console.log validator.valid_params()
