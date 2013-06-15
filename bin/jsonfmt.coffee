#!/usr/bin/env coffee

###

Usage:

% npm install pseudw-util
% npm install libxmljs
% for i in $(ls data/xml/1*.xml); do ./bin/jsonfmt.coffee $i > data/json/`basename $i | perl -pe 's/xml/json/'`; done

###

fs = require('fs')
util = require('pseudw-util')
greek = util.greek
treebank = util.treebank
libxml = require('libxmljs')

file = fs.readFileSync(path = process.argv[2], 'utf8')
console.warn(path)
metadata = libxml.parseXml(file)

tokens = []
for sentenceNode in metadata.find("/treebank/sentence")
  sentenceId = Number(sentenceNode.attr('id').value())
  for wordNode in sentenceNode.find("./word")
    token = treebank.wordNode2word(wordNode)
    token.sentenceId = sentenceId
    tokens.push(token)

console.log(JSON.stringify(tokens, ((name, value) -> if value == null then undefined else value), 2))