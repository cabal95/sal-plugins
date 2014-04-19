This plugin provides the ability to track any disk I/O errors on client
machines. If the /var/log/system.log contains a match for the regular
expression 'disk.*: I/O error' then the facter fact diskerror will be
set to 1, otherwise it will be 0.

You must also add 'diskerror' to your HISTORICAL_FACTS setting in your
server's settings.py file.

Requirements: Facter must be installed and configured on the clients.
