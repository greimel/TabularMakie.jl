function positions_legend_attributes(fig, has_legend, has_colorbar, legend_attr)
    legend_attr = Dict(pairs(legend_attr))
    
    legend_position = pop!(legend_attr, :position, :top)
	orientation     = pop!(legend_attr, :orientation, default_orientation(legend_position))
	titleposition   = pop!(legend_attr, :titleposition, default_titleposition(orientation))
	nbanks          = pop!(legend_attr, :nbanks, default_nbanks(orientation, has_colorbar))
	framevisible   = pop!(legend_attr, :framevisible, false)
	titlevisible   = pop!(legend_attr, :titlevisible, true)

    attr = (; legend_position, orientation, titleposition, nbanks, framevisible, titlevisible)
    
    ax_pos, legpos, cbpos = positions(fig, has_legend, has_colorbar, orientation, legend_position)

    pos = (; ax_pos, legpos, cbpos)

    (; attr, positions = pos)
end

function add_legend_and_colorbar(fig, leg_contents, cb_contents, attr, positions)
    has_colorbar = !isnothing(cb_contents)
    has_legend   = !isnothing(leg_contents)

    @unpack legpos, cbpos = positions
    @unpack legend_position, orientation, titleposition, nbanks, titlevisible = attr

    if has_legend
        leg_attributes = legend_attributes(orientation, has_colorbar, titleposition, nbanks)
        add_legend(legpos, leg_contents, leg_attributes)	
    end

    if has_colorbar
        cb_attributes = colorbar_attributes(orientation)
        add_colorbar(cb_contents, cbpos, titleposition, titlevisible, has_legend, cb_attributes)
    end

    fig
end

#leg_attr = (; orientation, titlevisible, framevisible, titleposition, nbanks, legend_attr...)


# -----------------------------
# -------- L E G E N D --------
# -----------------------------

function add_legend(figpos, legend, leg_attributes)
	leg = Legend(figpos, legend...)
	adjust_attributes!(leg; leg_attributes...)
end

function legend_attributes(orientation, has_colorbar, titleposition, nbanks)
	vertical = orientation == :vertical
	horizontal = !vertical
	
	stretch_height = has_colorbar && vertical
	stretch_width  = has_colorbar && horizontal

	(; nbanks, orientation, titleposition,
	   tellwidth = vertical    || stretch_width,
	   tellheight = horizontal || stretch_height,
	   framevisible = false)
end

function adjust_attributes!(legend; attr...)
	for (a,b) in pairs(attr)
		setproperty!(legend, a, b)
	end
end	

# -----------------------------
# ------ C O L O R B A R ------
# -----------------------------

function add_colorbar(cb_contents, cbpos, titlepos, titlevisible, has_legend, cb_attributes)
	cb = Colorbar(cbpos[1,1]; cb_contents.limits, cb_attributes...)

	squeeze_label_height = titlepos == :top 
	squeeze_label_width  = cb_attributes.vertical || titlepos == :left
	
	if !isnothing(cb_contents.title) && titlevisible
		cbtitlepos = colorbar_titleposition(cbpos, titlepos, has_legend)
		Label(cbtitlepos, cb_contents.title, tellheight = squeeze_label_height, tellwidth = squeeze_label_width)
	end
end

function colorbar_titleposition(cbpos, titlepos, has_legend)
	if titlepos == :top
		cbtitlepos = cbpos[0,1]
	elseif titlepos == :left
		cbtitlepos = cbpos[1,0]
	end
end

function colorbar_attributes(orientation)
	vertical = orientation == :vertical
	horizontal = !vertical
	
	if horizontal
		cb_attributes = (height = 18, width = Relative(1.0),
			tellwidth = true,
			vertical = vertical,
			valign = :center,
			ticksize = 5,
  			ticklabelpad = 1.5)
	else
		cb_attributes = (width = 18, height = Relative(1.0),
			vertical = vertical,
			halign = :center,
	)
		
	end
end

# -----------------------------
# ------- H E L P E R S -------
# -----------------------------

function positions(fig, has_legend, has_colorbar, orientation, legend_position)
	vertical = orientation == :vertical
	
	if has_legend || has_colorbar
		if legend_position == :bottom
			ax_pos 	 = fig[1,1] 
			legs_pos = fig[2,1]
		elseif legend_position == :top
			ax_pos 	 = fig[2,1] 
			legs_pos = fig[1,1]
		elseif legend_position == :right
			ax_pos   = fig[1,1]
			legs_pos = fig[1,2]
		elseif legend_position == :left
			ax_pos   = fig[1,2]
			legs_pos = fig[1,1]
		end
		i = 1
	else
		ax_pos = fig[1,1]
	end
	
	if has_legend
		leg_pos = vertical ? legs_pos[i,1] : legs_pos[1,i]
		i += 1
	else
		leg_pos = nothing
	end
	if has_colorbar
		cb_pos = vertical ? legs_pos[i,1] : legs_pos[1,i]
	else
		cb_pos = nothing
	end
	
	(; ax_pos, leg_pos, cb_pos)
end

default_orientation(legend_position) = legend_position in [:top, :bottom] ? :horizontal : :vertical

default_nbanks(orientation, has_colorbar) = has_colorbar && (orientation == :horizontal) ? 2 : 1

default_titleposition(orientation) = orientation == :horizontal ? :left : :top