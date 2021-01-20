function tplot(P, df, x_var, y_var; attr_var_pairs...)
	fig = Figure()
	
	# 1. Grouping	
	dict = Dict(attr_var_pairs...)

	layout_vars = let
		grp_x    = pop!(dict, :layout_x, nothing)
		grp_y    = pop!(dict, :layout_y, nothing)
		grp_wrap = pop!(dict, :layout_wrap, nothing) 
	
		(; grp_x, grp_y, grp_wrap)
	end
	
	@unpack group_pairs, style_pairs, kws = group_style_other(df, dict)
	
	group_dict = build_group_dict(df, group_pairs)
	style_dict = build_style_dict(df, style_pairs)
	
	# 2a. Plot
	
	# 2b. Layout
	grouped_plot_layout(P, fig, df, x_var, y_var, layout_vars, group_dict, style_dict, kws, group_pairs, style_pairs)
	
	# 3. Legend
	leg, cb = nothing, nothing
	
	@unpack leg, cb = legend(P, fig, group_pairs, style_pairs, group_dict, style_dict)
	
	# 4. Compose
	i = 1
	if !isnothing(leg)
		fig[1,2][1,i] = leg
		i = i + 1
	end
	if !isnothing(cb)
		fig[1,2][1,i] = cb
	end

	(; fig, leg, cb)
end

# ╔═╡ 703dc85c-54f5-11eb-0060-7ff7872f6834
function lplot(args...; kwargs...)
	@unpack fig = tplot(args...; kwargs...)
	fig
end