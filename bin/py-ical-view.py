#!/usr/bin/env python

import StringIO
import sys
import vobject


def get_value(event, key):
    return tostr(event.__getattr__(key))


def tostr(key):
    return key.value.encode('utf-8')


data = sys.stdin.read()
inv = vobject.readOne(StringIO.StringIO(data), ignoreUnreadable=True)
event = inv.vevent

print("Organizer: " + get_value(event, "organizer"))
print("Event: " + get_value(event, "summary"))
print("Starts: " + str(event.dtstart.value))
print("Ends: " + str(event.dtend.value))
print("Attendees:")
for attendee in event.attendee_list:
    print(" - " + tostr(attendee))
print("Location: " + get_value(event, "location"))
print("Description: " + get_value(event, "description"))
