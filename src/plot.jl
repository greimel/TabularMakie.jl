struct Incremental end
struct AllAtOnce end

mode(::Type) = Incremental()
mode(::Type{Scatter}) = AllAtOnce()
mode(::Type{BarPlot}) = AllAtOnce()

grouped_plot(P, args...; kwargs...) = _grouped_plot(mode(P), P, args...; kwargs...)

function _grouped_plot(::AllAtOnce, P, ax, df, group_dict, args, kws, group_pairs, style_pairs)
	xyz = [get(df, arg) for arg in args]
	
	pairs = lookup_symbols(df, group_pairs, style_pairs, group_dict)

	plt = plot!(P, ax, categorical_positions.(xyz)...; kws..., pairs...)
	
	categorical_ticks!(ax, xyz[1], xyz[2])

	(; plt)
end

function _grouped_plot(::Incremental, P, ax, gdf, group_dict, args, kws, group_pairs, style_pairs)
	
	
	if length(group_pairs) > 0
		grp = Symbol[Symbol(p[2]) for p in pairs(group_pairs)]
		unique!(grp)
	else
		grp = Symbol[]
	end

	if haskey(group_pairs, :group)
		group_pairs = delete(group_pairs, :group)
	end

	out = combine(groupby(gdf, grp)) do df
		xyz = [get(df, arg) for arg in args]
		
		pairs = lookup_symbols(df, group_pairs, style_pairs, group_dict)
		
		plt = plot!(P, ax, categorical_positions.(xyz)...; kws..., pairs...)

		categorical_ticks!(ax, xyz[1], xyz[2])
		
		(; plt)
	end
		
	(; out.plt)
end

