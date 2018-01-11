module FastSplat

export @fastsplat

macro fastsplat(call)
    @assert call.head == :call
    f = call.args[1]
    args = call.args[2:end]

    # figure out which arguments are splats
    splats = map(arg->isa(arg,Expr) && arg.head==:(...), args)

    gen = define_generator(splats)
    return esc(call_generator(gen, f, args, splats))
end

# define a generated function of signature `gen(f, args...)`
# where every arg corresponds with the original arg,
# or the arg and its length if it was splatted
function define_generator(splats::Vector{Bool})
    # build an arglist of form `(arg1, ... argN, ::Type{Val{LenN}}, ...)`
    arglist = Union{Expr,Symbol}[]
    typevars = Symbol[]
    for (i,splat) in enumerate(splats)
        push!(arglist, Symbol(:arg, i))
        if splat
            typevar = Symbol(:Len, i)
            push!(arglist, :(::Type{Val{$typevar}}))
            push!(typevars, typevar)
        end
    end

    # build an invocation of the original function, with every splat expanded
    args = Any[]
    for (i,splat) in enumerate(splats)
        arg = Symbol(:arg, i)
        if splat
            len = Symbol(:Len, i)
            push!(args, Expr(:(...), :((Expr(:ref, $(QuoteNode(arg)), i) for i in 1:$len))))
        else
            push!(args, QuoteNode(arg))
        end
    end

    @gensym gen
    @eval begin
        @generated function $gen(f, $(arglist...)) where {$(typevars...)}
            args = ($(args...),)
            quote
                Base.@_inline_meta
                @inbounds ret = f($(args...))
                ret
            end
        end
    end
    return gen
end

# emit an expression to call a generator as defined by `define_generator`
function call_generator(gen, f, args, splats)
    call = Expr(:call, :($FastSplat.$gen), f)
    for (i,splat) in enumerate(splats)
        if splat
            arg = args[i].args[1]
            push!(call.args, arg)
            push!(call.args, :(Val{length($arg)}))
        else
            arg = args[i]
            push!(call.args, arg)
        end
    end
    return call
end

end
