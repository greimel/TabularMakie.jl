function draw_legend!(specification)
	@unpack P, group_pairs, style_pairs, group_dict, style_dict = specification
	
	leg, cb = draw_legend!(P, group_pairs, style_pairs, group_dict, style_dict)
end

function draw_legend!(P, groups, styles, group_dict, style_dict0)
	groups_ = collect(keys(group_dict))

	legends_grp = length(group_dict) > 0 ? legends_discrete(P, groups, group_dict) : nothing
	
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

function legends_discrete(P, group_pairs, group_dict)
	group_pairs = clean_groups(group_pairs)
	
	inv_pairs = invert_pairs(pairs(group_pairs))
	
	legends = map(inv_pairs) do (var, attrs)
		subdict = filter(kv -> kv[1] in attrs, group_dict)
		nts = invert_dict_of_pairs(subdict)
		
		legend_discrete(P, var, nts)
	end |> StructArray
end

function legend_discrete(P, var, level_kws_vec)
	legend = map(level_kws_vec) do (level, kws)
		element = legend_element(P; kws...)
		(; level, element)
	end |> StructArray
	
	(elements = legend.element, labels = legend.level, title = var_lab(var))
end

function legend_continuous(P, attribute, extrema, title, n_ticks=4)
	   	
	ticks = MakieLayout.locateticks(extrema..., n_ticks)
	elements = [legend_element(P; attribute => s) for s in ticks]
	labels = string.(ticks)
	
	(; elements, labels, title)
end

from_default_theme(attr) = AbstractPlotting.current_default_theme()[attr]

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

poly_element(; color = from_default_theme(:color),
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

# Helpers
function invert_pairs(pairs) 
	pairs = pairs |> collect
	
	attrs = first.(pairs)
	vars = last.(pairs)
	
	map(unique(vars)) do var
		inds = findall(==(var), vars)	
		var => attrs[inds]
	end
end

function invert_dict_of_pairs(dict)	
	attrs = collect(keys(dict))
	
	df = mapreduce(vcat, attrs) do attr
		map(dict[attr]) do (level, characteristics)
			(; level, attr, characteristics)
		end
	end |> DataFrame 
	
	#@chain df begin
	combine(
		groupby(df, :level),
		[:attr, :characteristics] => vec_of_pairs => :kws
		) |>
	x -> NamedTuple.(eachrow(x))
	
end

vec_of_pairs(attrs, chars) = [[attr => char for (attr, char) in zip(attrs, chars)], ]

@testset "invert_pairs" begin
	nt = (color = :variable, linestyle = :variable)
	prs = pairs(nt) 
	
	inverted = [:variable => [:color, :linestyle]]
	
	@test invert_pairs(prs) == inverted
end

@testset "invert_dict_of_pairs" begin
	attr_level_char = Dict(
		:color     => ["nominal" => :orange, "real" => :blue],
		:linestyle => ["nominal" => nothing, "real" => :dash]
		)
	
	level_attr_char = [
		(level = "nominal", kws = [:color     => :orange,
								   :linestyle => nothing])
		(level = "real",    kws = [:color     => :blue,
								   :linestyle => :dash])
		]
	
	@test invert_dict_of_pairs(attr_level_char) == level_attr_char
end

function clean_groups(group_pairs)
	for key in [:group, :stack, :dodge]
		if haskey(group_pairs, key)
			group_pairs = delete(group_pairs, key)
		end
	end
	group_pairs
end
