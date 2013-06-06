#!/usr/bin/env coffee

###

Usage:

% npm install pseudw-util
% npm install libxmljs
% for i in $(ls data/xml/*.xml); do ./bin/jsonfmt.coffee $i > data/json/`basename $i | perl -pe 's/xml/json/'`; done

###

fs = require('fs')
util = require('pseudw-util')
greek = util.greek
treebank = util.treebank
libxml = require('libxmljs')

file = fs.readFileSync(process.argv[2], 'utf8')
metadata = libxml.parseXml(file)

sentences = []
for sentenceNode in metadata.find("/treebank/sentence")
  wordId2word = {}
  sentence =
    id: Number(sentenceNode.attr('id').value())
    children: []
  sentences.push(sentence)
  for wordNode in sentenceNode.find("./word")
    word = treebank.wordNode2word(wordNode)
    word.children = []
    wordId2word[word.id] = word

  for wordId, word of wordId2word
    parent = null
    if word.parentId == 0
      parent = sentence
    else
      parent = wordId2word[word.parentId]
    throw "Bad word #{word}" unless parent

    parent.children.push(word)
    word.parentId = null

console.log(JSON.stringify(sentences, ((name, value) -> if value == null then undefined else value), 2))