module TabularMakie

export tplot, lplot

using AbstractPlotting
using AbstractPlotting: MakieLayout
using AbstractPlotting.MakieLayout: Optional, LegendEntry, EntryGroup
# import some internal functions of AbstractPlotting
# TODO: test behavior of these functions

using AbstractPlotting: Automatic
include("categorical.jl")
using .CategoricalConversions: categorical_labels, categorical_range, categorical_positions, categorical_trait, Categorical, HasRefPool, Continuous

using DataFrames
using Chain: @chain
using Underscores: @_
using StructArrays
using UnPack: @unpack
#using Statistics
using NamedTupleTools: delete

using InlineTest: @testset, @test

include("mini-language.jl")
include("attribute-dicts.jl")
include("ticks.jl")
include("plot.jl")
include("layout.jl")
include("legend-entries.jl")
include("legend-layout.jl")
include("compose.jl")

end
