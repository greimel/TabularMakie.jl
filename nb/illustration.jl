### A Pluto.jl notebook ###
# v0.12.18

using Markdown
using InteractiveUtils

# ╔═╡ da555184-53f0-11eb-3d52-378fc5a3ae93
begin		
	using Pkg
	Pkg.activate(temp=true)
	Pkg.add(PackageSpec(url="https://github.com/greimel/AbstractPlotting.jl", rev="groupedbar"))
	Pkg.add(["WGLMakie", "CairoMakie", "DataFrames", "Underscores", "StructArrays", "PlutoUI", "UnPack"])
	using CairoMakie
	using DataFrames
	using Underscores
	using StructArrays
	using PlutoUI
	using UnPack
	
	PlutoUI.TableOfContents()
end

# ╔═╡ b0c82e12-53f1-11eb-312d-f9f72999b859
using DataAPI: refarray

# ╔═╡ 027d88ba-53f2-11eb-15c8-45e085a25935
using Statistics

# ╔═╡ faeea8de-53fd-11eb-232a-4b21cf8bb26a
using CairoMakie.AbstractPlotting.MakieLayout: Optional, LegendEntry, EntryGroup

# ╔═╡ c1f8092e-53f0-11eb-188c-8bdfb5f9360a
md"Another makie test"

# ╔═╡ 9308ddfa-53fa-11eb-2c57-3bd9641444bb
md"
# Examples
"

# ╔═╡ c047e80e-54e7-11eb-22b4-9d3613c9b384
md"
## Grouped bar
"

# ╔═╡ 27eaab58-54ce-11eb-3bc9-896396439f4c
md"
## Lines
"

# ╔═╡ 0cc56bac-5416-11eb-2703-4729c84f25a6
md"
## Scatter
"

# ╔═╡ 78725f92-542d-11eb-07f2-9b2d1263229a
md"
# Test data
"

# ╔═╡ b65fdcd0-541b-11eb-1601-db104fc8c3a5
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
		

# ╔═╡ c90ef7ca-54e7-11eb-2ae4-19c05cac55fd
bar_df = let
	n_dodge = 2
	n_x = 3
	n_stack = 5
	n = n_dodge * n_x * n_stack
	
	grp_dodge = ["dodge $i" for i in 1:n_dodge]
	grp_x     = ["x $i"     for i in 1: n_x]
	grp_stack = ["stack $i" for i in 1:n_stack]
	
	df = Iterators.product(grp_dodge, grp_x, grp_stack) |> DataFrame
	cols = [:grp_dodge, :grp_x, :grp_stack]
	rename!(df, cols)
	transform!(df, cols .=> categorical .=> cols)
	
	cols_i = cols .|> string .|> x -> x[5:end]  .|> x -> x * "_i"
	transform!(df, cols .=> (x -> Int.(x.refs)) .=> cols_i)
	
	df[:,:y] = rand(n)
	#shuffle
	#df = DataFrame(shuffle(eachrow(df)))
	df_long = [df; df]
	df_long[:, :g_la] = [fill("a", n); fill("b", n)] |> categorical
	df_long
end

# ╔═╡ 3f616bd4-54ce-11eb-269a-efb59e6ed7df
ts_df = let
	g_la = ["lay 1", "lay 2"]
	g_co = ["c 1", "c 2"]
	g_ls = ["ls 1", "ls 2", "ls 3"]
	
	ts_df = DataFrame(Iterators.product(g_la, g_co, g_ls))
	
	grps = [:g_la, :g_co, :g_ls]
	
	rename!(ts_df, grps)
	transform!(ts_df, grps .=> categorical, renamecols = false)
	
	transform!(ts_df, :g_co => refarray => :s_co)
	transform!(ts_df, :s_co => ByRow(float) => :s_co)
	
	ts_df[:,:grp] = 1:size(ts_df, 1)
	
	function rw_nt(T)
		function(i)
			rw = cumsum(randn(T))
		
			DataFrame([(t = t, v = v, grp = i) for (t, v) in enumerate(rw)])
		end
	end
	
	T = 100
	
	combine(groupby(ts_df, [grps; :s_co])) do sdf
		grp = sdf.grp[1]
		
		rw_nt(T)(grp)
	end
	
	
end

# ╔═╡ 10ba2efc-5428-11eb-0b4b-75c0c26ced8d
md"
# Description of the pipeline

1. Group data
   * discrete variables: `group_dict` with color, marker, etc
   * continuous variables: `style dict` with extrema

2. Create plots using colors, markers, etc from (1)

3. Create legends using colors, markers, etc from (1)
"

# ╔═╡ e57963c6-5428-11eb-001d-6f460b560b44
md"
## 1. Preparation: group data and transform them to plottable objects

### Documentation
"

# ╔═╡ f09286ae-54f6-11eb-04bf-3b3d192c95bb
md"
We start from 
```julia
Dict(
	:markersize => :s_m, # continuous style
	:color => :g_m,		 # discrete group with legend entry
	:layout_x = :g_la,	 # discrete group without legend entry
	:strokewidth = 1     # other attribute that is just passed through
)
```

First `layout_*` are removed in the plot functions. The rest is split into
`group_pairs`, `style_pairs`, `kws` by the function `group_style_other`.
"

# ╔═╡ 2247a688-54f8-11eb-1ee6-fdc8e5681af8
md"""
Then the `group_pairs` are transformed into dictionaries, where each level is mapped to a plottable attribute. E.g.

```julia
:color => Dict("c1" => :orange, "c2" => :blue, ...)
```
"""

# ╔═╡ d305737e-54f8-11eb-19ec-3d4229ec1cec
md"""
Then the `style_pairs` are transformed into a dictionary. This dictionary holds the extrema of each variable. eg.

```julia
Dict(:markersize => (5, 13), :zcolor => (1.18, 4.91), ...)
```

These are only needed for the legends and color bars.
"""

# ╔═╡ 422bd3a0-54fa-11eb-36d5-8de30832fdc8
md"
Finally, call `lookup_symbols` to look up the variables from the `DataFrame` and create a plottable kw dictionary.
"

# ╔═╡ f2b0207e-54f9-11eb-3629-77443b6c27f8
md"
### Functions
"

# ╔═╡ 614ca946-541c-11eb-23e9-2d4875cfa9db


# ╔═╡ d590ed42-542d-11eb-0cfc-2fab5053e17f
md"
## 2. Plot

If `layout_x`, `layout_y` or `layout_wrap` is provided, the data are grouped based on the layout group variables. Each group corresponds to one `Axis`.

Depending on the plot type, there are two modes for filling an `Axis`.

### Mode 1: All at once

Some plots, like a grouped bar plot, need all information be present at the creation of the plot.

```julia
figpos = fig[i,j]

ax, plt = plot(Bar, figpos, ...)
```

### Mode 2: Incremental

Some plots, like `Lines` takes just one object (here: line) at once. So we need something like

```julia
figpos = fig[1,1]

ax = figpos = Axis(fig)
for ...
	lines!(ax, ...)
end
```

Note: other plot types don't care about the mode.
"

# ╔═╡ babf539c-54d6-11eb-2c2d-9d1afed2a8c7


# ╔═╡ 2a1a3038-5430-11eb-1e9d-6d45c7cd4b98

# ╔═╡ 46362dd6-54bb-11eb-2324-5be940ea2340

# ╔═╡ 76fd8cd4-54bb-11eb-17e5-13d5f5731a82
test_out = let
	test_dict = Dict(:markersize => :s_m, :marker => :g_m, :color => :g_c, :zcolor => :s_c)
	group_style_other(cs_df, test_dict)
end

# ╔═╡ 4e77fca8-54f8-11eb-25d7-6da0205ea628
let
	group_pairs = test_out.group_pairs
	style_pairs = test_out.style_pairs
	
	group_dict = build_group_dict(cs_df, group_pairs)
end

# ╔═╡ e5209082-54f8-11eb-0818-3d152675485f
let
	style_pairs = test_out.style_pairs
	
	style_dict = build_style_dict(cs_df, style_pairs)
end

# ╔═╡ df732ab0-5431-11eb-0e0c-0567ac51bcd7


# ╔═╡ 56aba674-5785-11eb-37fb-bffe2340ff87
let 
	fig = Figure()
	axs = [Axis(fig) for i in 1:10]
	
	for i in 1:10
		fig[1,1][i, 1] = axs[i]
	end
end

# ╔═╡ 5358b1de-5789-11eb-2d21-0b236453bd1c


# ╔═╡ 92527f08-543c-11eb-2c86-f1dc66d01832


# ╔═╡ 9d86e1ee-542e-11eb-2280-2921fd4d35ba


# ╔═╡ f2c73ca4-5428-11eb-2f84-9def021678a6
md"
## 3. Legends

For each group, we need 

* `elements::Vector{<:LegendElement}`
* `labels::Vector{<:AbstractString}`
* `title::AbstractString`

Colorbar is handled as a special case.
"

# ╔═╡ f19c45c2-541e-11eb-3cbb-6f5887c0316f

# ╔═╡ 4c8e6f44-54c6-11eb-1cdd-4f2c25ffff10


# ╔═╡ 462aef48-54e8-11eb-2611-cd28579fcfa3
fig= lplot(BarPlot, bar_df, :grp_x, :y; dodge = :grp_dodge, stack = 
		:grp_stack, color = :grp_stack, layout_x = :g_la)

# ╔═╡ e3ef3a86-54cf-11eb-07f0-c98b2907a0b9
lplot(Lines, ts_df, :t, :v; color = :s_co, layout_y = :g_la)

# ╔═╡ 72ee6b5e-54d4-11eb-1600-eb98c7b9532e
lplot(Lines, ts_df, :t, :v; color = :g_co, layout_x = :g_la, linestyle = :g_ls, linewidth = 2)

# ╔═╡ a2094c60-54c5-11eb-17df-75fe4138f5f3
lplot(Scatter, cs_df, :xxx, :yyy; color = :s_c, marker = :g_m,  markersize = :s_m, layout_y = :g_lx)

# ╔═╡ d5921a6a-54d1-11eb-24c6-77f7d1bcbc0a
lplot(Scatter, cs_df, :xxx, :yyy; color = :g_c)

# ╔═╡ f8855d54-54c5-11eb-2df0-93d33c9b69e2
lplot(Scatter, cs_df, :xxx, :yyy; markersize = :s_m)

# ╔═╡ a3fc837a-54c5-11eb-3814-754c9664521a
lplot(Scatter, cs_df, :xxx, :yyy; color = :g_c,  markersize = :s_m, layout_y = :g_lx)

# ╔═╡ abfb99d2-5432-11eb-3807-15b99374dc82
let
	fig, _, _ = tplot(Scatter, cs_df, :xxx, :yyy; color = :s_c, marker = :g_m, layout_y = :g_lx)
	fig
end

# ╔═╡ dd00046c-54bd-11eb-1a85-b99b13225524
let
	fig = Figure()
	group = (marker = :g_m, )
	style = (markersize = :s_m, color = :s_c)
	
	group_dict = build_group_dict(cs_df, group)
	style_dict = build_style_dict(cs_df, style)
	
	leg, cb = legend(Scatter, fig, group, style, group_dict, style_dict)
	
	fig[1,1] = leg
	
	if !isnothing(cb)
		fig[1,2] = cb
	end
	
	fig
end

# ╔═╡ 1b83c4fe-54de-11eb-07f9-0549913f3d5d
let
	fig = Figure()
	group = (; linestyle = :g_ls, )
	style = (; color = :s_co)
	
	group_dict = build_group_dict(ts_df, group)
	style_dict = build_style_dict(ts_df, style)

	leg, cb = nothing, nothing
	leg, cb = legend(Lines, fig, group, style, group_dict, style_dict)
	
	i = 1
	if !isnothing(leg)
		fig[1,1] = leg
		i = i+1
	end
	if !isnothing(cb)
		fig[1,i] = cb
	end
	
	fig
	#group_dict
end

# ╔═╡ e47d63b0-53fd-11eb-32ea-67ac62abfbc3
md""" # Appendix
"""


# ╔═╡ Cell order:
# ╟─c1f8092e-53f0-11eb-188c-8bdfb5f9360a
# ╠═da555184-53f0-11eb-3d52-378fc5a3ae93
# ╠═b0c82e12-53f1-11eb-312d-f9f72999b859
# ╠═027d88ba-53f2-11eb-15c8-45e085a25935
# ╟─9308ddfa-53fa-11eb-2c57-3bd9641444bb
# ╟─c047e80e-54e7-11eb-22b4-9d3613c9b384
# ╠═462aef48-54e8-11eb-2611-cd28579fcfa3
# ╟─27eaab58-54ce-11eb-3bc9-896396439f4c
# ╠═e3ef3a86-54cf-11eb-07f0-c98b2907a0b9
# ╠═72ee6b5e-54d4-11eb-1600-eb98c7b9532e
# ╟─0cc56bac-5416-11eb-2703-4729c84f25a6
# ╠═a2094c60-54c5-11eb-17df-75fe4138f5f3
# ╠═d5921a6a-54d1-11eb-24c6-77f7d1bcbc0a
# ╠═f8855d54-54c5-11eb-2df0-93d33c9b69e2
# ╠═a3fc837a-54c5-11eb-3814-754c9664521a
# ╟─78725f92-542d-11eb-07f2-9b2d1263229a
# ╠═b65fdcd0-541b-11eb-1601-db104fc8c3a5
# ╠═c90ef7ca-54e7-11eb-2ae4-19c05cac55fd
# ╠═3f616bd4-54ce-11eb-269a-efb59e6ed7df
# ╟─10ba2efc-5428-11eb-0b4b-75c0c26ced8d
# ╠═4c8e6f44-54c6-11eb-1cdd-4f2c25ffff10
# ╠═703dc85c-54f5-11eb-0060-7ff7872f6834
# ╟─e57963c6-5428-11eb-001d-6f460b560b44
# ╟─f09286ae-54f6-11eb-04bf-3b3d192c95bb
# ╠═76fd8cd4-54bb-11eb-17e5-13d5f5731a82
# ╟─2247a688-54f8-11eb-1ee6-fdc8e5681af8
# ╠═4e77fca8-54f8-11eb-25d7-6da0205ea628
# ╟─d305737e-54f8-11eb-19ec-3d4229ec1cec
# ╠═e5209082-54f8-11eb-0818-3d152675485f
# ╟─422bd3a0-54fa-11eb-36d5-8de30832fdc8
# ╟─f2b0207e-54f9-11eb-3629-77443b6c27f8
# ╠═46362dd6-54bb-11eb-2324-5be940ea2340
# ╠═614ca946-541c-11eb-23e9-2d4875cfa9db
# ╠═8c8fa6fe-5425-11eb-20fd-137331c7d40e
# ╠═57715df4-5430-11eb-060f-8b0ef3c5a86f
# ╟─d590ed42-542d-11eb-0cfc-2fab5053e17f
# ╠═babf539c-54d6-11eb-2c2d-9d1afed2a8c7
# ╠═cfae1216-54d6-11eb-3677-35588376d7cd
# ╠═f8436df2-54d6-11eb-3099-6398a1a57b64
# ╠═dec7c6ca-54d6-11eb-26f8-61b61dfacf9b
# ╠═2a1a3038-5430-11eb-1e9d-6d45c7cd4b98
# ╠═df732ab0-5431-11eb-0e0c-0567ac51bcd7
# ╠═d4149a70-54dc-11eb-2624-09fe29195562
# ╠═56aba674-5785-11eb-37fb-bffe2340ff87
# ╠═5358b1de-5789-11eb-2d21-0b236453bd1c
# ╠═9d86e1ee-542e-11eb-2280-2921fd4d35ba
# ╠═2d1faab8-54d7-11eb-0671-3b6dada37d28
# ╠═92527f08-543c-11eb-2c86-f1dc66d01832
# ╠═96740386-54d7-11eb-346d-999453ec636a
# ╠═abfb99d2-5432-11eb-3807-15b99374dc82
# ╟─f2c73ca4-5428-11eb-2f84-9def021678a6
# ╠═f19c45c2-541e-11eb-3cbb-6f5887c0316f
# ╠═8d939c4a-54de-11eb-1fe4-c5d87f87f62c
# ╠═22c9a76c-5423-11eb-0d0d-51d759cdc69a
# ╠═c3a39502-541f-11eb-2e05-73ed7d8aa794
# ╠═1f7748c6-54eb-11eb-019f-95fd872aabff
# ╠═1d447dba-5428-11eb-3456-d57f302600b2
# ╠═36454e68-5428-11eb-2a12-d37b6e51a601
# ╠═8756acbe-54ea-11eb-333d-4155479d1ec7
# ╠═c5e926f6-5429-11eb-040c-4fcb7089b1b2
# ╠═da9453be-5429-11eb-2984-afc6b4eefaec
# ╠═af47ed28-542a-11eb-16d5-7d28e5b508cb
# ╠═dd00046c-54bd-11eb-1a85-b99b13225524
# ╠═1b83c4fe-54de-11eb-07f9-0549913f3d5d
# ╟─e47d63b0-53fd-11eb-32ea-67ac62abfbc3
# ╠═faeea8de-53fd-11eb-232a-4b21cf8bb26a
# ╠═ea232ce8-53fd-11eb-3066-09964938775a
# ╠═f5977bb8-53fd-11eb-1ac7-8ba88cda98c7
