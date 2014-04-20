# TimeMachine status plugin for Sal.

## Client Script

The client script is an external facter script, which means it needs to
be placed in the /etc/facter/facts.d directory for it to run properly. It
will provide a number of facts about the computer it is running on.

* timemachine_configured: 1 if TimeMachine is configured, 0 if not.
* timemachine_url: The backup URL of the first configured TimeMachine volume.
* timemachine_lastsnapshot: The date, as a unix timestamp, of the last successful backup.
* timemachine_firstsnapshot: The date, as a unix timestamp, of the first successful backup.
* timemachine_snapshotcount: The number of backups on the volume.

## Server Plugin

The server plugin provides list information to help you categorize the
following states of machines:

* TimeMachine Configured
* TimeMachine not configured
* Backed up < 7 days ago
* Backed up between 7 and 28 days ago
* Backed up > 28 days ago

## Requirements

The client script requires Facter to be installed on the clients. If you
don't already have it installed, get it installed. Provides a lot of nice
information.
