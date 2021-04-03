function draw_legend!(leg_pos, specification, legend_attr)
	@unpack P, group_pairs, style_pairs, group_dict, style_dict = specification
	
	leg, cb = draw_legend!(P, group_pairs, style_pairs, group_dict, style_dict)
end

function draw_legend!(P, groups, styles, group_dict, style_dict0)
	groups_ = collect(keys(group_dict))

	legends_grp = length(groups_) > 0 ? map(groups_) do k

		pairs = group_dict[k]
	
		legend_discrete(P, k, pairs, var_lab(groups[k]))
	end : nothing
	
	style_dict = deepcopy(style_dict0)
	# special case colorbar
	col_extr = pop!(style_dict, :color, nothing)
	if !isnothing(col_extr)
		cb = (limits = col_extr, title = var_lab(styles[:color]))
		#, width = 30, height = Relative(0.7)
	else	
		cb = nothing
	end
		
	styles_ = collect(keys(style_dict))
		
	legends_stl = map(styles_) do k
		
		extr = style_dict[k]
		
		legend_continuous(P, k, extr, var_lab(styles[k]))
	end
		
	# Combine
	legends = legends_grp
	if isnothing(legends)
		legends = legends_stl
	else
		if !isnothing(legends_stl)
			legends = [legends; legends_stl]
		end
	end
	
	if length(legends) > 0
		legends = DataFrame(legends)
		leg = (legends.elements, legends.labels, legends.title)
	else
		leg = nothing
	end
	
	(; leg, cb)
end

function legend_discrete(P, attribute, groups, title)
	
	elements = [legend_element(P; attribute => g[2]) for g in groups]
	labels = first.(groups)
	
	(; elements, labels, title)
end

function legend_continuous(P, attribute, extrema, title, n_ticks=4)
	   	
	ticks = MakieLayout.locateticks(extrema..., n_ticks)
	elements = [legend_element(P; attribute => s) for s in ticks]
	labels = string.(ticks)
	
	(; elements, labels, title)
end

from_default_theme(attr) = AbstractPlotting.current_default_theme()[attr]

from_default_theme(:palette)

line_element(; color     = :black, #default_theme(:color),
			   linestyle = nothing,
			   linewidth = 1.5,
			   kwargs...) = 
		LineElement(; color, linestyle, linewidth, kwargs...)

marker_element(; color       = from_default_theme(:color),
		        marker       = from_default_theme(:marker),
			    strokecolor  = :black,
			    markerpoints = [Point2f0(0.5, 0.5)],
		        kwargs...) =
		MarkerElement( ; color, marker, strokecolor, markerpoints, kwargs...)

poly_element(; color = from_default_thme(:color),
	 		   strokecolor = :transparent,
			   kwargs...) = 
		PolyElement(; color, strokecolor, kwargs...)

legend_element(::Type{Scatter}; kwargs...) = marker_element(; kwargs...)

legend_element(::Type{Lines}; kwargs...) = line_element(; kwargs...)

legend_element(::Type{BarPlot}; linewidth = 0, strokecolor=:green, kwargs...) = poly_element(; linewidth, kwargs...)

function create_entrygroups(contents::AbstractArray,
    labels::AbstractArray{String},
    title::Optional{String} = nothing)

    if length(contents) != length(labels)
        error("Number of elements not equal: $(length(contents)) content elements and $(length(labels)) labels.")
    end

    entries = [LegendEntry(label, content) for (content, label) in zip(contents, labels)]
    entrygroups = Vector{EntryGroup}([(title, entries)])
end

function create_entrygroups(contentgroups::AbstractArray{<:AbstractArray},
    labelgroups::AbstractArray{<:AbstractArray},
    titles::AbstractArray{<:Optional{String}})

    if !(length(titles) == length(contentgroups) == length(labelgroups))
    error("Number of elements not equal: $(length(titles)) titles,     $(length(contentgroups)) content groups and $(length(labelgroups)) label     groups.")
    end

    entries = [[LegendEntry(l, pg) for (l, pg) in zip(labelgroup, contentgroup)]
        for (labelgroup, contentgroup) in zip(labelgroups, contentgroups)]

    entrygroups = Vector{EntryGroup}([(t, en) for (t, en) in zip(titles, entries)])
end
