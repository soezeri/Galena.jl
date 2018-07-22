__precompile__(true)
module Galena
<<<<<<< HEAD
using GeometryTypes, Colors, Quaternions
using Reactive
using GLFW, GLAbstraction, GLWindow, GLVisualize
import Compose
import GLAbstraction: makesignal
import GeometryTypes: isdecomposable, decompose, GLNormalMesh
# package code goes here
include("backend/Backend.jl")
test 1
=======

using Reexport
using Quaternions, Reactive
@reexport using Colors
import Compose
import GLAbstraction: makesignal
import GeometryTypes: isdecomposable, decompose, GLNormalMesh

# package code goes here
include("Backend/Backend.jl")
export Backend

>>>>>>> 83806ca7b2ed1feccb6e676777fad84e40eb217d
end # module
