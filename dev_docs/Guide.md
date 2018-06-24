## TODO

###### Axes

* contains x, y(, z)-Axis

###### Axis

* consist of (ticks, labels, lines ending in arrows)
* static size/BoundingBox

###### Ticks

* static size (relative (to window size) or absolute)
* number of ticks can be static or dynamic (1)
* dynamic values (e.g. x values) (1)
  * (future) they should snap to "nice" values (not 1.23857, 1.47352, but 1.24, 1.47)

Notes:
* (1) Should be calculated when called from backend.

###### Labels

* static fontsize, font, color
* static or dynamic text (and therefore static size)
* static or dynamic position (with above static BoundingBox)
