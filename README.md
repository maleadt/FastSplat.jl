FastSplat
=========

A workaround for
[JuliaLang/julia#13359](https://github.com/JuliaLang/julia/issues/13359) in
Julia 0.6 and (to a lesser extent) 0.7, avoiding the penalty of splatting
arguments by passing the underlying argument collection and its length to a
generator function that builds a call expression with indexed arguments.

For example:

```julia
julia> @noinline foo(a,b,c) = a+b+c
julia> bar(args) = foo(args...)
julia> @code_llvm bar(SVector(1,2,3))
...
  call nonnull %jl_value_t addrspace(10)* @jl_f__apply(...)
...
```

```julia
julia> using FastSplat
julia> bar(args) = @fastsplat foo(args...)
julia> @code_llvm bar(SVector(1,2,3))
...
  call i64 @julia_foo(i64, i64, i64)
...
```

Note that this will only generate better code when the length of an array is
known to the type system, eg. when the argument is a `Vararg`, `Tuple` or
`SVector`.
