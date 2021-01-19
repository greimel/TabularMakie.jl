#using Pkg
#Pkg.add(PackageSpec(url="https://github.com/greimel/AbstractPlotting.jl", rev="groupedbar"))

using Revise
using TabularMakie
using CairoMakie
using DataFrames, CategoricalArrays
using DataAPI: refarray

cs_df = let
	N = 100
	dummy_df = DataFrame(
		xxx = rand(N),
		yyy = rand(N),
		s_m  = rand(5:13, N),
		g_c  = rand(["c 1", "c 2", "c 3"], N) |> categorical,
		g_lx = rand(["lx 1", "lx 2", "lx 3"], N) |> categorical,
		g_m  = rand(["m 1", "m 2", "m 3"], N) |> categorical
		)
	
	dummy_df[:,:s_c] = 2 .* rand(N) .+ refarray(dummy_df.g_lx)
	dummy_df
end

lplot(Scatter, cs_df, :xxx, :yyy; color = :s_c, marker = :g_m,  markersize = :s_m, layout_y = :g_lx)
