function build_group_dict(df, group_pairs)
	group_dict = Dict()
	for (attr, var) in pairs(group_pairs)
		if attr ∉ [:stack, :dodge]
			var_levels = levels(df[:,var])
			thm = AbstractPlotting.current_default_theme().palette
		
			group_dict[attr] = [var_levels[i] => thm[attr][][i] for i in 1:length(var_levels)]
		end
	end

	group_dict
end

function build_style_dict(df, style_pairs)
	style_dict = Dict()
	for (attr, var) in pairs(style_pairs)
		var_extr = extrema(df[:,var])
		
		style_dict[attr] = var_extr
	end

	style_dict
end

function group_style_other(df, dict)
	group_ = Dict()
	style_ = Dict()
	kws_   = Dict()
	
	
	for (attr, var) in pairs(dict)
		if var in propertynames(df)
			if is_discrete(df[:,var])
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
		x0 = df[:, var]
		x = is_discrete(x0) && (attr ∉ [:stack, :dodge]) ? get_marker(x0, group_dict[attr]) |> unique_or_identity : x0
		
		attr => x
	end
end