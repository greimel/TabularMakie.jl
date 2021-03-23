function categorical_ticks!(ax, x, y)
	cat_xticks = categorical_ticks(x)
	cat_yticks = categorical_ticks(y)
	
	if !isnothing(cat_xticks)
		ax.xticks[] = cat_xticks
	end
	if !isnothing(cat_yticks)
		ax.yticks[] = cat_yticks
	end
	ax
end

function categorical_ticks(var)
	ticks  = AbstractPlotting.categorical_range(var) 
	labels = AbstractPlotting.categorical_labels(var)

	if ticks isa Automatic
		nothing
	else 
		ticks, labels
	end
end