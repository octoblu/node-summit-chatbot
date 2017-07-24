readline        = require 'readline'
MeshbluHttp     = require 'meshblu-http'
MeshbluFirehose = require 'meshblu-firehose-socket.io'
MeshbluConfig   = require 'meshblu-config'
colors          = require 'colors/safe'
_               = require 'lodash'

class Chatter
  constructor: (@meshbluConfig)->
    @prompt = readline.createInterface
      input:  process.stdin,
      output: process.stdout

  start: =>
    console.log colors.magenta 'Loading chat service...'

    meshbluConfig = new MeshbluConfig().toJSON()
    @meshbluHttp = new MeshbluHttp meshbluConfig
    @meshbluFirehose = new MeshbluFirehose {meshbluConfig}
    @meshbluHttp.whoami (error, @user) =>
      console.error error.stack if error?
      console.log colors.cyan "Your username is #{@user.name} and your uuid is #{@user.uuid}"

    @prompt.on 'line', @onInput

  onInput: (msg) =>
    @sendMessage msg

  sendMessage: (msg) =>
    console.log colors.green "I was gonna send #{msg}, if I felt like it"

module.exports = Chatter
