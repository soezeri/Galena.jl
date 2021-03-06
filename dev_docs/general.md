#### TODO, possible Issues, implementation details

This things should be written in the respective files in `dev_docs/`.

#### Write tests for everything you implement (if possible)

Because tests are great

```julia
@test foo(bar) == expected_result
```

In order to compare graphical output, it might be good to write some code that comapres two images. GLVisualize gives functionality to save png's, for example, so a comparison would be easy to make. Should output absolute/percentage hits (or misses). May require `Images` if metadata varies in size...


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

* Most functions here should probably have a `x.y!(plot, ...)` method on top of the usual `x.y(...)` to be used in `plot(..., x.y(...))`


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

* Allows keys/mouse events or GUI elements to be bound to a variable (or object?) using Reactive. Could be used somewhat like `Geom.Sphere(r = Control.Slider(start = 0.0, stop = 1.0))`.


###### Tiling (Tile)

* Allows the user to specify a space in the window to throw the plot into.

The way subplots are generated in GG seems magical to me. I think something like this would be easy enough to implement while not interfering with the general style.
