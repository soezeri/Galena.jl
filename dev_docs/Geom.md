## TODO

All (most?) of these should wrap objects from `GeometryTypes`. If a shape is not available it should be implemented according to the `GeometryTypes` conventions. Geometries later inherit their position from `xy/ys(/zs)` or `points` given in `plot()`.

Possible fields/attributes:
* primitive (math representatio or mesh)
* edgecolor (default blue/black)
* facecolor (default blue)
* radius/size (default 1.0 in coordinate system / some pixels)
* offset (default 0)
* linewidth
* linestyle
* pointstyle (either using text or using primitives)

Functions:
* some Constructor with defaults
* TBD

#### 2D

* ring
* Hexagon
*

#### 2D/3D Geometries

* point
* line
* HyperSphere
* HyperCube
* HyperRectangle
* Simplex
* Arrow


#### 3D Geometries

* Torus
* Cylinder
* Octahedron?
*
* Wigner Seitz cells of lattices
