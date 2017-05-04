# Alfred workflow for updating slack status

This directory contains an alfred workflow for updating your slack status
using the same presets as used by the script.

To use, first set up your config file using slack_status.sh setup and make
sure you can update your status using the slack_status.sh script.

Next, make sure you have Alfred 3 with the Powerpack upgrade, then download
and open <https://raw.githubusercontent.com/mivok/slack_status_updater/master/alfred/update_slack_status.alfredworkflow>

The keyword for the slack status udpader is 'sst', and it will autocomplete
with the presets. For example, type `sst test hello world` and it will update
your status to ':check: Testing status updater hello world'.
