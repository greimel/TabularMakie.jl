const SymStr = Union{Symbol,AbstractString}

import DataFrames: ByRow

iscolumn(tbl, var) = var_key(var) in propertynames(tbl)

var_key(var) = var # needed to handle, eg, `linewidth = 2`
var_lab(var::SymStr) = string(var)
var_trans(var::SymStr) = identity

var_key(var::Pair{<: SymStr, <: SymStr}) = first(var)
var_lab(var::Pair{<: SymStr, <: SymStr}) = string(last(var))
var_trans(var::Pair{<: SymStr, <: SymStr}) = identity

var_key(var::Pair{<: SymStr, <: Function}) = first(var)
var_lab(var::Pair{<: SymStr, <: Function}) = funname(var_trans(var)) * "(" * string(first(var)) * ")"
var_trans(var::Pair{<: SymStr, <: Function}) = last(var)

var_key(var::Pair{<: SymStr, <: Pair{<: Function, <: SymStr}}) = first(var)
var_lab(var::Pair{<: SymStr, <: Pair{<: Function, <: SymStr}}) = string(last(last(var)))
var_trans(var::Pair{<: SymStr, <: Pair{<: Function, <: SymStr}}) = first(last(var))

funname(f) = string(Symbol(f))
funname(f::ByRow) = funname(f.fun)

function get(tbl, var)
    f = var_trans(var)
    col = getproperty(tbl, var_key(var))
    if f isa ByRow
        (f.fun).(col)
    else
        f(col)
    end
end