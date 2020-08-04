#
# Op
#

struct Op{N, Params <: NamedTuple}
  name::String
  sites::NTuple{N,Int}
  params::Params
end

Op(name::String, sites::Tuple{Vararg{Int}}) =
Op(name, sites, NamedTuple())

Op(name::String, site::Int,
  params::NamedTuple = NamedTuple()) =
Op(name, (site,), params)

Op(name::String, sites::Int...) =
Op(name, sites)

Base.convert(::Type{Op}, t::Tuple) = Op(t...)

function op(sites::Vector{<:Index}, o::Op)
  return op(sites, o.name, o.sites...; o.params...)
end

function Base.show(io::IO, o::Op)
  print(io, "\"$(o.name)\"")
  if length(o.sites) == 1
    print(io, "($(only(o.sites)))")
  else
    print(io, o.sites)
  end
  if !isempty(o.params)
    print(io, " ")
    if length(o.params) == 1
    print(io, "($(only(keys(o.params))) = $(only(o.params)))")
    else
    print(io, o.params)
    end
  end
end

#
# ProductOps
#

struct ProductOps
  data::Vector{Op}
end

ProductOps() = ProductOps(Op[])

data(C::ProductOps) = C.data

Base.copy(C::ProductOps) = ProductOps(copy(data(C)))

Base.getindex(C::ProductOps, args...) = getindex(data(C), args...)

Base.lastindex(C::ProductOps) = lastindex(data(C))

Base.push!(C::ProductOps, O) =
(push!(data(C), O);
    return C)

Base.pushfirst!(C::ProductOps, O) =
(pushfirst!(data(C), O);
    return C)

Base.iterate(C::ProductOps, args...) = iterate(data(C), args...)
Base.length(C::ProductOps) = length(data(C))

Base.:*(C::ProductOps, O) = push!(copy(C), O)

Base.:*(O, C::ProductOps) = pushfirst!(copy(C), O)

Base.:*(C1::ProductOps, C2::ProductOps) = ProductOps(vcat(data(C1), data(C2)))

"""
    C::ProductOps << O

    C::ProductOps >> O

Append the operator or operators `O` to the end of the
`ProductOps` list `C` with `<<` or to the beginning with
`>>`.
"""
Base.:<<(C::ProductOps, O) = C * O

Base.:>>(C::ProductOps, O) = O * C

function Base.show(io::IO, C::ProductOps)
  println("ProductOps")
  for o in C
    println(io, o)
  end
end

"""
    ops(C::ProductOps, ::Vector{Index})

Return a Vector of ITensors corresponding to the input circuit.
"""
ops(C::ProductOps, s::Vector{<:Index}) =
  [op(s, c) for c in C]