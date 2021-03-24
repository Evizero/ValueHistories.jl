abstract type ValueHistory end
abstract type UnivalueHistory{I} <: ValueHistory end
abstract type MultivalueHistory <: ValueHistory end

Base.push!(history::UnivalueHistory, iteration, value) =
    throw(ArgumentError("The specified arguments are of incompatible type"))

# length(history::ValueHistory) =  error()
# enumerate(history::ValueHistory) = error()
# get(history::ValueHistory) = error()
# first(history::ValueHistory) = error()
# last(history::ValueHistory) = error()

"""
    drop!(hist, it)

Deletes all values stored for iterations greater than `it`. If
`it>first(last(hist))` then it does nothing.
"""
function drop!(history::UnivalueHistory, it)
    iter, vals = get(history)
    n = findlast(x->x<=it, iter)
    isnothing(n) && return last(iter)

    resize!(history, n)
    return history.lastiter
end
