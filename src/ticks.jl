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
	ticks  = categorical_range(var)  # internal function from AbstractPlotting
	labels = categorical_labels(var) # internal function from AbstractPlotting

	if ticks isa Automatic
		nothing
	else 
		ticks, labels
	end
end