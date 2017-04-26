# Slack status updater

## Installation

Copy `slack_status.sh` to somewhere in your path.

## Setup

First, you need to get an api token. Go to
<https://api.slack.com/custom-integrations/legacy-tokens> and grab the token
for your team. If you don't already have a token for your team, click the
'Create token' button next to the team to get a token.

Once you have the token, run `slack_status.sh setup` and follow the prompt.
This will create a configuration file for you.

If you wish, edit the config file to add additional presets.

## Usage

* `slack_status.sh PRESET` - updates your slack status to the preset
* `slack_status.sh none` - resets your slack status to be blank
* `slack_status.sh PRESET ADDITIONAL TEXT` - any additional text you type will
  be added to the end of your slack status.

Example:

```
$ slack_status.sh test
Updating status to: :check: Testing status updater
$ slack_status.sh none
Updating status to:
$ slack_status.sh vacation
Updating status to: :hotel: On vacation
$ slack_status.sh vacation until June 15
Updating status to: :hotel: On vacation until June 15
```
