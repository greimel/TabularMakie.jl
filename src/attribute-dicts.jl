function specification(P, df, args, attr_var_pairs)
	dict = Dict(attr_var_pairs...)
	
	# 0. Take out some special attributes
	layout_vars = let
		grp_x    = pop!(dict, :layout_x, nothing)
		grp_y    = pop!(dict, :layout_y, nothing)
		grp_wrap = pop!(dict, :layout_wrap, nothing) 
		linkxaxes  = pop!(dict, :linkxaxes, true)
		linkyaxes  = pop!(dict, :linkyaxes, true)
		linkzcolor = pop!(dict, :linkzcolor, true)
	
		(; grp_x, grp_y, grp_wrap, linkxaxes, linkyaxes, linkzcolor)
	end
	
	# 1. Grouping	
	@unpack group_pairs, style_pairs, kws = group_style_other(df, dict)
	
	group_dict = build_group_dict(df, group_pairs)
	style_dict = build_style_dict(df, style_pairs)
	
	(; P, df, args, layout_vars, group_dict, style_dict, kws, group_pairs, style_pairs)
end

specification(P, df, args...; attr_var_pairs...) = specification(P, df, args, attr_var_pairs)

function build_group_dict(df, group_pairs)
	group_dict = Dict()
	for (attr, var) in pairs(group_pairs)
		if attr ∉ [:stack, :dodge, :group]
			var_levels = levels(get(df, var))
			thm = AbstractPlotting.current_default_theme().palette
		
			group_dict[attr] = [var_levels[i] => thm[attr][][i] for i in 1:length(var_levels)]
		end
	end

	group_dict
end

function build_style_dict(df, style_pairs)
	style_dict = Dict()
	for (attr, var) in pairs(style_pairs)
		var_extr = extrema(get(df, var))
		
		style_dict[attr] = var_extr
	end

	style_dict
end

function group_style_other(df, dict)
	group_ = Dict()
	style_ = Dict()
	kws_   = Dict()
	
	
	for (attr, var) in pairs(dict)
		if iscolumn(df, var)
			if is_discrete(get(df, var))
	  			group_[attr] = var
			else
				style_[attr] = var
			end
		else
			pop!(dict, attr)
			kws_[attr] = var
		end
	end
	
	group_pairs = (; group_...)
	style_pairs = (; style_...)
	kws   = (; kws_...)   
	
	(; group_pairs, style_pairs, kws)
end

get_marker(x, marker_dict) = last.(marker_dict)[refarray(x)]

function unique_or_identity(x)
	x_unique = unique(x)
	if length(x_unique) == 1
		return only(x_unique)
	else
		return x
	end
end

is_discrete(x) = !(eltype(x) <: Number)

"This function replaces group indicators (numbers, categories) by attributes that can be plotted (:solid, :red, etc...)"
function lookup_symbols(df, group_pairs, style_pairs, group_dict)
	group_style_pairs = (; group_pairs..., style_pairs...)
	
	map(collect(pairs(group_style_pairs))) do (attr, var)
		x0 = get(df, var)
		x = is_discrete(x0) && (attr ∉ [:stack, :dodge]) ? get_marker(x0, group_dict[attr]) |> unique_or_identity : x0
		
		attr => x
	end
end