from __future__ import print_function
import dbus
import dbus.exceptions
import dbus.mainloop.glib
import dbus.service

import array
try:
  from gi.repository import GObject
  from gi.repository import GLib
except ImportError:
  import gobject as GObject
  import glib as GLib
import advertising
import gatt_server
import argparse


def main():
    dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
    bus = dbus.SystemBus()
    mainloop = GLib.MainLoop()

    gatt_server.gatt_server_main(mainloop, bus)
    advertising.advertising_main(mainloop, bus)
    mainloop.run()

if __name__ == '__main__':
    main()
