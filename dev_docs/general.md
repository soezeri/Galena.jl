#### TODO, possible Issues, implementation details

This things should be written in the respective files in `dev_docs/`.

#### Write tests for everything you implement (if possible)

Because tests are great

```julia
@test foo(bar) == expected_result
```


#### Write doc strings for everything

Or at least everything that should be used by a user. For a Style guide refer to the julia documentation.

```julia
"""
  foo(bar)

Returns the foo of bar.
"""
function foo(bar::Bar) end
```


#### Follow julia Style

This includes being consistent with spaces, staying within 80 line length and whatnot. Also, I prefer long argument lsits to be split like this:

```julia
function foo(
    bar_list::Vector{Bar},
    start::Int64,
    stop::Int64;
    transformation::Symbol = :Identity,
    do_smoothing::Bool = true,
    kwargs...
  )
end
```

---

## Grammer of Graphics

For the most part we want to implement a Grammer of Graphics style with GLVisualize as the backend. In the Grammer of Graphics style we talk about the following objects. (Also see `Gadfly.jl`)


###### Scales (Scale)

* Scales scale the data. For example, it may create a log-scale or discretize the data.

###### Statistics (Stat)

* Statistics transform the data. For example Statistics may approximate densities, or bin the data.

###### Coordinates (Coord)

* Coordinates may set the Coordinate system to Polar or Cartesian (or other) coordinates. It may also restrict the view.

###### Guides (Guide)

* Guides control things that don't directly interact on the data, such the axes (ticks, labels), titles, legends, annotations, etc.

###### Geometries (Geom)

* Some Geometry we use to display data. Examples include `Geom.Point`, `Geom.line`, `Geom.bar`, etc. In 3D we may use Geometries to create primitives. For example `plot(points, Geom.Torus)` could create a torus at position point.



For interacting with GLVisualize we may want to implement some other objects. These are subject to change

###### Controls (Control)

* Allows key and mouse events to control all(?) the above mentioned objects.

###### Graphical User Interface (GUI)

* Allows a GUI element to be connected to a control

The problem with both of these is that they explicitly need to interact with other objects. In my opinion it doesn't make sense to implement a `Control.modify_linear_scale(params...)` for every little thing. This would be a lot of mundane work, and restrict the user to specific Controls (and connected GUI elements). A more general `Control.modify(Key_Event, scale, modification)` kind of thing would be better, but not fit the GG style.


###### Tiling (Tile)

* Allows the user to specify a space in the window to throw the plot into.

The way subplots are generated in GG seems magical to me. I think something like this would be easy enough to implement while not interfering with the general style.
