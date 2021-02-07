module TabularMakie

export tplot, lplot

using AbstractPlotting
using AbstractPlotting: MakieLayout
using AbstractPlotting.MakieLayout: Optional, LegendEntry, EntryGroup

using DataFrames
using Underscores: @_
using StructArrays
using UnPack: @unpack
using DataAPI: refarray
#using Statistics
using NamedTupleTools: delete

include("mini-language.jl")
include("attribute-dicts.jl")
include("plot.jl")
include("layout.jl")
include("legends.jl")
include("compose.jl")

end
