readline        = require 'readline'
MeshbluHttp     = require 'meshblu-http'
MeshbluFirehose = require 'meshblu-firehose-socket.io'
MeshbluConfig   = require 'meshblu-config'
ora             = require 'ora'
colors          = require 'colors/safe'

class Chatter
  constructor: ()->
    @meshbluConfig = new MeshbluConfig().toJSON()
    @prompt = readline.createInterface
      input:  process.stdin,
      output: process.stdout

  start: =>
    @spinner = ora('Loading chat service').start()
    @setupFirehose()
    @setupMeshbluHttp()

  setupFirehose: =>
    meshbluFirehose = new MeshbluFirehose {@meshbluConfig}
    meshbluFirehose.on 'error', (error) =>
      return unless error?
      @spinner.fail(error.toString())

    meshbluFirehose.on 'message', @onMessage
    meshbluFirehose.connect()

  setupMeshbluHttp: =>
    @meshbluHttp = new MeshbluHttp @meshbluConfig

    @meshbluHttp.whoami (error, @user) =>
      return @spinner.fail(error.toString()) if error?
      @spinner.clear()
      @spinner.succeed "Connected as \"#{@user.name}\" (#{@user.uuid})"
      @spinner.info("Example commands:")
      @spinner.info("  - 'What is the current weather in Tempe?'")
      @spinner.info("  - 'What is the latest version of meshblu?'")
      @spinner.info("  - 'Tell me a joke'")
      @readLine()

  readLine: =>
    @spinner.warn "Type a command:  "
    @spinner.stop()
    process.stdin.once 'data', =>
      @prompt.once 'line', (line) =>
        return unless line
        @sendMessage(line)

  sendMessage: (msg) =>
    @spinner.start('Sending message')
    @meshbluHttp.message @getMessage(msg), (error) =>
      if error?
        @spinner.fail("I sent your message, but there was a problem")
        return
      @spinner.text = "I actually sent it. Congratulate me."
      @spinner.text = "Waiting for response"
      @waiting = true
      clearTimeout(@timeout)
      @timeout = setTimeout =>
        return unless @waiting
        @spinner.fail("Timeout")
        @spinner.stop()
        @readLine()
        @waiting = false
      , 10 * 1000

  getMessage: (msg) =>
    return {
      devices: ['f6798094-fe2e-4f09-9bf3-4f688b4e8738']
      message: msg
      respondUuid: @meshbluConfig.uuid
    }

  onMessage: ({data}) =>
    if data?.message?
      @spinner.succeed "Received: #{data.message}"
    else
      @spinner.fail "Invalid message received"
    if @waiting
      @readLine()
      @waiting = false

module.exports = Chatter
