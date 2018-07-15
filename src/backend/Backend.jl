module Backend

using Reactive
using GeometryTypes, GLFW, GLAbstraction, GLWindow, GLVisualize

include("Window.jl")
export init_window, subscreen, default_plot_screen
export close!, close_all!

include("Camera.jl")
export ScreenCamera

end
