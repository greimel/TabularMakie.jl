function tplot(P, df, args...;
			   axis_attr = (;),
               legend_attr = (;),               
			   attr_var_pairs...)

	fig = Figure()
	
	# 1. Grouping	
	dict = Dict(attr_var_pairs...)

	layout_vars = let
		grp_x    = pop!(dict, :layout_x, nothing)
		grp_y    = pop!(dict, :layout_y, nothing)
		grp_wrap = pop!(dict, :layout_wrap, nothing) 
		linkxaxes  = pop!(dict, :linkxaxes, true)
		linkyaxes  = pop!(dict, :linkyaxes, true)
		linkzcolor = pop!(dict, :linkzcolor, true)
	
		(; grp_x, grp_y, grp_wrap, linkxaxes, linkyaxes, linkzcolor)
	end
	
	title = pop!(dict, :title, nothing)
	
	@unpack group_pairs, style_pairs, kws = group_style_other(df, dict)
	
	group_dict = build_group_dict(df, group_pairs)
	style_dict = build_style_dict(df, style_pairs)

	# 2. Legend	and Colorbar
	@unpack leg, cb = legend(P, group_pairs, style_pairs, group_dict, style_dict)

	# 3. Placement
	has_legend   = !isnothing(leg)
	has_colorbar = !isnothing(cb)
		
	legend_attr, positions = positions_legend_attributes(fig, has_legend, has_colorbar, legend_attr)
	add_legend_and_colorbar(fig, leg, cb, legend_attr, positions)

	# 4. Plot the collection of axes
	@unpack ax_pos = positions
	grouped_plot_layout(P, ax_pos, df, args, layout_vars, group_dict, style_dict, kws, group_pairs, style_pairs, axis_attr)
	
	# 5. Title
	if !isnothing(title)
		Label(fig[0,:], title, tellwidth = false, tellheight = true)
	end

	(; fig, leg, cb)
end

function lplot(args...; kwargs...)
	@unpack fig = tplot(args...; kwargs...)
	fig
end