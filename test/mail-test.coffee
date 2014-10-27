chai = require "chai"
sinon = require "sinon"
chai.use require "sinon-chai"

expect = chai.expect

describe "mail", ->
    beforeEach ->
        @robot =
            respond: sinon.spy()
            hear: sinon.spy()

        require("../src/mail")(@robot)

    it "registers a respond listener", ->
        expect(@robot.respond).to.have.been.calledWith(/mail (\S+) (.+)/i)
        expect(@robot.respond).to.have.been.calledWith(/unmail\s?(.*)/i)

    it 'registers a hear listener', ->
        expect(@robot.hear).to.have.been.calledWith(/./i)