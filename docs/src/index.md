```@meta
CurrentModule = TabularMakie
```

```@eval
using CairoMakie
CairoMakie.activate!()
```

```@example tutorial
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

# TabularMakie

This is how it looks.

```@example tutorial
using TabularMakie, CairoMakie

fig = lplot(Scatter, cs_df, :xxx, :yyy; color = :s_c, marker = :g_m,  markersize = :s_m, layout_y = :g_lx)

save("fig_001.svg", fig) # hide
fig
```

Some text in the middle. And now show it again.

![fig_001](fig_001.svg)



```@index
```

```@autodocs
Modules = [TabularMakie]
```
