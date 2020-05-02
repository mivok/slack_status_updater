# Slack status updater

A simple shell script to update your status in slack from the command line, based on presets you provide in a configuration file.

## Installation

Copy `slack_status.sh` to somewhere in your path.

## Setup

Before you can use this, you need to add the status updater as a new slack app. To do this:

* Go to <https://api.slack.com/apps/new> to create a new app
* Choose a name for the new app: Slack status updater
* Select your workspace from the "Development Slack Workspace" dropdown
* This will bring you to the app configuration section, choose "OAuth and Permissions"  from the sidebar on the left under the "Features" section.
* Scroll down until you see "User token scopes" and click "Add an OAuth scope"
* Type in `users.profile:write` and select it from the menu.
* Scroll back to the top and click the "Install App to Workspace" button.
* You will be brought to a screen asking you to allow the app access. Click "Allow"
* You will be taken back to a screen containing an access token starting with `xoxp-`. Click the "Copy" button to copy this to the clipboard.

Once you have the token, run `slack_status.sh setup` and follow the prompts.
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

## Helpers

### Zoom helper

There is a helper script for hammerspoon that will automatically set your
status appropriately when you are in a [zoom](https://zoom.us) meeting.

To install it:

* Install and set up the slack_status.sh script (make sure it's in your path)
* Ensure there is a 'zoom' preset (one is created by default during setup)
* Install hammerspoon (brew cask install hammerspoon) if you don't have it already.
* Copy the `zoom_detect.lua` file to ~/.hammerspoon/
* Add the following line to ~/.hammerspoon/init.lua:
  `local zoom_detect = require("zoom_detect")`

### Alfred workflow

There is an alfred workflow in [helpers/alfred](helpers/alfred) to let you
quickly update your slack status from within alfred. See the README in that
directory for more information on using it.
