readline        = require 'readline'
MeshbluHttp     = require 'meshblu-http'
MeshbluFirehose = require 'meshblu-firehose-socket.io'
MeshbluConfig   = require 'meshblu-config'
colors          = require 'colors/safe'
_               = require 'lodash'
moment          = require 'moment'

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
    @meshbluFirehose.on 'message', @onMessage

  onInput: (msg) =>
    @sendMessage msg

  sendMessage: (msg) =>
    @meshbluHttp.message @getMessage(msg), (error) =>
      if error?
        console.log colors.error "I sent your message, but there was a problem"
        console.error error.stack
        return

      console.log colors.green "I actually sent it. Congratulate me."


  getMessage: (msg) =>
    return {
      devices: ['f6798094-fe2e-4f09-9bf3-4f688b4e8738']
      query: msg
      sessionId: moment().format()
    }

  onMessage: (msg) =>
    console.log colors.yellow "Received: #{msg}"

module.exports = Chatter
