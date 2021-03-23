module TabularMakie

export tplot, lplot

using AbstractPlotting
using AbstractPlotting: MakieLayout
using AbstractPlotting.MakieLayout: Optional, LegendEntry, EntryGroup
# import some internal functions of AbstractPlotting
# TODO: test behavior of these functions
using AbstractPlotting: categorical_labels, categorical_range

using DataFrames
using Underscores: @_
using StructArrays
using UnPack: @unpack
using DataAPI: refarray
#using Statistics
using NamedTupleTools: delete

include("mini-language.jl")
include("attribute-dicts.jl")
include("ticks.jl")
include("plot.jl")
include("layout.jl")
include("legend-entries.jl")
include("legend-layout.jl")
include("compose.jl")

end
