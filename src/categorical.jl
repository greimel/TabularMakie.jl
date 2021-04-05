module CategoricalConversions

export Continuous, HasRefPool, Categorical,
    catetorical_labels, categorical_range, categorical_trait, categorical_positions

using DataAPI: DataAPI
using AbstractPlotting: Automatic

# Trait for categorical values
struct Categorical end
struct Continuous end
struct HasRefPool end # the better Categorical

categorical_trait(x::AbstractVector) = !isnothing(DataAPI.refpool(x)) ? HasRefPool() : Categorical()
categorical_trait(::AbstractVector{<: Number}) = Continuous()

categorical_labels(xs) = categorical_labels(categorical_trait(xs), xs)
categorical_labels(::Categorical, xs) = unique(xs)
categorical_labels(::Continuous,  _)  = Automatic() # we let them be automatic
categorical_labels(::HasRefPool,  xs) = DataAPI.levels(xs) # could also use values(DataAPI.refpool(xs))

categorical_range(xs) = categorical_range(categorical_trait(xs), xs)
categorical_range(::Categorical, xs) = 1:length(categorical_labels(xs))
categorical_range(::Continuous,  _)  = Automatic() # we let them be automatic
categorical_range(::HasRefPool,  xs) = keys(DataAPI.refpool(xs))

categorical_position(x, xs) = categorical_position(categorical_trait(xs), x, xs)
categorical_position(::Categorical, x, xs, labels = categorical_labels(xs)) = findfirst(l -> l == x, labels)
categorical_position(::Continuous,  x, _)  = x
categorical_position(::HasRefPool,  x, xs) = DataAPI.invrefpool(xs)[x]

categorical_positions(xs) = categorical_positions(categorical_trait(xs), xs)
categorical_positions(::Continuous, xs) = xs
function categorical_positions(t::Categorical, xs)
    labels = categorical_labels(xs)
    categorical_position.(Ref(t), xs, Ref(xs), Ref(labels))
end
categorical_positions(::HasRefPool, xs) = DataAPI.refarray(xs)

end