```@meta
CurrentModule = TabularMakie
```

```@eval
using CairoMakie
CairoMakie.activate!()
```

```@example cs
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

nothing # hide
```

```@example ts
using DataFrames, CategoricalArrays
using DataAPI: refarray

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
nothing # hide
```

# TabularMakie

This is how it looks.

```@example cs
using TabularMakie, CairoMakie

fig = lplot(Scatter, cs_df, :xxx, :yyy; color = :s_c, marker = :g_m,  markersize = :s_m, layout_y = :g_lx)

save("fig_001.svg", fig) # hide
```

![fig_001](fig_001.svg)

```@example ts
using TabularMakie, CairoMakie

fig = lplot(Lines, ts_df, :t, :v; color = :g_co, layout_x = :g_la, linestyle = :g_ls, linewidth = 2)
save("fig_ts1.svg", fig) # hide
```

![fig_ts1](fig_ts1.svg)

```@example ts
using TabularMakie, CairoMakie

fig = lplot(Lines, ts_df, :t, :v; color = :s_co, layout_y = :g_la, group = :grp )
save("fig_ts2.svg", fig) # hide
```

![fig_ts2](fig_ts2.svg)


```@index
```

```@autodocs
Modules = [TabularMakie]
```
