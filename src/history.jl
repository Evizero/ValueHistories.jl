mutable struct History{I,V} <: UnivalueHistory{I}
    lastiter::I
    iterations::Vector{I}
    values::Vector{V}

    function History(::Type{V}, ::Type{I} = Int) where {I,V}
        new{I,V}(typemin(I), Array{I}(undef, 0), Array{V}(undef, 0))
    end
end

Base.length(history::History) = length(history.iterations)
Base.enumerate(history::History) = zip(history.iterations, history.values)
Base.first(history::History) = history.iterations[1], history.values[1]
Base.last(history::History) = history.iterations[end], history.values[end]
Base.get(history::History) = history.iterations, history.values

function Base.push!(
        history::History{I,V},
        iteration::I,
        value::V) where {I,V}
    lastiter = history.lastiter
    iteration > lastiter || throw(ArgumentError("Iterations must increase over time"))
    history.lastiter = iteration
    push!(history.iterations, iteration)
    push!(history.values, value)
    value
end

function Base.push!(
        history::History{I,V},
        value::V) where {I,V}
    lastiter = history.lastiter == typemin(I) ? zero(I) : history.lastiter
    iteration = lastiter + one(history.lastiter)
    history.lastiter = iteration
    push!(history.iterations, iteration)
    push!(history.values, value)
    value
end

Base.print(io::IO, history::History{I,V}) where {I,V} = print(io, "$(length(history)) elements {$I,$V}")

function Base.show(io::IO, history::History{I,V}) where {I,V}
    println(io, "History")
    println(io, "  * types: $I, $V")
    print(io,   "  * length: $(length(history))")
end

function Base.resize!(history::History, n)
    iter, vals = get(history)
    resize!(iter, n)
    resize!(vals, n)
    history.lastiter = last(iter)

    history
end

"""
    increment!(trace, iter, val)

Increments the value for a given iteration if it exists, otherwise adds the iteration with an ordinary push.
"""
function increment!(trace::History{I,V}, iter::Number, val)  where {I,V}
    if !isempty(trace.iterations)
        if trace.lastiter == iter # Check most common case to make it faster
            i = length(trace.iterations)
        else
            i = findfirst(isequal(iter), trace.iterations)
        end
        if i != nothing
            return (trace.values[i] += val)
        end
    end
    push!(trace, iter, val)
end
