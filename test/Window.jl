# Yuck
@testset "Checking screen setup" begin

using Reactive
using GeometryTypes, GLAbstraction, GLVisualize

# Get a window and the plotting screens.
# Mark them with different colors, so we can see which overwrites which

window = Backend.init_window(
    resolution = (800, 600),
    color = RGBA(0., 1., 0., 1.)
)

bg_screen = Backend.tile_screen(
    window,
    area = Signal(SimpleRectangle(10, 10, 780, 580)),
)
plot_screen, float_screen = Backend.default_plot_screen(
    bg_screen,
    plot_area = Signal(SimpleRectangle(100, 100, 600, 400))
)
bg_screen.color = RGBA{Float32}(1., 0., 0., 1.)
plot_screen.color = RGBA{Float32}(0., 0., 1., 1.)


# Get correct rotation, scale
# This will probably be redundant once we have/use our own cameras
_view(visualize(
    HyperRectangle(Vec2f0(0.), Vec2f0(1., 1.)),
    color = RGBA(0., 0., 0., 0.)
), plot_screen, camera = :orthographic_pixel)
center!(plot_screen, :orthographic_pixel)

_view(visualize(
    HyperRectangle(Vec2f0(0.), Vec2f0(1., 1.)),
    color = RGBA(0., 0., 0., 0.)
), float_screen, camera = :orthographic_pixel)
center!(float_screen, :orthographic_pixel)


# draw some stuff
# This should further show how stuff is restricted to screens.

# This should draw a black bar on the blue plot screen. It should not extend
# beyond the screen
_view(visualize(
    HyperRectangle(Vec2f0(0.4, 0.), Vec2f0(.2, 2.)),
    color = RGBA(0., 0., 0., 1.)
), plot_screen, camera = :orthographic_pixel)

# This marks the float_screen with a transparent white box. It should extend up
# to the green background of the window
_view(visualize(
    HyperRectangle(Vec2f0(-2.0), Vec2f0(4.0)),
    color = RGBA(1., 1., 1., 0.4)
), float_screen, camera = :orthographic_pixel)

# This draws some ellipsoid onto the float_screen. It should draw over everything
# except the green window area.
_view(visualize(
    [Point2f0(.5 + .8sin(x), .5 + .3cos(x)) for x in linspace(0, 2pi, 100)],
    :lines
), float_screen, camera = :orthographic_pixel)

# Isn't there a better way to wait for the last render? :(
sleep(0.1)

# Compare current render to reference
GLWindow.screenshot(window)
Backend.close!(window)

ref_img = load("ref_img/screens.png");
img = load("screenshot.png");
image_equal = ref_img == img
@test image_equal
rm("screenshot.png")
end
