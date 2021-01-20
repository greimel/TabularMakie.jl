function grouped_plot_layout(P, fig, df, x_var, y_var, grp_x, grp_y, group_dict, style_dict, kws, groups, styles)
	linkxaxes  = true
	linkyaxes  = true
	linkzcolor = true
	
	N_x = isnothing(grp_x) ? 1 : length(unique(df[:, grp_x]))
	N_y = isnothing(grp_y) ? 1 : length(unique(df[:, grp_y]))
	
	axs = [Axis(fig) for i in 1:N_y, j in 1:N_x]
	for i in 1:N_y, j in 1:N_x
		fig[1,1][i, j] = axs[i,j]
	end
			
	grp = Symbol[]
	isnothing(grp_x) || push!(grp, grp_x)
	isnothing(grp_y) || push!(grp, grp_y)
		
	out = combine(groupby(df, grp)) do groupdf
		# Compute group key and index for layouting variables
		if !isnothing(grp_x)
			xkey = groupdf[:,grp_x] |> unique |> only
			xind = groupdf[:,grp_x] |> refarray |> unique |> only |> Int
		else
			xind = 1
		end
		if !isnothing(grp_y)
			ykey = groupdf[:,grp_y] |> unique |> only
			yind = groupdf[:,grp_y] |> refarray |> unique |> only |> Int
		else
			yind = 1
		end
		
		# Do the plot
		plt = grouped_plot(P, axs[yind, xind], groupdf, group_dict, x_var, y_var, kws, groups, styles)
				
		# Add labels for faceting
		if !isnothing(grp_x) && yind == 1 
			fig[1,1][1, xind, Top()] = Box(fig, color=:lightgray)
			fig[1,1][1, xind, Top()] = Label(fig, string(xkey))
		end
		if !isnothing(grp_y) && xind == 1 
	    	fig[1,1][yind, 1, Right()] = Box(fig, color=:lightgray)
			fig[1,1][yind, 1, Right()] = Label(fig, string(ykey), rotation = -pi/2)
		end

		(; plt)#, color=:red)
	end	
	
	# spanned labels
	span_label(:x, string(x_var), axs, fig[1,1])
	span_label(:y, string(y_var), axs, fig[1,1])

	# Link axes
	linkyaxes && linkyaxes!(axs...)
	linkxaxes && linkxaxes!(axs...)	
	linkyaxes && hidexdecorations!.(axs[1:end-1, :], grid = false)
    linkxaxes && hideydecorations!.(axs[:, 2:end], grid = false)
	
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