module CMBLensing

using Base.Broadcast: AbstractArrayStyle, ArrayStyle, Broadcasted, broadcasted,
    DefaultArrayStyle, flatten, preprocess_args, Style
using Base.Iterators: repeated, product
using Base.Threads
using Base: @kwdef, @propagate_inbounds, Bottom, OneTo, showarg, show_datatype,
    show_default, show_vector, typed_vcat
using Combinatorics
using DataStructures
using Distributed
using FFTW
using Images: feature_transform, imfilter
using Images.Kernel
using InteractiveUtils
using Interpolations
using JLD2
using FileIO
using Loess
using LinearAlgebra
using LinearAlgebra: diagzero
using MacroTools: @capture, combinedef, isexpr, postwalk, splitdef
using Match
using Markdown
using Memoize
using Optim: optimize
using Parameters
using Printf
using ProgressMeter
using PyCall
using PyPlot
using QuadGK
using Random
using Random: seed!
using Roots
using Requires
using Setfield
using StaticArrays: @SMatrix, @SVector, SMatrix, StaticArray, StaticArrayStyle,
    StaticMatrix, StaticVector, SVector
using Statistics
using StatsBase
using Strided


import Base: +, -, *, \, /, ^, ~, ≈,
    adjoint, axes, broadcast, broadcastable, BroadcastStyle, conj, convert,
    copy, copyto!, eltype, fill!, getindex, getproperty, hcat, hvcat, inv,
    iterate, keys, length, literal_pow, materialize!, materialize, one,
    print_array, promote, promote_rule, promote_rule, promote_type,
    propertynames, real, setindex!, show, show_datatype, show_vector, similar,
    size, sqrt, sqrt, string, summary, transpose, zero
import Base.Broadcast: instantiate, preprocess
import LinearAlgebra: dot, isnan, ldiv!, logdet, mul!, pinv,
    StructuredMatrixStyle, structured_broadcast_alloc, tr
import PyPlot: loglog, plot, semilogx, semilogy



export
    @animate, @repeated, @unpack, @namedtuple, azeqproj, BandPassOp, cache,
    CachedLenseFlow, camb, cg, class, cov_to_Cℓ, Cℓ_2D, Cℓ_to_Cov, DataSet,
    DerivBasis, Diagonal, DiagOp, dot, EBFourier, EBMap, FFTgrid, Field,
    FieldArray, FieldMatrix, FieldOrOpArray, FieldOrOpMatrix,
    FieldOrOpRowVector, FieldOrOpVector, FieldRowVector, FieldTuple,
    FieldVector, FieldVector, Flat, FlatEB, FlatEBFourier, FlatEBMap,
    FlatFourier, FlatIQUMap, FlatIQUMap, FlatMap, FlatQU, FlatQUFourier,
    FlatQUMap, FlatS0, FlatS2, FlatS2Fourier, FlatS2Map, FlatTEBFourier,
    Fourier, fourier∂, FuncOp, FΦTuple, get_Cℓ, get_Cℓ, get_Dℓ, get_αℓⁿCℓ,
    get_ρℓ, get_ℓ⁴Cℓ, gradhess, GradientCache, HealpixCap, HealpixS0Cap,
    HealpixS2Cap, HighPass, IdentityOp, InterpolatedCℓs, IsotropicHarmonicCov,
    LazyBinaryOp, LenseBasis, LenseFlow, LenseOp, lensing_wiener_filter,
    LinDiagOp, LinOp, lnP, load_healpix_sim_dataset, load_sim_dataset, LowPass,
    Map, MAP_joint, MAP_marg, map∂, MidPass, nan2zero, noiseCℓs, OuterProdOp,
    pack, ParamDependentOp, pixwin, plot, PowerLens, quadratic_estimate,
    QUFourier, QUMap, resimulate, S0, S02, S2, sample_joint, shortname,
    simulate, sptlike_mask, symplectic_integrate, Taylens, toCℓ, toDℓ,
    tuple_adjoint, ud_grade, Ð, Ł, δf̃ϕ_δfϕ, δfϕ_δf̃ϕ, δlnP_δfϕₜ, ℓ², ℓ⁴, ∇, ∇²,
    ∇¹, ∇ᵢ, ∇⁰, ∇ⁱ, ∇₀, ∇₁, ⋅, ⨳

# generic stuff
include("util.jl")
include("util_fft.jl")
include("numerical_algorithms.jl")
include("generic.jl")
include("cls.jl")
include("field_tuples.jl")
include("field_vectors.jl")
include("specialops.jl")

# lensing
include("lensing.jl")
include("powerlens.jl")
include("lenseflow.jl")
# include("healpix.jl")
# include("taylens.jl")

# flat-sky maps
include("flat_fftgrid.jl")
include("flat_s0.jl")
include("flat_s2.jl")
include("flat_s0s2.jl")
include("flat_generic.jl")
include("masking.jl")

include("plotting.jl")

# sampling and maximizing the posteriors
include("dataset.jl")
include("posterior.jl")
include("sampling.jl")

# other estimates
include("quadratic_estimate.jl")

end
