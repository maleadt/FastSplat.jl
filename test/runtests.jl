using FastSplat
using Compat
using Compat.Test

@testset "vararg" begin
    splat_single(args...) = string(args...)
    fastsplat_single(args...) = @fastsplat string(args...)
    @test splat_single(1,2,3) == fastsplat_single(1,2,3)

    splat_trailing(args...) = string(0,args...)
    fastsplat_trailing(args...) = @fastsplat string(0,args...)
    @test splat_trailing(1,2,3) == fastsplat_trailing(1,2,3)

    splat_leading(args...) = string(args...,0)
    fastsplat_leading(args...) = @fastsplat string(args...,0)
    @test splat_leading(1,2,3) == fastsplat_leading(1,2,3)

    splat_middle(args...) = string(0,args...,0)
    fastsplat_middle(args...) = @fastsplat string(0,args...,0)
    @test splat_middle(1,2,3) == fastsplat_middle(1,2,3)
end

@testset "array" begin
    splat_single(args) = string(args...)
    fastsplat_single(args) = @fastsplat string(args...)
    @test splat_single([1,2,3]) == fastsplat_single([1,2,3])

    splat_trailing(args) = string(0,args...)
    fastsplat_trailing(args) = @fastsplat string(0,args...)
    @test splat_trailing([1,2,3]) == fastsplat_trailing([1,2,3])

    splat_leading(args) = string(args...,0)
    fastsplat_leading(args) = @fastsplat string(args...,0)
    @test splat_leading([1,2,3]) == fastsplat_leading([1,2,3])

    splat_middle(args) = string(0,args...,0)
    fastsplat_middle(args) = @fastsplat string(0,args...,0)
    @test splat_middle([1,2,3]) == fastsplat_middle([1,2,3])
end
