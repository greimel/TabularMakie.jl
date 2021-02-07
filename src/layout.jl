function grouped_plot_layout(P, fig, df, x_var, y_var, layout_vars, group_dict, style_dict, kws, groups, styles)
	linkxaxes  = true
	linkyaxes  = true
	linkzcolor = true
	
	@unpack grp_x, grp_y, grp_wrap = layout_vars
	
	if isnothing(grp_wrap)
		I = isnothing(grp_y) ? 1 : length(unique(df[:, grp_y]))
		J = isnothing(grp_x) ? 1 : length(unique(df[:, grp_x]))
		N = I * J
	else
		N = length(unique(df[:, grp_wrap]))
		J = ceil(Int, sqrt(N))
		I = ceil(Int, N / J)
	end

	axs = [Axis(fig) for i in 1:I, j in 1:J]
	for i in 1:I, j in 1:J
		ax = axs[i,j]
		if (i-1) * J + j > N
			hidespines!(ax)
			hidedecorations!(ax)
		end
		fig[1,1][i, j] = ax
	end
			
	grp = filter(!isnothing, collect(layout_vars))
	
	out = combine(groupby(df, grp)) do groupdf
		# Compute group key and index for layouting variables
		if !isnothing(grp_y)
			ykey = groupdf[:,grp_y] |> unique |> only
			i = groupdf[:,grp_y] |> refarray |> unique |> only |> Int
		else
			i = 1
		end
		if !isnothing(grp_x)
			xkey = groupdf[:,grp_x] |> unique |> only
			j = groupdf[:,grp_x] |> refarray |> unique |> only |> Int
		else
			j = 1
		end
		if !isnothing(grp_wrap)
			wrapkey = groupdf[:,grp_wrap] |> unique |> only
			ind = groupdf[:,grp_wrap] |> refarray |> unique |> only |> Int

			i, j = fldmod1(ind, J) 
		end
			
		# Do the plot
		plt = grouped_plot(P, axs[i, j], groupdf, group_dict, x_var, y_var, kws, groups, styles)
		
		let 
			padding = (3f0, 3f0, 3f0, 3f0)
		# Add labels for faceting
		if !isnothing(grp_wrap) 
			fig[1,1][i, j, Top()] = Box(fig, color=:lightgray)
			fig[1,1][i, j, Top()] = Label(fig, string(wrapkey); padding)
		end
		if !isnothing(grp_x) && i == 1 
			fig[1,1][1, j, Top()] = Box(fig, color=:lightgray)
			fig[1,1][1, j, Top()] = Label(fig, string(xkey); padding)
		end
		if !isnothing(grp_y) && j == 1 
	    	fig[1,1][i, 1, Right()] = Box(fig, color=:lightgray)
			fig[1,1][i, 1, Right()] = Label(fig, string(ykey); padding, rotation = -pi/2)
		end
	end
		(; plt)#, color=:red)
	end	
	
	# spanned labels
	span_label(:x, string(x_var), axs, fig[1,1])
	span_label(:y, string(y_var), axs, fig[1,1])

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
function needs_xdecorations(i,j,J,N)
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