### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 1cb400e6-68ca-11eb-287e-75c3fb94873f
begin
	using Pkg
	Pkg.activate(temp = true)
	Pkg.add(PackageSpec(name = "DataAPI", version = "1.4"))
	Pkg.add(PackageSpec(url = "https://github.com/greimel/AbstractPlotting.jl", rev = "bar-rebased"))
	Pkg.add(["Revise", "CairoMakie", "DataFrames", "CategoricalArrays", "PooledArrays"])
	Pkg.add("PlutoUI")
	
	Pkg.develop("TabularMakie")
	
	using Revise, CairoMakie, DataFrames, CategoricalArrays, PooledArrays
	using DataAPI: DataAPI, refarray
	using TabularMakie
	using PlutoUI
	
	Base.show(io::IO, ::MIME"text/html", x::CategoricalArrays.CategoricalValue) = print(io, get(x))
end

# ╔═╡ b3ba674a-76bd-11eb-3a9a-f3583c9b7d94
using Random: shuffle

# ╔═╡ 6588b3e6-6941-11eb-198a-15e00c20cb5a
md"""
# Some Examples
"""

# ╔═╡ 904fef48-76be-11eb-26b4-fb433306bc3f
md"""
## Categorical axes
"""

# ╔═╡ 9cfe05a6-76be-11eb-06ed-a92dc0e547c4
md"""
## Grouped bar
"""

# ╔═╡ a4051f48-6952-11eb-036e-37b3de9c37c2
md"""
## Rename and transform variables on the fly
"""

# ╔═╡ 6cf5fce8-6941-11eb-24f1-6d4281735519
rec_1(x) = recode!(x, "m 1" => "Nice name", "m 2" => "Other")

# ╔═╡ 5281fcf6-6946-11eb-34b9-79d05e3ec288
rec_2(x) = recode!(x, "lx 1" => "Panel 1")

# ╔═╡ 1a656cf2-694a-11eb-1c4f-edf4c99c3edc
minus1(x) = x .- 1

# ╔═╡ 2fec9ae6-76c4-11eb-35cd-c5c79181ed02
md"""
## Band
"""

# ╔═╡ 365c077a-76c4-11eb-14d1-47bcb751896c
let
	df = DataFrame(
		x = 1:10, lo = rand(10), up = 5 .+ rand(10)
	)
	lplot(Band, df, :x, :lo => "nice y label", :up)
end

# ╔═╡ 69854f4e-6952-11eb-28c5-6dcf989a98f4
md"""
# Appendix
"""

# ╔═╡ 8672add8-6952-11eb-195e-4133c66f1e07
md"""
## Package environment
"""

# ╔═╡ 9bee489c-694e-11eb-3d8f-735277e3db10
md"""
## Generate some data
"""

# ╔═╡ 346fba94-6950-11eb-0c18-43cb90d135b8
ts_df = let
	g_la = ["lay 1", "lay 2"]
	g_co = ["c 1", "c 2"]
	g_ls = ["ls 1", "ls 2", "ls 3"]

	ts_df = DataFrame(Iterators.product(g_la, g_co, g_ls))

	grps = [:g_la, :g_co, :g_ls]

	rename!(ts_df, grps)
	transform!(ts_df, grps .=> categorical, renamecols = false)

	transform!(ts_df, :g_co => (x -> refarray(x) .+ rand.())  => :s_co)
	transform!(ts_df, :s_co => ByRow(float) => :s_co)

	ts_df[:,:grp] = 1:size(ts_df, 1) |> categorical

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

# ╔═╡ 45624846-6950-11eb-1d56-35b025fbbaa4
fig = lplot(Lines, ts_df, :t, :v; color = :g_co, layout_x = :g_la, linestyle = :g_ls, linewidth = 2)

# ╔═╡ 47184b9e-68ca-11eb-2595-3b8b241a2b9f
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

# ╔═╡ 831aa510-6947-11eb-3694-21c2defdbaef
out0 = lplot(Scatter, cs_df,
	:xxx,
	:yyy;
	color = :s_c,
	marker = :g_m,
	markersize = :s_m,
	layout_wrap = :g_lx,
	
)

# ╔═╡ 4e1fd39c-68cc-11eb-3c84-b3127a09c2a2
out = lplot(Scatter, cs_df,
	:xxx => minus1,
	:yyy => ByRow(x -> x + 1) => "the y plus one";
	color = :s_c => "hey there",
	marker = :g_m => rec_1 => "bla",
	markersize = :s_m => :tada,
	layout_wrap = :g_lx => rec_2	
  )

# ╔═╡ 5c5a8fe8-76bd-11eb-234c-09a056b0c256


# ╔═╡ 07ce7300-76b5-11eb-3132-2bea7add28e1
cat_df = DataFrame(
	x = rand(["a", "b", "c"], 100) |> categorical,
	y = rand(100)
	)

# ╔═╡ 8030ddc6-76b5-11eb-030d-b79fd57b5a6f
out_ = lplot(Scatter, cat_df, :x, :y)

# ╔═╡ 96075d2a-76bd-11eb-2d9d-31333dd2f2fd
bar_df = let
	n_dodge = 2
	n_x = 3
	n_stack = 5
	n = n_dodge * n_x * n_stack
	
	grp_dodge = ["dodge $i" for i in 1:n_dodge] |> categorical
	grp_x     = ["x $i"     for i in 1: n_x] |> categorical
	grp_stack = ["stack $i" for i in 1:n_stack] |> categorical
	
	df = Iterators.product(grp_dodge, grp_x, grp_stack) |> DataFrame
	cols = [:grp_dodge, :grp_x, :grp_stack]
	rename!(df, cols)
	transform!(df, cols .=> categorical .=> cols)
	
	cols_i = cols .|> string .|> x -> x[5:end]  .|> x -> x * "_i"
	transform!(df, cols .=> (x -> Int.(x.refs)) .=> cols_i)
	
	df[:,:y] = rand(n)
	#shuffle
	df = DataFrame(shuffle(eachrow(df)))
	df
end

# ╔═╡ c92db4ce-76bd-11eb-0d6f-d55846f72e5b
lplot(BarPlot, bar_df, :grp_x => "nice name for x", :y, stack = :grp_stack, dodge = :grp_dodge, color = :grp_stack)

# ╔═╡ 1eff7f5a-76c0-11eb-247c-9bc3836564ed
lplot(BarPlot, filter(:grp_stack => ==("stack 1"), bar_df), :grp_x, :y => ByRow(log), dodge = :grp_dodge, color = :grp_dodge)

# ╔═╡ 911d9356-6952-11eb-1712-bd37da0cba85
TableOfContents()

# ╔═╡ Cell order:
# ╟─6588b3e6-6941-11eb-198a-15e00c20cb5a
# ╟─831aa510-6947-11eb-3694-21c2defdbaef
# ╠═45624846-6950-11eb-1d56-35b025fbbaa4
# ╟─904fef48-76be-11eb-26b4-fb433306bc3f
# ╠═8030ddc6-76b5-11eb-030d-b79fd57b5a6f
# ╟─9cfe05a6-76be-11eb-06ed-a92dc0e547c4
# ╠═c92db4ce-76bd-11eb-0d6f-d55846f72e5b
# ╠═1eff7f5a-76c0-11eb-247c-9bc3836564ed
# ╟─a4051f48-6952-11eb-036e-37b3de9c37c2
# ╠═6cf5fce8-6941-11eb-24f1-6d4281735519
# ╠═5281fcf6-6946-11eb-34b9-79d05e3ec288
# ╠═1a656cf2-694a-11eb-1c4f-edf4c99c3edc
# ╠═4e1fd39c-68cc-11eb-3c84-b3127a09c2a2
# ╟─2fec9ae6-76c4-11eb-35cd-c5c79181ed02
# ╠═365c077a-76c4-11eb-14d1-47bcb751896c
# ╟─69854f4e-6952-11eb-28c5-6dcf989a98f4
# ╟─8672add8-6952-11eb-195e-4133c66f1e07
# ╠═1cb400e6-68ca-11eb-287e-75c3fb94873f
# ╟─9bee489c-694e-11eb-3d8f-735277e3db10
# ╠═346fba94-6950-11eb-0c18-43cb90d135b8
# ╠═47184b9e-68ca-11eb-2595-3b8b241a2b9f
# ╠═5c5a8fe8-76bd-11eb-234c-09a056b0c256
# ╠═07ce7300-76b5-11eb-3132-2bea7add28e1
# ╠═b3ba674a-76bd-11eb-3a9a-f3583c9b7d94
# ╠═96075d2a-76bd-11eb-2d9d-31333dd2f2fd
# ╠═911d9356-6952-11eb-1712-bd37da0cba85
