#!/bin/sh
#
# Facter script to gather various facts about Time Machine.
# This script should be placed in the facts.d directory, which on Mac
# OS X is /etc/facter/facts.d
#

version=`sw_vers -productVersion | cut -f1-2 -d.`

# Determine if it is configured.
configured=0
if [ -e /usr/bin/tmutil ]; then
  V=`/usr/bin/tmutil destinationinfo | grep "No destinations configured"`
  if [ -z "$V" ]; then
    configured=1
  fi
fi

# Get the URL used for backups.
url=""
if [ $configured -eq 1 ]; then
  url=`tmutil destinationinfo | grep "^URL" | cut -c17- | head -n1`
fi

# Get the most recent snapshot date.
lastsnapshot=""
lastsnapshotdate=""
if [ $configured -eq 1 ]; then
  if [ "$version" = "10.6" ]; then
    lastsnapshot=0
  elif [ "$version" = "10.7" -o "$version" = "10.8" ]; then
    lastsnapshotdate=`/usr/libexec/PlistBuddy -c "Print :Destinations:0:BACKUP_COMPLETED_DATE" /Library/Preferences/com.apple.TimeMachine.plist`
    lastsnapshot=`date -j -f "%a %b %d %T %Z %Y" "$lastsnapshotdate" +%s 2>/dev/null`
  else
    lastsnapshotdate=`/usr/libexec/PlistBuddy -c "Print :Destinations:0:SnapshotDates" /Library/Preferences/com.apple.TimeMachine.plist | grep ":" | tail -n1 | sed 's/^ *//g'`
    lastsnapshot=`date -j -f "%a %b %d %T %Z %Y" "$lastsnapshotdate" +%s 2>/dev/null`
  fi
fi

# Get the oldest snapshot date.
firstsnapshot=""
firstsnapshotdate
if [ $configured -eq 1 ]; then
  if [ "$version" = "10.6" ]; then
    firstsnapshot=0
  elif [ "$version" = "10.7" -o "$version" = "10.8" ]; then
    firstsnapshotdate=`/usr/libexec/PlistBuddy -c "Print :Destinations:0:kCSBackupdOldestCompleteSnapshotDate" /Library/Preferences/com.apple.TimeMachine.plist`
    firstsnapshot=`date -j -f "%a %b %d %T %Z %Y" "$firstsnapshotdate" +%s 2>/dev/null`
  else
    firstsnapshotdate=`/usr/libexec/PlistBuddy -c "Print :Destinations:0:SnapshotDates" /Library/Preferences/com.apple.TimeMachine.plist | grep ":" | head -n1 | sed 's/^ *//g'`
    firstsnapshot=`date -j -f "%a %b %d %T %Z %Y" "$firstsnapshotdate" +%s 2>/dev/null`
  fi
fi

# Get the number of snapshots
snapshotcount="0"
if [ $configured -eq 1 ]; then
  if [ "$version" = "10.6" ]; then
    snapshotcount=0
  elif [ "$version" = "10.7" -o "$version" = "10.8" ]; then
    snapshotcount=`/usr/libexec/PlistBuddy -c "Print :Destinations:0:SnapshotCount" /Library/Preferences/com.apple.TimeMachine.plist`
  else
    snapshotcount=`/usr/libexec/PlistBuddy -c "Print :Destinations:0:SnapshotDates" /Library/Preferences/com.apple.TimeMachine.plist | grep -c ":"`
  fi
fi

echo "timemachine_configured=$configured"
echo "timemachine_url=$url"
echo "timemachine_lastsnapshot=$lastsnapshot"
echo "timemachine_firstsnapshot=$firstsnapshot"
echo "timemachine_lastsnapshotdate=$lastsnapshotdate"
echo "timemachine_firstsnapshotdate=$firstsnapshotdate"
echo "timemachine_snapshotcount=$snapshotcount"
