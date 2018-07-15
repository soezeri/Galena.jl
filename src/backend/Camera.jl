abstract type AbstractCamera2D{T} <: Camera{T} end

#=
# Static 2D camera

TODO
- make some system using units, like (0.3w, 0.4h) and (20px, 80px)
- does this need any controls? probably not
=#

struct ScreenCamera{T} <: AbstractCamera2D{T}
    screen_size::Signal{SimpleRectangle{Int}}

    scale::Signal{Mat4{T}}
    view::Signal{Mat4{T}}
    projection::Signal{Mat4{T}}
    projectionview::Signal{Mat4{T}}
end

"""
    ScreenCamera(screen_area)

Returns a static camera which uses the same coordinates as the screen.
"""
function ScreenCamera(screen_area::Signal{SimpleRectangle{Int}})
    # NOTE
    # view ONLY applies to the position of opengl primitives, such as rectangles
    # projection applies to all vertices
    # it seems...

    projection = scale = map(screen_area) do box
        Mat{4}(
            2f0/box.w,  0f0,        0f0,    0f0,
            0f0,        2f0/box.h,  0f0,    0f0,
            0f0,        0f0,        1f0,    0f0,
            -1f0,      -1f0,        0f0,    1f0
        )
    end
    view = Signal(eye(Mat{4, 4, Float32}))
    ScreenCamera(screen_area, scale, view, projection, map(*, projection, view))
end
ScreenCamera(screen::GLWindow.Screen) = ScreenCamera(screen.area)


################################################################################




#=
## 2D Plotting Camera

Coordinate Systems:
- absolute screen coordinates (in pixels)
- relative screen coordinates (0 to 1)
- relative plotting coordinates (0 to 1)
- absolute plotting coordinates (x_min to x_max, y_min to y_max)

Coordinate Systems in OpenGL
- model space (visualize input)
| model matrix
- world space (everything in relation to each other)
| view matrix
- view space (world viewed from a camera)
| projection matrix
- clip space (added perspective projection, 0 to 1 scale)
| viewport matrix
- screen space
see https://learnopengl.com/Getting-started/Coordinate-Systems
=#

#=
AbsolutePlottingCamera
RelativePlottingCamera
RelativeScreenCamera
AbsoluteScreenCamera
=#

#=
general stuff
struct Camera2D{T} <: GLAbstraction.Camera
    screen_area::Signal{SimpleRectangle{Int}}
        rel2abs_screen::Signal{Mat4{T}}
    rel_screen_area::Signal{SimpleRectangle{T}}
        plot2screen::Signal{Mat4{T}}
    rel_plot_area::Signal{SimpleRectangle{T}}
        abs2rel_plot::Signal{Mat4{T}}
    plot_area::Signal{SimpleRectangle{T}}

    view::Signal{Mat4{T}}
    projection::Signal{Mat4{T}}
    projectionview::Signal{Mat4{T}}

    trans_speed::Signal{Vec{3, T}}
    zoom::Signal{T}
end
=#

################################################################################

# NOTE OLD STUFF

#=
mutable struct ScreenCamera{T} <: Camera{T}
    window_size     ::Signal{SimpleRectangle{Int}}

    view            ::Signal{Mat4{T}}
    projection      ::Signal{Mat4{T}}
    projectionview  ::Signal{Mat4{T}}
end

"""
    ScreenCamera(screen_area)

Returns a static camera which uses the same coordinates as the screen.
"""
function ScreenCamera(screen_area::Signal{SimpleRectangle{Int}})
    view = Signal(eye(Mat{4, 4, Float32}))
    projection = projectionmatrix = map(screen_area) do box
        Mat{4}(
            2f0/box.w, 0f0,       0f0,  0f0,
            0f0,       2f0/box.h, 0f0,  0f0,
            0f0,       0f0,       1f0,  0f0,
            -1f0, -1f0, 0f0,  1f0
        )
    end
    ScreenCamera(screen_area, view, projection, map(*, projection, view))
end
ScreenCamera(screen::GLWindow.Screen) = ScreenCamera(screen.area)


################################################################################

# Base apce: (0, 1) x (0, 1)
# Plot space: plot_box
# screen space: screen_area
mutable struct PlottingCamera{T} <: Camera{T}
    screen_area     ::Signal{SimpleRectangle{Int}}

    view            ::Signal{Mat4{T}}
    projection      ::Signal{Mat4{T}}
    projectionview  ::Signal{Mat4{T}}

    screen_model    ::Signal{Mat4{T}}               # inverse of projectionview
    plot_model      ::Signal{Mat4{T}}

    trans_speed     ::Signal{Vec{3, T}}             # (x, y, zoom) - speed
    zoom            ::Signal{T}                     # internal (zoom multiplier)
    plot_box        ::Signal{SimpleRectangle{T}}    # region of world that can be seen
end


function PlottingCamera(
        screen::GLWindow.Screen,
        l = -10f0, b = -10f0, r = 10f0, t = 10f0;
        translation_speed = Signal(Vec3f0(1f0, 1f0, 1.1f0)),
    )

    PlottingCamera(
        screen.area,
        screen.inputs,
        translation_speed = translation_speed,
        initial_plot_box = SimpleRectangle{Float32}(l, b, r-l, t-b)
    )
end


function PlottingCamera(
        screen_area::Signal{SimpleRectangle{Int}},
        screen_inputs::Dict{Symbol, Any},
        l = -10f0, b = -10f0, r = 10f0, t = 10f0;
        translation_speed = Signal(Vec3f0(1f0, 1f0, 1.1f0))
    )

    PlottingCamera(
        screen_area,
        screen_inputs,
        translation_speed = translation_speed,
        initial_plot_box = SimpleRectangle{Float32}(l, b, r-l, t-b)
    )
end

"""
    PlottingCamera(
        screen_area::Signal{SimpleRectangle{Int}},
        screen_inputs::Dict{Sybol, Any};
        translation_speed = Signal(Vec3f0(1f0, 1f0, 1.1f0)),
        initial_plot_box = SimpleRectangle{Float32}(-10f0, -10f0, 20f0, 20f0)
    )

Sets up the world to be a stretchable, moveable canvas viewed from a static
camera. The displayed region is given by a SimpleRectangle called plot_box,
which can be interacted with by dragging and zooming.
"""
function PlottingCamera(
        screen_area::Signal{SimpleRectangle{Int}},
        screen_inputs::Dict{Symbol, Any};
        translation_speed = Signal(Vec3f0(1f0, 1f0, 1.1f0)),
        initial_plot_box = SimpleRectangle{Float32}(-10f0, -10f0, 20f0, 20f0)
    )

    # Get some Signals
    @materialize mouseposition, mouse_buttons_pressed, scroll = screen_inputs

    # Manipulate Signals:
    # mouseposition -> offsets (x, y) if left_click_down (w/ x, y ∈ (-1, 0, +1))
    # mousewheel -> rotation offset ∈ (-1, 0, +1)
    mouseposition = map(Vec2f0, mouseposition)
    left_pressed  = const_lift(
        GLAbstraction.pressed,
        mouse_buttons_pressed,
        GLFW.MOUSE_BUTTON_LEFT
    )
    # I'm suprised dragged_diff doesn't filter 0s on its own
    xytranslate = filter(
        x -> x != Vec2f0(0f0, 0f0), Vec2f0(0f0),
        GLAbstraction.dragged_diff(mouseposition, left_pressed)
    )
    # println(typeof(xytranslate))
    ztranslate = map(x -> Float32(last(x)), scroll)

    # Zoom multiplier. Usually in (1/v[3], 1, v[3])
    zoom = map((v, x) -> Float32(v[3]^x), translation_speed, ztranslate)


    # Update the plot_box to fit the currently viewed part of the world
    plot_box = foldp(initial_plot_box, xytranslate, zoom) do pbox, xy, z
        # nothing to do
        if (xy == Vec2f0(0f0)) && (z == 1f0)
            return pbox
        end

        # Intials
        x, y = pbox.x, pbox.y
        w, h = pbox.w, pbox.h

        # dragging the plot area
        if xy != Vec3f0(0f0)
            sbox = value(screen_area)
            vel = value(translation_speed)
            x += vel[1] * xy[1] * pbox.w / sbox.w
            y += vel[2] * xy[2] * pbox.h / sbox.h
        end

        # zooming
        if z != 1f0
            sbox = value(screen_area)

            # NOTE
            # This causes the xy translation to slightly desync if translation
            # and zooming happens at the same time. (Because mouseposition and
            # the offset of pbox can desync)
            mx, my = value(mouseposition)

            # (mx, my) on (0, 1) scale
            a = mx / sbox.w
            b = my / sbox.h
            # println("a, b = ", a, ", ", b)

            w *= z
            h *= z

            # x + aw = x' + aw'
            x += a * (pbox.w - w)
            y += b * (pbox.h - h)
            # println("x, y = ", x, ", ", y)
        end

        SimpleRectangle{Float32}(x, y, w, h)
    end

    # No camera motion!
    viewmatrix = Signal(eye(Mat{4, 4, Float32}))

    # scale * translation
    projectionmatrix = Signal(Mat4(
         2f0,    0f0,    0f0,    0f0,
         0f0,    2f0,    0f0,    0f0,
         0f0,    0f0,    1f0,    0f0,
        -1f0,   -1f0,    0f0,    1f0
    ))

    to_plot = map(plot_box) do box
        Mat4(
             1f0/box.w,      0f0,          0f0,  0f0,
             0f0,            1f0/box.h,    0f0,  0f0,
             0f0,            0f0,          1f0,  0f0,
            -box.x/box.w,   -box.y/box.h,  0f0,  1f0
        )
    end

    to_screen = map(screen_area) do box
        Mat4(
             1f0/box.w,      0f0,          0f0,  0f0,
             0f0,            1f0/box.h,    0f0,  0f0,
             0f0,            0f0,          1f0,  0f0,
            -box.x/box.w,   -box.y/box.h,  0f0,  1f0
        )
    end

    projectionview = map(*, projectionmatrix, viewmatrix)

    PlottingCamera{Float32}(
        screen_area,

        viewmatrix,
        projectionmatrix,
        projectionview,

        to_screen,
        to_plot,

        translation_speed,
        zoom,
        plot_box
    )
end


"""
    setRegion!(cam::PlottingCamera, xmin, ymin, xmax, ymax)

Sets the visible region to (xmin, xmax) x (ymin, ymax).
"""
function setRegion!(cam::PlottingCamera, xmin, ymin, xmax, ymax)
    @assert isfinite(xmin) "xmin has to be finite, but is $xmin"
    @assert isfinite(xmax) "xmax has to be finite, but is $xmax"
    @assert isfinite(ymin) "ymin has to be finite, but is $ymin"
    @assert isfinite(ymax) "ymax has to be finite, but is $ymax"

    region = SimpleRectangle{Float32}(xmin, ymin, xmax-xmin, ymax-ymin)
    push!(cam.plot_box, region)

    nothing
end
=#
