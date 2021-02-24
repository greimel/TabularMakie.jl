# TabularMakie

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://greimel.github.io/TabularMakie.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://greimel.github.io/TabularMakie.jl/dev)
[![Build Status](https://github.com/greimel/TabularMakie.jl/workflows/CI/badge.svg)](https://github.com/greimel/TabularMakie.jl/actions)
[![Coverage](https://codecov.io/gh/greimel/TabularMakie.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/greimel/TabularMakie.jl)

I wrote this package because I couldn't figure out how to fix some things in AlgebraOfGraphics.jl (see [#136](https://github.com/JuliaPlots/AlgebraOfGraphics.jl/issues/136)). This package might at some point become the backend for AlgebraOfGraphics.jl.

## An example
<details> <summary> Generate Data </summary>

### Generate data

```julia
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
```

</details>

```julia
using TabularMakie, CairoMakie

fig = lplot(Scatter, cs_df, :xxx, :yyy; color = :s_c, marker = :g_m,  markersize = :s_m, layout_wrap = :g_lx)
```

![](https://greimel.github.io/TabularMakie.jl/dev/fig_cs1.svg)


## What this package can do but AlgebraOfGraphics can't

* rename or transform variables on the fly (e.g. `:xxx => "name of x"` or `:yyy => ByRow(log)`)
* supports `layout_wrap` (in addition to `layout_x` and `layout_y`)
* generates legend for continuous aesthetics (e.g. markersize and linewidth)
* generates a colorbar if `color` is provided with a continuous variable
* adds a non-incremental mode for creating a plot, this allows creation of grouped bar plots
* allows access of the legend to change position and attributes

## What this package can't do but AlgebraOfGraphics can

* combine different plots (e.g. `visual(Scatter) + linear`)
* use other inputs than tables (the "slicing context")

Open an issue if you find more.
