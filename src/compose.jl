function tplot(P, df, args...;
			   axis_attr = (;),
			   legend_attr = (;),
			   title = nothing,               
			   attr_var_pairs...)
			   
	fig = Figure()
	
    # 1. Preparations
    spec = specification(P, df, args, attr_var_pairs)

    # 2. Figure out positions of axis and legend
	if !haskey(legend_attr, :position)
		legend_attr = (; position = :top, legend_attr...)
	end

	legend_position = legend_attr.position

	@unpack ax_pos, legs_pos = 
			outer_legend_position(fig, has_legend_or_colorbar(spec), legend_position)

	draw!(ax_pos, legs_pos, spec, attr_var_pairs; legend_attr, axis_attr)

	# 5. Add Title
	if !isnothing(title)
		Label(fig[0,:], title, tellwidth = false, tellheight = true)
	end

	(; fig)
end

function draw!(ax_pos, legs_pos, spec, attr_var_pairs; legend_attr = (;), axis_attr = (;))

	# 3. Draw Axis/Axes
	draw_axis!(ax_pos, spec, axis_attr)
	
	# 4. Draw Legend/Colorbar
	add_legend(legs_pos, spec; legend_attr...)
	
	nothing
end

function lplot(args...; kwargs...)
	@unpack fig = tplot(args...; kwargs...)
	fig
end