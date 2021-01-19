struct Incremental end
struct AllAtOnce end

mode(::Type{Scatter}) = AllAtOnce()
mode(::Type{BarPlot}) = AllAtOnce()
mode(::Type{Lines}) = Incremental()

grouped_plot(P, args...; kwargs...) = _grouped_plot(mode(P), P, args...; kwargs...)

function _grouped_plot(::AllAtOnce, P, ax, df, group_dict, x_var, y_var, kws, group_pairs, style_pairs)
	x = df[:, x_var]
	y = df[:, y_var]
	
	pairs = lookup_symbols(df, group_pairs, style_pairs, group_dict)

	plt = plot!(P, ax, x, y; kws..., pairs...)
	
	(; plt)
end

function _grouped_plot(::Incremental, P, ax, gdf, group_dict, x_var, y_var, kws, group_pairs, style_pairs)
	
	## TODO! need correct grouping here!
	out = combine(groupby(gdf, :grp)) do df
		x = df[:, x_var]
		y = df[:, y_var]
	
		pairs = lookup_symbols(df, group_pairs, style_pairs, group_dict)
		
		plt = plot!(P, ax, x, y; kws..., pairs...)
		(; plt)
	end
		
	(; out.plt)
end

