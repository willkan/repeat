isArray = (obj) ->
  return (Object::toString.apply obj) is '[object Array]'
class Repeat
  constructor: (@arg) ->
  par: (cb) ->
    arg = @arg
    self = @
    if isArray arg
      res = []
      length = arg.length
      counter = 0
      done = (index) ->
        (err, value) ->
          return self.endCb err, null if err
          res[index] = value
          if counter is length - 1
            return self.endCb null, res if self.endCb?
          counter++
      for i in [0...length]
        cb (done i), arg[i], i
    @
  seq: (cb) ->
    arg = @arg
    self = @
    if isArray arg
      res = []
      length = arg.length
      prev = null
      counter = 0
      done = (err, value) ->
        return self.endCb err, null if err
        res.push value
        if counter is length - 1
          return self.endCb null, res if self.endCb?
        prev = value
        counter++
        cb done, arg[counter], counter, prev
      cb done, arg[counter], counter, prev
    @
  end: (@endCb) ->

module.exports = (arg) -> new Repeat arg
