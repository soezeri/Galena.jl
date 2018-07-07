# NOTE
# - What does focus do?
# - Should monitor default to something other than `nothing`?
#   * Having things pop up where you're not working could be nicer...
"""
    init_window([, name = "Galena"; kwargs...])

Creates a new window and returns it.

# Keyword Arguments
- `resolution`: The resolution or size of a window, given in pixels.
- `debugging::Bool = false`: Run window in debug mode.
- `clear::Bool = true`: If true `color` is used as the background.
- `color`: Color to be used for the background.
- `stroke = (0f0, color)`: Size and color of screen border.
- `hidden::Bool = false`: If true, hides the current render.
- `visible::Bool = true`: If false, the user will not see a window.
- `focus::Bool = false`: Don't know, seems to be focused regardless
- `fullscreen::Bool = false`: Sets the window to fullscreen
- `monitor = nothing`: Picks a monitor to create the window on. The following
are usuable
    * `::Void`: Picks the last active monitor.
    * `::Integer`: Picks from a list of monitors.
    * `::GLFW.Monitor`: Direct input.
"""
function init_window(
        window_name::String = "Galena";
        resolution = GLWindow.standard_screen_resolution(),
        debugging::Bool = false,
        clear::Bool = true,
        color = RGBA{Float32}(1,1,1,1),
        stroke = (0f0, color),
        hidden::Bool = false,
        visible::Bool = true,
        focus::Bool = false,
        fullscreen::Bool = false,
        monitor = nothing
    )
    window = GLWindow.Screen(
        window_name,
        resolution = resolution,
        debugging = debugging,
        # major = 3,
        # minor = 3,# this is what GLVisualize needs to offer all features
        # windowhints = GLWindow.standard_window_hints(),
        # opengl version?
        # contexthints = GLWindow.standard_context_hints(3, 3),#major, minor),
        # callbacks = GLWindow.standard_callbacks(),
        clear = clear,
        color = color,
        stroke = stroke,
        hidden = hidden,
        visible = visible,
        focus = focus,
        fullscreen = fullscreen,
        monitor = monitor
    )
    # Bookkeeping
    GLVisualize.add_screen(window)
    # add the drag events and such
    GLWindow.add_complex_signals!(window)
    # Make drawing happen on the new screen
    GLFW.MakeContextCurrent(GLWindow.nativewindow(window))
    # Bookkeeping?
    GLVisualize.pixel_per_mm[] = GLVisualize.get_scaled_dpi(window) / 25.4

    return window
end

# TODO
# wrap this?
# GLVisualize.cleanup()
