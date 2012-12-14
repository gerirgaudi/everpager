# OVERVIEW

*Everpager* is a Ruby library that implements the PagerDuty APIs. Additionally, it provides utilities to send PagerDuty events from Nagios (as notifications) and Splunk (as alert scripts).

# SYNOPSIS

## General

    everpager [global-options] <action> [action-options]
    
## Nagios

    notify_pagerduty [global-options] <nagios-options>

## Splunk
    splunk_alert_pagerduty

# INSTALLATION

## General

*Everpager* is distributed as a Ruby Gem:

    gem install everpager

## Nagios

Symlink to `notify_pagerduty` from the location where Nagios expects to find the `notify_pagerduty` command.

## Splunk

Symlink to `splunk_alert_pagerduty`

# GENERAL ARGUMENTS and OPTIONS

* `<action>` is one of `list`, `recovery` or `acknowledgement`
* `-D`, `--debug`: enable *debug* mode
* `-A`, `--about`: display general information about `everpager`
* `-V`, `--version`: display `everpager`'s version

# LIBRARY

To use *Everpager* as a library, you need to install the Ruby gem and then

	require ‘everpager/pagerduty’
	include Everpager::PagerDuty

This makes several classes available, including `Incidents`, `Alerts`, and `Users`. Everpager tries to hide the REST details of the original PagerDuty API, focusing instead on useful method.

Each class implements a `find` method, which accepts a `params` hash as defined by the PagerDuty API:

<table>
	<tr><th>Class</th><th>Documentation</th></th>
    <tr><td>Incidents</td><td><a href=‘http://developer.pagerduty.com/documentation/rest/incidents/list’>GET Incidents</a></td></tr>
    <tr><td>Alerts</td><td><a href=‘http://developer.pagerduty.com/documentation/rest/alerts/list'>GET Alerts</a></td></tr>
    <tr><td>Users</td><td><a href=‘http://developer.pagerduty.com/documentation/rest/users/list'>GET Users</a></td></tr>
</table>

The library includes some sensible defaults for parameters
