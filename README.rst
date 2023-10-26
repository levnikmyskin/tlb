TLB - TLP, but it's actually just battery thresholds
========================================
This is a fork of `TLP <https://linrunner.de/tlp>`_, with the only goal of providing exclusively TLP Battery module.

A slightly more detailed README is coming soon.

Why?
----
Because the only thing I needed from TLP was the battery module. For everything else I use powertop + power profiles daemon.
If you need this too, feel free to use it.

Documentation
-------------
Coming soon 

Installation
------------
``sudo make install && sudo make install-man``

Settings
--------
Coming soon, but basically same as TLP conf. Put it in ``/etc/tlb.conf``. Of course, only battery-related stuff is going to work (thresholds).
