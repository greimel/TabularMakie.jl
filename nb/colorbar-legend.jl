### A Pluto.jl notebook ###
# v0.14.0

using Markdown
using InteractiveUtils

# ╔═╡ ea52d932-9304-11eb-0c41-4d06311308a6
begin
	using Pkg
	Pkg.activate(temp = true)
	
	Pkg.add("CairoMakie")
	
	using CairoMakie
	CairoMakie.activate!(type = "png")
end

# ╔═╡ 70c50868-5465-4b03-918b-a83c83d224c5
using PlutoUI; TableOfContents()

# ╔═╡ 528b77d3-2672-418a-b059-bdbbea41b54f
md"""
## Default attributes
"""

# ╔═╡ 38df7208-a6ab-4824-acc7-42c5f22f970a
default_orientation(legend_position) = legend_position in [:top, :bottom] ? :horizontal : :vertical

# ╔═╡ 0e38adf6-8853-43a7-b44e-1df517ed8bd2
default_nbanks(orientation, has_colorbar) = has_colorbar && (orientation == :horizontal) ? 2 : 1

# ╔═╡ 172b31a8-d853-4f64-a89c-9e61129b3455
default_titleposition(orientation) = orientation == :horizontal ? :left : :top

# ╔═╡ 59723752-2d54-4b8f-b55a-02f165fc2b6c
md"""
## Compose
"""

# ╔═╡ 0986d286-af46-4373-937f-3f73b28430f3
md"""
## Test plots
"""

# ╔═╡ 25912b01-7a74-44cc-9336-e50ccc84edb8
function positions(fig, has_legend, has_colorbar, vertical, legend_position)
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

# ╔═╡ 276a78cc-7a76-4901-a3ea-edcf60bb7d3b
function make_legend(fig, legend_title, n = 2)
	markersizes = [5, 10, 15, 20]

	group_size = [MarkerElement(marker = :circle, color = :black, strokecolor = :transparent,
    	markersize = ms) for ms in markersizes]
	
	legend = Legend(fig,
    	fill(group_size, n),
    	fill(string.(markersizes), n),
    	fill(legend_title, n)
	)
end

# ╔═╡ 8d63a603-6ed6-4d9c-8c50-19c7535324b7
function adjust_attributes!(legend; attr...)
	for (a,b) in pairs(attr)
		setproperty!(legend, a, b)
	end
end	

# ╔═╡ 4dacaaee-05eb-488e-857b-9c7b95b6c181
md"""
## Legend
"""

# ╔═╡ 46084f3f-844b-4b62-9fe5-812ca917236e
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

# ╔═╡ b5318ac4-91f2-44ab-b6ea-f12a63fe68de
md"""
## Colorbar
"""

# ╔═╡ 72c5cdcf-d6ee-435b-b018-dbb2755be00c
function colorbar_titleposition(cbpos, titlepos, has_legend)
	if titlepos == :top
		cbtitlepos = cbpos[0,1]
	elseif titlepos == :left
		cbtitlepos = cbpos[1,0]
	end
end

# ╔═╡ 711d8f7a-16fd-42ab-9e7a-c3c91f76fe1e
function add_colorbar(colorbar, cbpos, titlepos, has_legend, cb_attributes)
	cb = Colorbar(cbpos[1,1]; colorbar.kwargs..., cb_attributes...)

	squeeze_label_height = titlepos == :top 
	squeeze_label_width  = titlepos == :left
	
	if !isnothing(colorbar.title)
		cbtitlepos = colorbar_titleposition(cbpos, titlepos, has_legend)


		Label(cbtitlepos, colorbar.title, tellheight = squeeze_label_height, tellwidth = squeeze_label_width)
	end
end

# ╔═╡ f0fbd3f9-7e44-4e76-9c5e-f5347863cf8c
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
			halign = :left,
	)
		
	end
end


# ╔═╡ d9cc8536-9304-11eb-1a23-dd648f1d3ef7
function add_legend_and_colorbar(fig, legend_title, colorbar;
		legend_position = :top,
		orientation = default_orientation(legend_position),
		titleposition =  default_titleposition(orientation),
		nbanks = default_nbanks(orientation, !isnothing(colorbar))
		)
	
	has_colorbar = !isnothing(colorbar)
	has_legend = true
	
	vertical = orientation == :vertical

	ax_pos, legpos, cbpos = positions(fig, has_legend, has_colorbar, vertical, legend_position)

	ax = Axis(ax_pos)

	if has_legend
		legend = make_legend(legpos, legend_title)
		leg_attributes = legend_attributes(orientation, has_colorbar, titleposition, nbanks)
		adjust_attributes!(legend; leg_attributes...)	
	end

	if has_colorbar
		cb_attributes = colorbar_attributes(orientation)
		add_colorbar(colorbar, cbpos, titleposition, has_legend, cb_attributes)
	end
	
	fig
end

# ╔═╡ edd7503c-ef60-4bd6-8b2a-1f0c517216a7
function test(legend_title, colorbar_title; kwargs...
		)
	
	my_colorbar = (args = (),
			  kwargs = (limits = (-1, 1), ),
			  title = "nice title")	


	fig = Figure()
		
	add_legend_and_colorbar(fig, legend_title, my_colorbar; kwargs...)
		
	
end

# ╔═╡ 0303e9a8-9305-11eb-0737-c187ab85885b
test("bla bla", "bla", legend_position = :bottom)

# ╔═╡ 0b209f44-d7c1-424d-8fa1-0d5a46657058
test("bla bla", "bla", legend_position = :top, titleposition = :top)

# ╔═╡ 390a3394-63e9-479d-bd54-fa5088d16abb
test("bla bla", "bla", legend_position = :right, nbanks = 2)

# ╔═╡ d0ca4cf2-96f5-4d48-90d6-62909628a6ee
test("bla bla", "bla",  legend_position = :left, titleposition = :left)

# ╔═╡ Cell order:
# ╠═ea52d932-9304-11eb-0c41-4d06311308a6
# ╠═edd7503c-ef60-4bd6-8b2a-1f0c517216a7
# ╟─528b77d3-2672-418a-b059-bdbbea41b54f
# ╠═38df7208-a6ab-4824-acc7-42c5f22f970a
# ╠═0e38adf6-8853-43a7-b44e-1df517ed8bd2
# ╠═172b31a8-d853-4f64-a89c-9e61129b3455
# ╟─59723752-2d54-4b8f-b55a-02f165fc2b6c
# ╠═d9cc8536-9304-11eb-1a23-dd648f1d3ef7
# ╟─0986d286-af46-4373-937f-3f73b28430f3
# ╠═0303e9a8-9305-11eb-0737-c187ab85885b
# ╠═0b209f44-d7c1-424d-8fa1-0d5a46657058
# ╠═390a3394-63e9-479d-bd54-fa5088d16abb
# ╠═d0ca4cf2-96f5-4d48-90d6-62909628a6ee
# ╠═25912b01-7a74-44cc-9336-e50ccc84edb8
# ╠═276a78cc-7a76-4901-a3ea-edcf60bb7d3b
# ╠═8d63a603-6ed6-4d9c-8c50-19c7535324b7
# ╟─4dacaaee-05eb-488e-857b-9c7b95b6c181
# ╠═46084f3f-844b-4b62-9fe5-812ca917236e
# ╟─b5318ac4-91f2-44ab-b6ea-f12a63fe68de
# ╠═72c5cdcf-d6ee-435b-b018-dbb2755be00c
# ╠═711d8f7a-16fd-42ab-9e7a-c3c91f76fe1e
# ╠═f0fbd3f9-7e44-4e76-9c5e-f5347863cf8c
# ╠═70c50868-5465-4b03-918b-a83c83d224c5
