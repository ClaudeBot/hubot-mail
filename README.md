# Hubot: Mail

A Hubot script for preparing messages that will be delivered upon the recipient's next activity (i.e. joins room, enters a message).


## Installation via NPM

1. Install the __hubot-mail__ module as a Hubot dependency by adding it to your `package.json` file:

    ```
    npm install --save hubot-mail
    ```

2. Enable the script by adding the __hubot-mail__ entry to your `external-scripts.json` file:

    ```json
    ["hubot-mail"]
    ```

3. Run `npm install`


## Commands

Command | Description
--- | ---
hubot mail `recipient` `message` | Sends a `message` to `recipient` when found available
hubot unmail `[recipient]` | Deletes all mail sent by you. Optionally, if `recipient` is specified, only mail sent to `recipient` by you will be deleted