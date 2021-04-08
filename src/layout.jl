function draw_axis!(ax_pos, specification, axis_attr = (;))
	@unpack P, df, args, layout_vars, group_dict, style_dict, kws, group_pairs, style_pairs = specification
	draw_axis!(P, ax_pos, df, args, layout_vars, group_dict, style_dict, kws, group_pairs, style_pairs, axis_attr)
end

function draw_axis!(P, figpos, df, args, layout_vars, group_dict, style_dict, kws, groups, styles, axis_attr)
	@unpack grp_x, grp_y, grp_wrap = layout_vars
	@unpack linkxaxes, linkyaxes, linkzcolor = layout_vars
	
	if isnothing(grp_wrap)
		I = isnothing(grp_y) ? 1 : length(unique(get(df, grp_y)))
		J = isnothing(grp_x) ? 1 : length(unique(get(df, grp_x)))
		N = I * J
	else
		N = length(unique(get(df, grp_wrap)))
		J = ceil(Int, sqrt(N))
		I = ceil(Int, N / J)
	end

	axs = [Axis(figpos[i,j]; axis_attr...) for i in 1:I, j in 1:J]
	for i in 1:I, j in 1:J
		ax = axs[i,j]
		if (i-1) * J + j > N
			hidespines!(ax)
			hidedecorations!(ax)
		end
	end
			
	grp = filter(!isnothing, collect((; grp_x, grp_y, grp_wrap)))
	
	out = combine(groupby(df, var_key.(grp))) do groupdf
		# Compute group key and index for layouting variables
		if !isnothing(grp_y)
			ykey = get(groupdf, grp_y) |> unique |> only
			i = categorical_positions(get(groupdf, grp_y)) |> unique |> only |> Int
		else
			i = 1
		end
		if !isnothing(grp_x)
			xkey = get(groupdf, grp_x) |> unique |> only
			j = categorical_positions(get(groupdf, grp_x)) |> unique |> only |> Int
		else
			j = 1
		end
		if !isnothing(grp_wrap)
			wrapkey = get(groupdf, grp_wrap) |> unique |> only
			ind = categorical_positions(get(groupdf, grp_wrap)) |> unique |> only |> Int

			i, j = fldmod1(ind, J) 
		end
			
		# Do the plot
		plt = grouped_plot(P, axs[i, j], groupdf, group_dict, args, kws, groups, styles)
		
		let 
			padding = (3f0, 3f0, 3f0, 3f0)
		# Add labels for faceting
		if !isnothing(grp_wrap) 
			Box(  figpos[i, j, Top()], color=:lightgray)
			Label(figpos[i, j, Top()], string(wrapkey); padding)
		end
		if !isnothing(grp_x) && i == 1 
			Box(  figpos[1, j, Top()], color=:lightgray)
			Label(figpos[1, j, Top()], string(xkey); padding)
		end
		if !isnothing(grp_y) && j == 1 
	    	Box(  figpos[i, end, Right()], color=:lightgray)
			Label(figpos[i, end, Right()], string(ykey); padding, rotation = -pi/2)
		end
	end
		(; plt)#, color=:red)
	end	
	
	# spanned labels
	span_label(:x, var_lab(args[1]), axs, figpos)
	span_label(:y, var_lab(args[2]), axs, figpos)

	# Link axes
	linkyaxes && linkyaxes!(axs...)
	linkxaxes && linkxaxes!(axs...)

    linkyaxes && hideydecorations!.(axs[:, 2:end], grid = false)

	if linkxaxes
		for i in 1:I, j in 1:J
			needs_deco = needs_xdecorations(i, j, J, N)
			if (i < I-1) || ((i == I-1) && !needs_deco)
				hidexdecorations!(axs[i,j], grid = false)
			end
			if (i < I) && needs_deco
				axs[i,j].alignmode = Mixed(bottom = MakieLayout.GridLayoutBase.Protrusion(0))
			end
		end
	end
	
	if linkzcolor && haskey(style_dict, :color)
		for p in out.plt
			if p.plt isa Vector
				for p_ in p.plt
					p_.colorrange = style_dict[:color]
				end
			else
				p.plt.colorrange = style_dict[:color]
			end
		end
	end
	
	# x and y labels
	#fig[1,1,Left()]   = Label(fig, string(y_var), rotation = pi/2, padding = (0,80,0,0))
	#fig[1,1,Bottom()] = Label(fig, string(x_var), padding = (0, 0, 0, 0))
	
end

# Check if there is a non-empty axis in the position just below
function needs_xdecorations(i, j, J, N)
	i * J + j > N
end

function span_label(axis, spanned_label, axs, figpos)

	positive_rotation = axis == :x ? 0f0 : π/2f0
	N_y, N_x = size(axs)
		
	itr = axis == :x ? axs[end, :] : axs[:, 1]
    group_protrusion = lift(
        (xs...) -> maximum(x -> axis == :x ? x.bottom : x.left, xs),
        (MakieLayout.protrusionsobservable(ax) for ax in itr)...
    )

    padding = lift(group_protrusion) do val
        val += 10f0
        axis == :x ? (0f0, 0f0, 0f0, val) : (0f0, val, 0f0, 0f0)
    end


    label = Label(figpos.fig, spanned_label, padding = padding, rotation = positive_rotation)
    pos = axis == :x ? (N_y, :, Bottom()) : (:, 1, Left())
    
	figpos[pos...] = label
	
end