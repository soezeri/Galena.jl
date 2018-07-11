# TODO
# - rewrite screen bookeeping part, so that we can destroy all screens of one
#   window, rather than everything (see GLVisualize/../renderloop.jl)

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
        # contexthints = GLWindow.standard_context_hints(major, minor),
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
    # I don't see a reason not to start this already
    @async renderloop(window)

    return window
end


# NOTE
# - may require complex_signals?
"""
    subscreen(source_screen, subscreen_name; kwargs...)

Generates a Screen under the source_screen. By default, it will inherit the size
of the source_screen.

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
function subscreen(
        window::GLWindow.Screen,
        name::Symbol;
        area::TOrSignal{<: SimpleRectangle} = map(x -> x, window.area),
        kwargs...
    )
    screen = Screen(window, name = name, area = area; kwargs...)
    GLVisualize.add_screen(screen)
    screen
end


# I think this is all GLVisualize does, really
"""
    close!(window)

Closes any Screen under window.
"""
function close!(screen::GLWindow.Screen)
    if isempty(screen.children)
        destroy!(screen)
        return nothing
    else
        map(close!, screen.children)
        GLVisualize.clean!() # Bookkeeping
        return nothing
    end
end


# Closes every window and screen 
function close_all!()
    GLVisualize.cleanup()
end

################################################################################

# NOTE
# - this cannot be transparent
# but maybe plotting screens like this would be good:
#=
1) window -> (Axis screen -> Plot screen)
    ╔══════════════════════╗
    ║    ┌───────────────┐ ║
    ║    │               │ ║
    ║    │   plot area   │ ║
    ║    │               │ ║
    ║    └───────────────┘ ║
    ║         Axis         ║ <- window
    ╚══════════════════════╝
- Screens cannot be transparent (?) => Plot Screen may overwrite
- Labels can't float outside plot area if defined on Plot Screen
- 3D Axis are intertwined with 3D plots

2) window -> (plot screen)
    ╔══════════════════════╗                ╔══════════╦══════════╗
    ║                      ║                ║   plot   ║   plot   ║
    ║                      ║                ║   1, 1   ║   1, 2   ║
    ║      plot area       ║                ╠══════════╬══════════╣
    ║                      ║                ║   plot   ║   plot   ║
    ║                      ║ <- window      ║   2, 1   ║   2, 2   ║ <- window
    ╚══════════════════════╝                ╚══════════╩══════════╝
+ No overlap issues
+ 3D Axis are fine
- Axis, legend, text, etc might be more complex (camera setup needed)
- Some stuff should shrink the Plot Area (e.g. titles, colorbars, Axis2D, ...)

3) window -> (Blocking Screen -> Plot Screen)
    ╔═══════════════════╗
    ║ ┌───────────────┐ ║
    ║ │               │ ║
    ║ │   plot area   │ ║
    ║ │               │ ║
    ║ └───────────────┘ ║<- window
    ╚═══════════════════╝
Do a soft version of 1)
* overlap issues can be avoided
* plot area can be shrunk
+ 3D Axis are fine

  window
  ╱    ╲
Tile  Tile
 │      │
plot  plot
=#


# function init_draw_screen(
#         window::GLWindow.Screen,
#         area::TOrSignal{SimpleRectangle} = window.area
#     )
#     tile_screen = Screen(
#         window,
#         name = :tile11,
#         area = area
#     )
#     plot_screen = Screen(
#         tile_screen,
#         name = :plot11,
#         area = area
#     )
# end

# I think having a step between window.area and tile.area (and plot.area) could
# be useful. I think that enables us to modify the connections without breaking
# stuff after screen creation.
