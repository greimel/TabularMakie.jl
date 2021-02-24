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
	rp0 = refpool(var)
	if isnothing(rp0)
		nothing
	else
		rp = pairs(rp0)
		ticks = keys(rp), values(rp)
	end
		
end