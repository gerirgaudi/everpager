# OVERVIEW

*Everpager* is both Ruby library that implements PagerDuty's Integration API and (work-in-progress) REST API, wrapping them under a friendlier interface, and several utities that work with PagerDuty throught a command-line interface, with with Nagios (for notifications) and Splunk (for script alerts) integration.

# SYNOPSIS

## Shell

    everpager [global-options] <action> [<collection>] [collection-options]
    
## Nagios

    notify_pagerduty [global-options] <nagios-options>

## Splunk

    splunk_alert_pagerduty_<key>

# INSTALLATION

## General

*Everpager* is distributed as a Ruby Gem:

    gem install everpager

## Nagios

Symlink to `notify_pagerduty` from the location where Nagios expects to find the `notify_pagerduty` command and configure Nagios to use. The following is a sample notification configuration:

    define command {
      command_name  pagerduty:service
      command_line  $USER3$/notify_pagerduty  -K $_CONTACT_PD_SERVICE_KEY$ -H $HOSTNAME$
                                              -I $HOSTADDRESS$ -A $HOSTALIAS$
                                              -S $SERVICEDESC$ -s $SERVICESTATE$
                                              -N $NOTIFICATIONTYPE$ "$SERVICEOUTPUT$"
    }

    define command {
      command_name  pagerduty:host
      command_line  $USER3$/notify_pagerduty -K $_CONTACT_PD_SERVICE_KEY$ -H $HOSTNAME$
                                             -I $HOSTADDRESS$ -A $HOSTALIAS$ -s $HOSTSTATE$ 
                                             -N $NOTIFICATIONTYPE$ "$HOSTOUTPUT$"
    }

## Splunk

Symlink to `splunk_alert_pagerduty`

# GENERAL ARGUMENTS and OPTIONS

* `<action>` is one of `list`, `recovery` or `acknowledgement`
* `-D`, `--debug`: enable *debug* mode
* `-A`, `--about`: display general information about `everpager`
* `-V`, `--version`: display `everpager`'s version

# GETTING HELP

*Everpager* offers help for specific options for API calls. For instance:

    gerir@boxie:~:everpager list incidents --help
    Usage: everpager [options] list <collection>

          <collection> is users,services,schedules,alerts,log_entries,incidents

          --since Date                 Start of date range (ISO8601)
          --until Date                 End of date range (ISO8601)
          --fields String              Fields (comma separated)
          --status String              Status (triggered,acknowledged,resolved)
          --incident_key String        Incident key
          --service String             Service IDs (comma separated)
          --assigned_to_user String    User IDs (comma separated)
          --sort_by String             Sort order <field>:[asc|desc]

Help for other personalities is also available:

    gerir@boxie:~:notify_pagerduty --help
    Usage: notify_pagerduty [options] <description>

    Common options:
        -K, --key KEY                    Pagerduty service/access key (required)
        -c, --appconf CONFIG             Pagerduty API keys config file
        -d, --subdomain SUBDOMAIN        Subdomain

    Nagios options:
        -H, --hostname HOSTNAME          Hostname (required)
        -a, --hostalias ALIAS            Host alias (required)
        -I, --IP-address IPADDRESS       Host IP address (required)
        -S, --service SVC_DESCR          Service description (required for service notifications)
        -s, --status STATUS              Service/Host status (ok,warning,critical,unknown)
        -N, --notification-type TYPE     Notification Type (problem,recovery,acknowledgement) (required)
                                           problem        -> trigger
                                           recovery       -> resolve
                                           acknowledgment -> acknowledge

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
