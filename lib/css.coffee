# csso   = require 'csso'
cleanCss = require 'clean-css'
Bundle   = require './bundle'
fs       = require 'fs'
os       = require 'os'
path     = require 'path'
crypto   = require 'crypto'

class Css extends Bundle
  constructor: (@options) ->
    @fileExtension = '.css'
    super

  minify: (code) ->
    return code unless @options.minifyCss

    try
      # csso.justDoIt(code, false, false)
      # csso.parse(code, 'stylesheet', true)
      return cleanCss.process(code, {
        keepSpecialComments:0 # remove all
      });
    catch err
      filename = path.resolve(os.tmpDir(), 'tmpcss.css')
      fs.writeFileSync(filename, code)
      console.error("CSSO", err, "temporary file at: ", filename)
      process.exit()

  render: (namespace) ->
    style = ''
    for file in @files
      if file.namespace == namespace
        if @options.bundle
          hash = '?' + crypto.createHash('md5').update(Math.random().toString()).digest('hex')
        else
          hash = ''
        url = if typeof file.url == 'boolean' then file.file else file.url
        style += "<link href='#{url}#{hash.substring(0, 7)}' rel='stylesheet' type='text/css'/>"
    return style

  _convertFilename: (filename) ->
    splitted = filename.split('.')
    splitted.splice(0, splitted.length - 1).join('.') + '.css'

module.exports = Css
