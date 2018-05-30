{Transform} = require 'stream'
{LineStream} = require 'byline'
vcard = require 'vcf'
pipe = require 'multipipe'

class FilterLine extends Transform
  constructor: (opts) ->
    super opts
    @pattern = opts.pattern

  _transform: (chunk, encoding, cb) ->
    data = chunk.toString()
    if not @pattern.test data
      @push data
    cb()
      
class SplitVCard extends Transform
  lines: ''

  _transform: (chunk, encoding, cb) ->
    if /BEGIN\:VCARD/.test chunk
      @lines = ''
    @lines += "#{chunk}\n"
    if /END\:VCARD/.test chunk
      @push @lines
    cb()

class JSONVCard extends Transform
  json: (data) ->
    ret = {}
    attrs = [
      'email'
      'n'
      'tel'
      'title'
      'note'
      'nickname'
    ]
    for i in attrs
      ret[i] = data[i]?._data?.trim()
    ret

  _transform: (chunk, encoding, cb) ->
    @push @json vcard.parse(chunk)[0].data
    cb()

class NameAttr extends Transform
  _transform: (chunk, encoding, cb) ->
    [family, given] = chunk.n?.split ';'
    chunk.familyName = family
    chunk.givenName = given
    @push chunk
    cb()

class OrgAttr extends Transform
  _transform: (chunk, encoding, cb) ->
    note = /.*\/(.*)/.exec chunk.note
    note = if note?.length >=2 then note[1] else ''
    pattern = /([\- a-zA-Z0-9]*)(\(*.*)/
    [input, title1, org1] = pattern.exec note
    [input, title2, org2] = pattern.exec chunk.title
    chunk.title = if title1?.length > title2?.length then title1 else title2
    chunk.organization = if org1?.length > org2?.length then org1 else org2
    @push chunk
    cb()

class EmailAttr extends Transform
  _transform: (chunk, encoding, cb) ->
    chunk.email ?= chunk.nickname.split(';')[1]?.trim()
    @push chunk
    cb()

class FilterInvalid extends Transform
  _transform: (chunk, encoding, cb) ->
    if not (chunk.email? and (chunk.email == '' or /^Dummy/.test chunk.email))
      @push chunk
    cb()
    
module.exports = 
  default: pipe new LineStream(),
    new FilterLine(pattern: /X\-LOTUS\-CHARSET\:UTF\-8/),
    new SplitVCard(),
    new JSONVCard(readableObjectMode: true),
    new EmailAttr(objectMode: true),
    new FilterInvalid(objectMode: true),
    new NameAttr(objectMode: true),
    new OrgAttr(objectMode: true)
