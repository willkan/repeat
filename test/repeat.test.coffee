e = require 'expect.js'
should = require 'should'
repeat = require '../index.js'

describe "handle array", ->
  describe "parallelly", ->
    it 'should run parallelly', (done) ->
      arr = [1..5]
      length = arr.length
      res = []
      repeat(arr).par((done, value, index) ->
        setTimeout (-> res.push value; done()), 100 * length - index - 1
      ).end ->
        _res = [5..1]
        for value, index in res
          e(value).to.be _res[index]
        done()
    it 'should return no error the first arg is null', (done) ->
      arr = [1..5]
      repeat(arr).par((done, value, index) ->
        setTimeout (-> done null, value), 100
      ).end (err, res) ->
        should.not.exist err
        for value, index in res
          e(value).to.be arr[index]
        done()
    it 'should throw error if the first arg isnt null', (done) ->
      arr = [1..5]
      repeat(arr).par((done, value, index) ->
        setTimeout (-> done (if index is 2 then new Error else null), null), 100
      ).end (err, res) ->
        should.exist err
        should.not.exist res
        done()
  describe "sequentially", ->
    it 'should run sequentially', (done) ->
      arr = [1..5]
      length = arr.length
      res = []
      repeat(arr).par((done, value, index) ->
        setTimeout (-> res.push value; done()), 100 * length - index - 1
      ).end ->
        for value, index in arr
          e(value).to.be arr[index]
        done()
    it 'should return no error if the first arg is null', (done) ->
      arr = [1..5]
      repeat(arr).seq((done, value, index, prev) ->
        setTimeout (-> done null, value + prev), 100
      ).end (err, res) ->
        should.not.exist err
        _res = [1, 3, 6, 10, 15]
        for value, index in res
          e(value).to.be _res[index]
        done()
    it 'should throw error if the first arg isnt null', (done) ->
      arr = [1..5]
      repeat(arr).seq((done, value, index, prev) ->
        setTimeout (-> done (if index is 2 then new Error else null), null), 100
      ).end (err, res) ->
        should.exist err
        should.not.exist res
        done()
describe.skip "handle object", ->
  describe "parallelly", ->
    it 'should return no error', (done) ->
    it 'should throw error', (done) ->
  describe "sequentially", ->
    it 'should return no error', (done) ->
    it 'should throw error', (done) ->
