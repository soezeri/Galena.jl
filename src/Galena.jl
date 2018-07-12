module Galena
using GeometryTypes, Colors, Quaternions
using Reactive
using GLFW, GLAbstraction, GLWindow, GLVisualize
import Compose
import GLAbstraction: makesignal
import GeometryTypes: isdecomposable, decompose, GLNormalMesh
# package code goes here
include("backend/Backend.jl")

end # module
