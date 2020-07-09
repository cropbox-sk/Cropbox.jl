abstract type Graph end

graph(g::Graph) = g
labels(g::Graph; kw...) = [] #error("labels() not defined for $x")
edgestyles(g::Graph; kw...) = Dict()

import TikzGraphs
plot(g::Graph, layout=(), label=(), edgestyle=()) = begin
    TikzGraphs.plot(
        graph(g),
        TikzGraphs.Layouts.Layered(; layout...),
        labels(g; label...);
        edge_styles=edgestyles(g; edgestyle...),
        prepend_preamble="\\usetikzlibrary{backgrounds}",
        options="background rectangle/.style={fill=white}, show background rectangle",
    )
end

import TikzPictures
Base.write(filename::AbstractString, g::Graph; plotopts...) = begin
    f = TikzPictures.PDF(string(filename))
    TikzPictures.save(f, plot(g; plotopts...))
end

makedot(g::Graph) = begin
    node(i, l) = """$i [label="$l"]\n"""
    N = [node(i, l) for (i, l) in enumerate(labels(g))]
    
    edge(a, b) = """$a -> $b [style="$(get(ES, (a, b), ""))"]\n"""
    ES = edgestyles(g)
    E = [edge(e.src, e.dst) for e in edges(graph(g))]
    
    """
    digraph {
    node[
        width=0
        height=0
        margin=0.03
        shape=plaintext
    ]
    edge [
        arrowsize=0.2
        penwidth=0.5
    ]
    $(N...)
    $(E...)
    }
    """
end

writedot(g::Graph) = let f = "$(tempname()).dot"; 
    write(f, makedot(g))
    f
end

import Graphviz_jll
writesvg(name::AbstractString, g::Graph) = begin
    !endswith(name, ".svg") && (name *= ".svg")
    dot = writedot(g)
    Graphviz_jll.dot() do exe
        cmd = `$exe -Tsvg $dot -o $name`
        success(cmd) || error("cannot execute: $cmd")
    end
    name
end

Base.show(io::IO, ::MIME"image/svg+xml", g::Graph) = begin
    f = writesvg(tempname(), g)
    s = read(f, String)
    print(io, s)
end
