# Description:
#   Activity-based Mail System
#
# Configuration:
#   HUBOT_MAIL_KEY
#
# Commands:
#   hubot mail <recipient> <message> - Sends a <message> to <recipient> when found available
#   hubot unmail [<recipient>] - Deletes all mail sent by you. Optionally, if <recipient> is specified, only mail sent to <recipient> by you will be deleted
#
# Author:
#   MrSaints

moment = require "moment"

#
# Config
#
MAIL_STORAGE_KEY = process.env.HUBOT_MAIL_KEY or "_mail"

module.exports = (robot) ->
    # Returns mail from the brain or an empty object if none is found
    GetMail = ->
        robot.brain.data[MAIL_STORAGE_KEY] or= {}

    # Delivers all mail belonging to a recipient in `ctx` via reply()
    # Returns nothing
    DeliverMail = (ctx) ->
        return unless ctx.message.user?.name?
        recipient = ctx.message.user.name.toLowerCase()
        if mails = GetMail()[recipient]
            response = ""
            for mail in mails
                response += "[From #{mail[0]}, #{moment.unix(mail[1]).fromNow()}] #{mail[2]} \n"
            ctx.reply response
            delete GetMail()[recipient]
            robot.brain.save()

    #
    # Hubot commands
    #
    robot.respond /unmail\s?(.*)/i, id: "mail.cancel", (res) ->
        deleted = 0

        # TODO: Detect and delete empty nodes
        DeleteByRecipient = (recipient) ->
            if mails = GetMail()[recipient.toLowerCase()]
                for mail, index in mails by -1
                    if mail[0] is res.message.user.name.toLowerCase()
                        mails.splice index, 1
                        ++deleted

        # Delete using a specified recipient
        if recipient = res.match[1]
            DeleteByRecipient recipient
            if deleted is 0
                res.reply "There are no outbound mail sent by you towards #{recipient}."
            else
                res.reply "#{deleted} of your mail(s) towards #{recipient} has been deleted."
                robot.brain.save()

        # Delete all from sender / command executor
        else
            for recipient, _mails of GetMail()
                DeleteByRecipient recipient

            if deleted is 0
                res.reply "There are no outbound mail sent by you."
            else
                res.reply "#{deleted} of your mail(s) has been deleted."
                robot.brain.save()

    robot.respond /mail (\S+) (.+)/i, id: "mail.new", (res) ->
        [_command, recipient, message] = res.match
        sender = res.message.user.name.toLowerCase()
        recipient = recipient.toLowerCase()

        if sender is recipient
            res.reply "Are you sure you want to send a mail to yourself? Sad."
        else if recipient is robot.name.toLowerCase()
            res.reply "Thanks, but no thanks! I do not need any mail."
        else
            try
                GetMail()[recipient] or= []
                GetMail()[recipient].push [sender, moment().unix(), message]
                robot.brain.save()
                res.reply "Your mail has been prepared for #{recipient}."
            catch error
                robot.logger.error "hubot-mail: #{error}"

    #
    # Hubot events
    #
    robot.enter id: "mail.enter", (res) ->
        DeliverMail res

    robot.hear /./i, id: "mail.hear", (res) ->
        DeliverMail res