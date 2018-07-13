module Galena

using Reexport
using Quaternions, Reactive
@reexport using Colors
import Compose
import GLAbstraction: makesignal
import GeometryTypes: isdecomposable, decompose, GLNormalMesh

# package code goes here
include("backend/Backend.jl")
export Backend

end # module
