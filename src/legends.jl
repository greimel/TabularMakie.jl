from_default_theme(attr) = AbstractPlotting.current_default_theme()[attr]

# ╔═╡ 8d939c4a-54de-11eb-1fe4-c5d87f87f62c
from_default_theme(:palette)

# ╔═╡ 22c9a76c-5423-11eb-0d0d-51d759cdc69a
line_element(; color     = :black, #default_theme(:color),
			   linestyle = nothing,
			   linewidth = 1.5,
			   kwargs...) = 
		LineElement(; color, linestyle, linewidth, kwargs...)

# ╔═╡ c3a39502-541f-11eb-2e05-73ed7d8aa794
marker_element(; color       = from_default_theme(:color),
		        marker       = from_default_theme(:marker),
			    strokecolor  = :black,
			    markerpoints = [Point2f0(0.5, 0.5)],
		        kwargs...) =
		MarkerElement( ; color, marker, strokecolor, markerpoints, kwargs...)

# ╔═╡ 1f7748c6-54eb-11eb-019f-95fd872aabff
poly_element(; color = from_default_thme(:color),
	 		   strokecolor = :transparent,
			   kwargs...) = 
		PolyElement(; color, strokecolor, kwargs...)

# ╔═╡ 1d447dba-5428-11eb-3456-d57f302600b2
legend_element(::Type{Scatter}; kwargs...) = marker_element(; kwargs...)

# ╔═╡ 36454e68-5428-11eb-2a12-d37b6e51a601
legend_element(::Type{Lines}; kwargs...) = line_element(; kwargs...)

# ╔═╡ 8756acbe-54ea-11eb-333d-4155479d1ec7
legend_element(::Type{BarPlot}; linewidth = 0, strokecolor=:green, kwargs...) = poly_element(; linewidth, kwargs...)

# ╔═╡ c5e926f6-5429-11eb-040c-4fcb7089b1b2
function legend_discrete(P, attribute, groups, title)
	
	elements = [legend_element(P; attribute => g[2]) for g in groups]
	labels = first.(groups)
	
	(; elements, labels, title)
end

# ╔═╡ da9453be-5429-11eb-2984-afc6b4eefaec
function legend_continuous(P, attribute, extrema, title, n_ticks=4)
	   	
	ticks = MakieLayout.locateticks(extrema..., n_ticks)
	elements = [legend_element(P; attribute => s) for s in ticks]
	labels = string.(ticks)
	
	(; elements, labels, title)
end

# ╔═╡ af47ed28-542a-11eb-16d5-7d28e5b508cb
function legend(P, fig, groups, styles, group_dict, style_dict)
	groups_ = collect(keys(group_dict))

	legends_grp = length(groups_) > 0 ? map(groups_) do k

		pairs = group_dict[k]
	
		legend_discrete(P, k, pairs, var_lab(groups[k]))
	end : nothing
	
	# special case colorbar
	col_extr = pop!(style_dict, :color, nothing)
	if !isnothing(col_extr)
		cb = Colorbar(fig, limits=col_extr, label = var_lab(styles[:color]))
		cb.width = 30
		cb.height = Relative(0.7)
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
		leg = Legend(fig, legends.elements, legends.labels, legends.title)
	else
		leg = nothing
	end
	
	(; leg, cb)
end

function create_entrygroups(contents::AbstractArray,
    labels::AbstractArray{String},
    title::Optional{String} = nothing)

    if length(contents) != length(labels)
        error("Number of elements not equal: $(length(contents)) content elements and $(length(labels)) labels.")
    end

    entries = [LegendEntry(label, content) for (content, label) in zip(contents, labels)]
    entrygroups = Vector{EntryGroup}([(title, entries)])
end

# ╔═╡ f5977bb8-53fd-11eb-1ac7-8ba88cda98c7
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
