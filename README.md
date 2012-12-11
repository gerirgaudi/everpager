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
