struct Incremental end
struct AllAtOnce end

mode(::Type{Scatter}) = AllAtOnce()
mode(::Type{BarPlot}) = AllAtOnce()
mode(::Type{Lines}) = Incremental()

grouped_plot(P, args...; kwargs...) = _grouped_plot(mode(P), P, args...; kwargs...)

function _grouped_plot(::AllAtOnce, P, ax, df, group_dict, x_var, y_var, kws, group_pairs, style_pairs)
	x = get(df, x_var)
	y = get(df, y_var)
	
	pairs = lookup_symbols(df, group_pairs, style_pairs, group_dict)

	plt = plot!(P, ax, x, y; kws..., pairs...)
	
	categorical_ticks!(ax, x, y)

	(; plt)
end

function _grouped_plot(::Incremental, P, ax, gdf, group_dict, x_var, y_var, kws, group_pairs, style_pairs)
	
	if length(group_pairs) > 0
		grp = Symbol[Symbol(p[2]) for p in pairs(group_pairs)]
	else
		grp = Symbol[]
	end

	if haskey(group_pairs, :group)
		group_pairs = delete(group_pairs, :group)
	end

	out = combine(groupby(gdf, grp)) do df
		x = get(df, x_var)
		y = get(df, y_var)
		
		pairs = lookup_symbols(df, group_pairs, style_pairs, group_dict)
		
		plt = plot!(P, ax, x, y; kws..., pairs...)

		categorical_ticks!(ax, x, y)
		
		(; plt)
	end
		
	(; out.plt)
end

