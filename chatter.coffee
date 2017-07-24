readline        = require 'readline'
MeshbluHttp     = require 'meshblu-http'
MeshbluFirehose = require 'meshblu-firehose-socket.io'
MeshbluConfig   = require 'meshblu-config'
colors          = require 'colors/safe'
moment          = require 'moment'

class Chatter
  constructor: ()->
    @meshbluConfig = new MeshbluConfig().toJSON()
    @prompt = readline.createInterface
      input:  process.stdin,
      output: process.stdout

  start: =>
    console.log colors.magenta 'Loading chat service...'
    @setupFirehose()
    @setupMeshbluHttp()

  setupFirehose: =>
    meshbluFirehose = new MeshbluFirehose {@meshbluConfig}
    meshbluFirehose.on 'error', @onError
    meshbluFirehose.on 'message', @onMessage
    meshbluFirehose.connect()

  setupMeshbluHttp: =>
    @meshbluHttp = new MeshbluHttp @meshbluConfig

    @meshbluHttp.whoami (error, @user) =>
      console.error error.stack if error?
      console.log colors.cyan "Your username is #{@user.name} and your uuid is #{@user.uuid}"

    @prompt.on 'line', @onInput


  onInput: (msg) =>
    @sendMessage msg

  onError: (error) =>
    console.error "error: #{error.stack || error}"

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
      message: msg
    }

  onMessage: ({data}) =>
    console.log colors.yellow "Received: #{data.message}"

module.exports = Chatter
