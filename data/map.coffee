#!/usr/bin/env coffee

fs = require('fs')
greek = require('pseudw-util').greek
libxml = require('libxmljs')
stream = require('stream')

tagsFile = fs.createReadStream(
  '/Users/nkallen/Workspace/Perseus/agdt-1.6/data/1999.01.0183.xml',
  {encoding: 'utf8'})

documentFile = fs.createReadStream(
'/Users/nkallen/Workspace/Perseus/texts/1999.01/1999.01.0183.xml'
  {encoding: 'utf8'})

class XmlStream extends stream.Stream
  isPaused = false

  constructor: (@parser) ->
    @writable = @readable = true
  write: (chunk, encoding) ->
  pause: ->
    isPaused = true
  resume: ->
    isPaused = false
    @emit 'drain'
  end: ->
    @emit 'end'

class DocumentParser
  class State
    @handleSp:           new State
    @awaitSpeaker:       new State
    @handleSpeaker:      new State
    @awaitLine:          new State
    @handleLine:         new State

  state = State.skip
  speeches = []
  speech = null
  skip = ->
    speech = null
    state = State.skip
  handleSpeech = {
    startElementNS: (elem, attrs, prefix, uri, namespaces) ->
      switch elem
      when "sp"
        speech = {
          speaker: null
          lines: []
        }
        state = State.awaitSpeaker
      when "speaker"
        state = State.handleSpeaker
      when "l"
        state = State.handleLine

    characters: (chars) ->
      switch state
        when State.handleSpeaker
          speech.speaker = chars
        when State.handleLine
          speech.lines.push(chars)
    endElementNS: (elem, prefix, uri) ->
      switch state
        when State.handleSpeaker
          if elem == "speaker"
            state = State.awaitLine
        when State.handleLine
          if elem == "l"
            state = State.awaitLine
          else if elem == "sp"
            speeches.push(speech)
  }
  parser = new libxml.SaxPushParser(handleAnalysis)

  write: (chunk, oncomplete) ->
    parser.push(chunk)
    oncomplete(speeches)
    speeches = []

class DocumentStream extends XmlStream
  write: (chunk, encoding) ->
    @parser.write(chunk, (speeches) =>
      print speeches
      emissions = (@emit('data', speeches) for speech in speeches)
      pause() if false in emissions
    )
    !isPaused

documentStream = new DocumentStream(new DocumentParser)
documentFile.pipe(documentStream)
