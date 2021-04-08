using TabularMakie
using ReTest

retest(TabularMakie)

@testset "TabularMakie.jl" begin
    include(joinpath("..", "nb", "notebook.jl"))
end
