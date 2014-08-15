#!/bin/sh
#
# Facter script to gather information about attached HDD S.M.A.R.T. status
# information. Sets a smart_status fact to one of the SMART status values.
# e.g. Verified, Not Supported, etc.
#


smart=""

#
# Walk each physical hard disk that is attached.
#
for d in `diskutil list | grep "/dev/disk\d$"`; do
  #
  # Get the status
  #
  status=`diskutil info $d | grep "SMART Status" | sed "s/ *SMART Status: *//"`

  #
  # If the stat is not supported, we don't care.
  #
  if [ "$status" == "Not Supported" ]; then continue; fi

  #
  # If the global smart status is not set yet, or the current status is not
  # "Verified" (good), then update the global status.
  #
  if [ "$smart" == "" -o "$status" != "Verified" ]; then
    smart="$status"
  fi
done

#
# Default value if no hard drives support SMART.
#
if [ -z "$smart" ]; then smart="Not Supported"; fi

echo "smart_status=$smart"

