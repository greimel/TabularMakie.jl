var documenterSearchIndex = {"docs":
[{"location":"","page":"Home","title":"Home","text":"CurrentModule = TabularMakie","category":"page"},{"location":"","page":"Home","title":"Home","text":"using CairoMakie\nCairoMakie.activate!()","category":"page"},{"location":"","page":"Home","title":"Home","text":"<details> <summary> Generate some data ... </summary>","category":"page"},{"location":"","page":"Home","title":"Home","text":"using DataFrames, CategoricalArrays\nusing DataAPI: refarray\n\ncs_df = let\n\tN = 100\n\tdummy_df = DataFrame(\n\t\txxx = rand(N),\n\t\tyyy = rand(N),\n\t\ts_m  = rand(5:13, N),\n\t\tg_c  = rand([\"c 1\", \"c 2\", \"c 3\"], N) |> categorical,\n\t\tg_lx = rand([\"lx 1\", \"lx 2\", \"lx 3\"], N) |> categorical,\n\t\tg_m  = rand([\"m 1\", \"m 2\", \"m 3\"], N) |> categorical\n\t\t)\n\t\n\tdummy_df[:,:s_c] = 2 .* rand(N) .+ refarray(dummy_df.g_lx)\n\tdummy_df\nend\nnothing # hide","category":"page"},{"location":"","page":"Home","title":"Home","text":"using DataFrames, CategoricalArrays\nusing DataAPI: refarray\n\nts_df = let\n\tg_la = [\"lay 1\", \"lay 2\"]\n\tg_co = [\"c 1\", \"c 2\"]\n\tg_ls = [\"ls 1\", \"ls 2\", \"ls 3\"]\n\t\n\tts_df = DataFrame(Iterators.product(g_la, g_co, g_ls))\n\t\n\tgrps = [:g_la, :g_co, :g_ls]\n\t\n\trename!(ts_df, grps)\n\ttransform!(ts_df, grps .=> categorical, renamecols = false)\n\t\n\ttransform!(ts_df, :g_co => (x -> refarray(x) .+ rand.())  => :s_co)\n\ttransform!(ts_df, :s_co => ByRow(float) => :s_co)\n\t\n\tts_df[:,:grp] = 1:size(ts_df, 1) |> categorical\n\t\n\tfunction rw_nt(T)\n\t\tfunction(i)\n\t\t\trw = cumsum(randn(T))\n\t\t\n\t\t\tDataFrame([(t = t, v = v, grp = i) for (t, v) in enumerate(rw)])\n\t\tend\n\tend\n\t\n\tT = 100\n\t\n\tcombine(groupby(ts_df, [grps; :s_co])) do sdf\n\t\tgrp = sdf.grp[1]\n\t\t\n\t\trw_nt(T)(grp)\n\tend\nend\nnothing # hide","category":"page"},{"location":"","page":"Home","title":"Home","text":"using DataFrames\n\nbar_tbl = (x = [1, 1, 1, 2, 2, 2, 3, 3, 3],\n       height = 0.1:0.1:0.9,\n       grp = \"Group \" .* string.([1, 2, 3, 1, 2, 3, 1, 2, 3]),\n       grp1 = \"grp \" .* string.([1, 2, 2, 1, 1, 2, 1, 1, 2]),\n       grp2 = \"Grp \" .* string.([1, 1, 2, 1, 2, 1, 1, 2, 1])\n       )\n\nbar_df = DataFrame(bar_tbl)\nnothing # hide","category":"page"},{"location":"","page":"Home","title":"Home","text":"</details>","category":"page"},{"location":"#TabularMakie","page":"Home","title":"TabularMakie","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"This is how it looks.","category":"page"},{"location":"","page":"Home","title":"Home","text":"using TabularMakie, CairoMakie\n\nfig = lplot(Scatter, cs_df, :xxx, :yyy; color = :s_c, marker = :g_m,  markersize = :s_m, layout_wrap = :g_lx)\n\nsave(\"fig_cs1.svg\", fig); # hide","category":"page"},{"location":"","page":"Home","title":"Home","text":"(Image: fig_cs1)","category":"page"},{"location":"","page":"Home","title":"Home","text":"We can use the DataFrames.jl minilanguage to transform columns or rename them. You have the following options.","category":"page"},{"location":"","page":"Home","title":"Home","text":"source_column => target_column_name\nsource_column => transformation\nsource_column => transformation => target_column_name","category":"page"},{"location":"","page":"Home","title":"Home","text":"This is shown in the following example.","category":"page"},{"location":"","page":"Home","title":"Home","text":"\nusing CategoricalArrays: recode!\n\nrec_1(x) = recode!(x, \"m 1\" => \"Nice name\", \"m 2\" => \"Other\")\nrec_2(x) = recode!(x, \"lx 1\" => \"Panel 1\")\nminus1(x) = x .- 1\n\nfig = lplot(Scatter, cs_df,\n\t:xxx => minus1,\n\t:yyy => ByRow(x -> x + 1) => \"the y plus one\";\n\tcolor = :s_c => \"hey there\",\n\tmarker = :g_m => rec_1 => \"bla\",\n\tmarkersize = :s_m => :tada,\n\tlayout_wrap = :g_lx => rec_2\t\n  )\n\nsave(\"fig_cs2.svg\", fig); # hide","category":"page"},{"location":"","page":"Home","title":"Home","text":"(Image: fig_cs2)","category":"page"},{"location":"","page":"Home","title":"Home","text":"using TabularMakie, CairoMakie\n\nfig = lplot(Lines, ts_df,\n\t\t:t,\n\t\t:v;\n\t\tcolor = :g_co => \"Buahh!\",\n\t\tlayout_x = :g_la,\n\t\tlinestyle = :g_ls,\n\t\tlinewidth = 2,\n\t\tlegend_attr = (position = :left,)\n)\nsave(\"fig_ts1.svg\", fig); # hide","category":"page"},{"location":"","page":"Home","title":"Home","text":"(Image: fig_ts1)","category":"page"},{"location":"","page":"Home","title":"Home","text":"using TabularMakie, CairoMakie\n\nfig = lplot(Lines, ts_df, :t, :v; color = :s_co, layout_y = :g_co, group = :grp )\nsave(\"fig_ts2.svg\", fig); # hide","category":"page"},{"location":"","page":"Home","title":"Home","text":"(Image: fig_ts2)","category":"page"},{"location":"","page":"Home","title":"Home","text":"using TabularMakie, CairoMakie\n\nfig = lplot(BarPlot, bar_df,\n\t:x => \"nice name for x\",\n\t:height,\n\tstack = :grp1,\n\tdodge = :grp2,\n\tcolor = :grp => \" \"\n)\nsave(\"fig_bar1.svg\", fig); # hide","category":"page"},{"location":"","page":"Home","title":"Home","text":"(Image: fig_bar1)","category":"page"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"Modules = [TabularMakie]","category":"page"},{"location":"#TabularMakie.lookup_symbols-NTuple{4, Any}","page":"Home","title":"TabularMakie.lookup_symbols","text":"This function replaces group indicators (numbers, categories) by attributes that can be plotted (:solid, :red, etc...)\n\n\n\n\n\n","category":"method"}]
}
