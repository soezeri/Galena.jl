module Backend

using GeometryTypes, GLFW, GLAbstraction, GLWindow, GLVisualize

include("Window.jl")
export init_window, subscreen, default_plot_screen
export close!, close_all!

include("Camera.jl")

end
