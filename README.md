# SmokePingSurfboardProbe
A Probe for screen-scraping the SNR and Power Level stats from the Motorola SurfBoard SB5100 management interface. 

To be used in conjunction with SmokePing (https://oss.oetiker.ch/smokeping/index.en.html) and based upon the example code provided there.

# Example Configuration

## /etc/smokeping/config.d/Probes
```
  + Surfboard
  step = 10
  offset = 1%
  pings = 3
```
##  /etc/smokeping/config.d/Targets
```
  + SB
  menu = SB
  title = SB
  probe = Surfboard

  ++ SNRDown
  menu = SNRDown
  title = SNR Down
  host = 192.168.100.1
  key = SNR_Down

  ++ PLDown
  menu = PLDown
  title = Power Level Down
  host = 192.168.100.1
  key = PL_Down

  ++ PLUp
  menu = PLUp
  title = Power Level Up
  host = 192.168.100.1
  key = PL_Up

  ++ MultiGraph
  menu = Surfboard-Multi
  title = All SB Stats
  host = /SB/SNRDown /SB/PLDown /SB/PLUpstream
  key = PL_Up
```

# License
This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

