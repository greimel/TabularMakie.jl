module TmpCategorical

export Continuous, HasRefPool, Categorical,
    catetorical_labels, categorical_range, categorical_trait, categorical_positions

using AbstractPlotting: AbstractPlotting, categorical_trait, Categorical, Automatic

const AP = AbstractPlotting

struct HasRefPool end
const Continuous = AP.Continous

AP.categorical_trait(x::AbstractVector) = !isnothing(DataAPI.refpool(x)) ? HasRefPool() : Categorical()

AP.categoric_labels(::HasRefPool,  xs) = DataAPI.levels(xs)

categorical_labels = AP.categoric_labels

# -----------------------------
# ----- Categorical range -----
# -----------------------------

categorical_range(xs) = categorical_range(categorical_trait(xs), xs)

function categorical_range(t, xs)
    labels  = categorical_labels(t, xs)
    AP.categoric_range(t, labels)
end

#categorical_range(::HasRefPool,  xs) = keys(DataAPI.refpool(xs))

# -----------------------------
# --- Categorical positions ---
# -----------------------------

categorical_positions(xs) = categorical_positions(categorical_trait(xs), xs)
categorical_positions(::Continuous, xs) = xs
function categorical_positions(t::AP.Categorical, xs)
    labels = categorical_labels(xs)
    categorical_position.(Ref(t), xs, Ref(xs), Ref(labels))
end
categorical_positions(::HasRefPool, xs) = DataAPI.refarray(xs)

categorical_position(x, xs) = categorical_position(categorical_trait(xs), x, xs)
categorical_position(::Categorical, x, xs, labels = categorical_labels(xs)) = findfirst(l -> l == x, labels)
categorical_position(::Continuous,  x, _)  = x
categorical_position(::HasRefPool,  x, xs) = DataAPI.invrefpool(xs)[x]

end