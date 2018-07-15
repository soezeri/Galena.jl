using Reactive
using GeometryTypes
using GLFW, GLVisualize
using GLAbstraction

@testset "Testing static ScreenCamera, basic Tiling" begin

window = Backend.init_window(
    resolution = (800, 400),
    color = RGBA(0., 1., 0., 1.)
)

# Let's also test basic (but cumbersome) tiling here
left_area = map(window.area) do box
    SimpleRectangle(
        box.x + 10,             box.y + 10,
        div(box.w, 2) - 15,     box.h - 20
    )
end
right_area = map(window.area) do box
    SimpleRectangle(
        box.x + div(box.w, 2) + 5,   box.y + 10,
        div(box.w, 2) - 15,          box.h - 20
    )
end

left_tile = Backend.tile_screen(window, area = left_area)
right_tile = Backend.tile_screen(window, area = right_area)

left_ps, left_fs = Backend.default_plot_screen(
    left_tile,
    plot_area = map(left_area) do box
        SimpleRectangle(50, 50, box.w-100, box.h-100)
    end
)
right_ps, right_fs = Backend.default_plot_screen(
    right_tile,
    plot_area = map(right_area) do box
        SimpleRectangle(50, 50, box.w-100, box.h-100)
    end
)

left_ps.color = RGBA{Float32}(0., 0., 1., 1.)
right_ps.color = RGBA{Float32}(0., 0., 1., 1.)

# With this camera changing the window size should
# - keep the size of objects the same
# - keep the absolute position of objects on the respective screen the same
window_cam = Backend.ScreenCamera(window)
left_cam = Backend.ScreenCamera(left_fs)
right_cam = Backend.ScreenCamera(right_fs)


w, h = 50, 50
rect(x, y) = SimpleRectangle(Vec2f0(x-0.5w, y-0.5h), Vec2f0(w, h))

# Plop a Rectangle in the bottom center
# This should be in the background
robj = visualize(rect(400, 0), color = RGBA(1., 1., 0., 1.))
_view(robj, window, camera = window_cam)


# Rectangles on left screen & right screen
# these should be at the front
robj = visualize(rect(50, 50), color = RGBA(1., 0., 1., 1.))
_view(robj, left_fs, camera = left_cam)
robj = visualize(rect(335, 330), color = RGBA(1., 0., 1., 1.))
_view(robj, left_fs, camera = left_cam)
robj = visualize(rect(450, 200), color = RGBA(1., 0., 1., 1.))
_view(robj, left_fs, camera = left_cam)

robj = visualize(rect(50, 50), color = RGBA(1., 0., 1., 1.))
_view(robj, right_fs, camera = right_cam)
robj = visualize(rect(335, 330), color = RGBA(1., 0., 1., 1.))
_view(robj, right_fs, camera = right_cam)
robj = visualize(rect(450, 200), color = RGBA(1., 0., 1., 1.))
_view(robj, right_fs, camera = right_cam)

# Test some other objects too
w, h = 385/2, 380/2
robj = visualize(
    HyperSphere(Point2f0(w, h), 20f0),
    color = RGBA(0., 1., 1., 1.)
)
_view(robj, left_fs, camera = left_cam)
robj = visualize(
    [Point2f0(w+40cos(x), h+20sin(2x)) for x in linspace(0, 2pi, 100)],
    :lines,
    color = RGBA(0., 1., 1., 1.)
)
_view(robj, right_fs, camera = right_cam)

# Test 1
sleep(0.1)
GLWindow.screenshot(window)

ref_img = load("ref_img/ScreenCamera.png");
img = load("screenshot.png");
image_equal = ref_img == img
@test image_equal
rm("screenshot.png")

# Test 2

# rescale screen
# the third squares should show up now
GLFW.SetWindowSize(window.glcontext.window, 1200, 600)
sleep(2/60)
GLWindow.screenshot(window)
Backend.close!(window)

ref_img = load("ref_img/ScreenCamera_scaled.png");
img = load("screenshot.png");
image_equal = ref_img == img
@test image_equal
rm("screenshot.png")

end
