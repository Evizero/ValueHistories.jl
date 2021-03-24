module ValueHistories

using DataStructures
using RecipesBase

export

    ValueHistory,
      UnivalueHistory,
        History,
        QHistory,
      MultivalueHistory,
        MVHistory,
        increment!,
    @trace,
    drop!

include("abstract.jl")
include("history.jl")
include("qhistory.jl")
include("mvhistory.jl")
include("recipes.jl")

end # module
