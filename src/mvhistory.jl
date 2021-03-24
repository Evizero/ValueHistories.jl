
struct MVHistory{H<:UnivalueHistory} <: MultivalueHistory
    storage::Dict{Symbol, H}
end

function MVHistory(::Type{H} = History) where {H<:UnivalueHistory}
    MVHistory{H}(Dict{Symbol, H}())
end

# ====================================================================
# Functions

Base.length(history::MVHistory, key::Symbol) = length(history.storage[key])
Base.enumerate(history::MVHistory, key::Symbol) = enumerate(history.storage[key])
Base.first(history::MVHistory, key::Symbol) = first(history.storage[key])
Base.last(history::MVHistory, key::Symbol) = last(history.storage[key])
Base.keys(history::MVHistory) = keys(history.storage)
Base.values(history::MVHistory, key::Symbol) = get(history, key)[2]

function Base.push!(
        history::MVHistory{H},
        key::Symbol,
        iteration::I,
        value::V) where {I,H<:UnivalueHistory,V}
    if !haskey(history.storage, key)
        _hist = H(V, I)
        push!(_hist, iteration, value)
        history.storage[key] = _hist
    else
        push!(history.storage[key], iteration, value)
    end
    value
end

function Base.push!(
        history::MVHistory{H},
        key::Symbol,
        value::V) where {H<:UnivalueHistory,V}
    if !haskey(history.storage, key)
        _hist = H(V, Int)
        push!(_hist, value)
        history.storage[key] = _hist
    else
        push!(history.storage[key], value)
    end
    value
end

function Base.getindex(history::MVHistory, key::Symbol)
    history.storage[key]
end

Base.haskey(history::MVHistory, key::Symbol) = haskey(history.storage, key)

function Base.get(history::MVHistory, key::Symbol)
    l = length(history, key)
    k, v = first(history.storage[key])
    karray = Array{typeof(k)}(undef, l)
    varray = Array{typeof(v)}(undef, l)
    i = 1
    for (k, v) in enumerate(history, key)
        karray[i] = k
        varray[i] = v
        i += 1
    end
    karray, varray
end

function Base.show(io::IO, history::MVHistory{H}) where {H}
    print(io, "MVHistory{$H}")
    for (key, val) in history.storage
        print(io, "\n", "  :$(key) => $(val)")
    end
end

using Base.Meta

"""
Easily add to a MVHistory object `tr`.

Example:

```julia
using ValueHistories, OnlineStats
v = Variance(BoundedEqualWeight(30))
tr = MVHistory()
for i=1:100
    r = rand()
    fit!(v,r)
    μ,σ = mean(v),std(v)

    # add entries for :r, :μ, and :σ using their current values
    @trace tr i r μ σ
end
```
"""
macro trace(tr, i, vars...)
    block = Expr(:block)
    for v in vars
        push!(block.args, :(push!($(esc(tr)), $(quot(Symbol(v))), $(esc(i)), $(esc(v)))))
    end
    block
end

"""
    increment!(trace, key, iter, val)

Increments the value for a given key and iteration if it exists, otherwise adds the key/iteration pair with an ordinary push.
"""
function increment!(trace::MVHistory{<:History}, key::Symbol, iter::Number, val)
    if haskey(trace, key)
        i = findfirst(isequal(iter), trace.storage[key].iterations)
        if i != nothing
            return trace[key].values[i] += val
        end
    end
    push!(trace, key, iter, val)
end

"""
    drop!(hist, it)

Deletes all values stored for iterations greater than `it` for all
keys stored in `hist`.
"""
function drop!(history::MVHistory, it)
    lastiters = Int[]
    for hist=values(history.storage)
        push!(lastiters, drop!(hist, it))
    end
    maximum(lastiters)
end
