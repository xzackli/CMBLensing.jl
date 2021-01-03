
const FlatField{B, M<:FlatProj, T, A<:AbstractArray{T}} = BaseField{B, M, T, A}

# const FlatFieldMap{P,T,M} = Union{FlatMap{P,T,M},FlatS2Map{P,T,M},FlatS02Map{P,T,M}}
# const FlatFieldFourier{P,T,M} = Union{FlatFourier{P,T,M},FlatS2{P,T,M},FlatS02Fourier{P,T,M}}

### pretty printing
Base.show_datatype(io::IO, t::Type{<:Field}) = print(io, typealias(t))
typealias(T) = string(T)
typealias(::Type{F}) where {B,M,T,A,F<:FlatField{B,M,T,A}} = "Flat$(B.name.name){$(typealias(A)),$(typealias(M))}"
function Base.summary(io::IO, f::FlatField)
    @unpack Nx,Ny,θpix = f
    Nbatch = size(f.arr, 4)
    print(io, "$(length(f))-element $Ny×$Nx$(Nbatch==1 ? "" : "(×$Nbatch)")-map $(θpix)′-pixels ")
    Base.showarg(io, f, true)
end

# ### promotion & conversion
# # note: we don't need to promote the eltype T here since that will be
# # automatically handled in broadcasting
# function promote(f1::F1, f2::F2) where {T1,θ1,N1,∂mode1,F1<:FlatField{<:Flat{N1,θ1,∂mode1},T1},T2,θ2,N2,∂mode2,F2<:FlatField{<:Flat{θ2,N2,∂mode2},T2}}
#     B     = promote_type(basis(F1),basis(F2))
#     ∂mode = promote_type(∂mode1,∂mode2)
#     B(∂mode(f1)), B(∂mode(f2))
# end
# (::Type{∂mode})(f::F) where {∂mode<:∂modes,N,θ,D,F<:FlatS0{<:Flat{N,θ,<:Any,D}}} = basetype(F){Flat{N,θ,∂mode,D}}(fieldvalues(f)...)
# (::Type{∂mode})(f::FieldTuple{B}) where {∂mode<:∂modes,B} = FieldTuple{B}(map(∂mode,f.fs))

### basis-like definitions
LenseBasis(::Type{<:FlatS0}) = Map
LenseBasis(::Type{<:FlatS2}) = QUMap
DerivBasis(::Type{<:FlatS0}) = Fourier
DerivBasis(::Type{<:FlatS2}) = QUFourier
# LenseBasis(::Type{<:FlatS02}) = IQUMap
# DerivBasis(::Type{<:FlatS0{<:Flat{<:Any,<:Any,fourier∂}}})  =    Fourier
# DerivBasis(::Type{<:FlatS2{<:Flat{<:Any,<:Any,fourier∂}}})  =  QUFourier
# DerivBasis(::Type{<:FlatS02{<:Flat{<:Any,<:Any,fourier∂}}}) = IQUFourier
# DerivBasis(::Type{<:FlatS0{<:Flat{<:Any,<:Any,map∂}}})      =    Map
# DerivBasis(::Type{<:FlatS2{<:Flat{<:Any,<:Any,map∂}}})      =  QUMap
# DerivBasis(::Type{<:FlatS02{<:Flat{<:Any,<:Any,map∂}}})     = IQUMap


### derivatives

function preprocess((g,metadata)::Tuple{<:Any,<:ProjLambert}, ∇d::∇diag)
    if ∇d.coord == 1
        broadcasted(*, ∇d.prefactor * im, metadata.ℓx')
    elseif ∇d.coord == 2
        broadcasted(*, ∇d.prefactor * im, metadata.ℓy)
    else
        error()
    end
end


# ## Map-space
# function copyto!(f′::F, bc::Broadcasted{<:Any,<:Any,typeof(*),Tuple{∇diag{coord,covariant,prefactor},F}}) where {coord,covariant,prefactor,T,θ,N,D,F<:FlatMap{Flat{N,θ,map∂,D},T}}
#     D!=1 && error("Gradients of batched map∂ flat maps not implemented yet.")
#     f = bc.args[2]
#     n,m = size(f.Ix)
#     α = 2 * prefactor * fieldinfo(f).Δx
#     if coord==1
#         @inbounds for j=2:m-1
#             @simd for i=1:n
#                 f′[i,j] = (f[i,j+1] - f[i,j-1])/α
#             end
#         end
#         @inbounds for i=1:n
#             f′[i,1] = (f[i,2]-f[i,end])/α
#             f′[i,end] = (f[i,1]-f[i,end-1])/α
#         end
#     elseif coord==2
#         @inbounds for j=1:n
#             @simd for i=2:m-1
#                 f′[i,j] = (f[i+1,j] - f[i-1,j])/α
#             end
#             f′[1,j] = (f[2,j]-f[end,j])/α
#             f′[end,j] = (f[1,j]-f[end-1,j])/α
#         end
#     end
#     f′
# end



# ### bandpass
# HarmonicBasis(::Type{<:FlatS0}) = Fourier
# HarmonicBasis(::Type{<:FlatQU}) = QUFourier
# HarmonicBasis(::Type{<:FlatEB}) = EBFourier
# broadcastable(::Type{F}, bp::BandPass) where {P,T,F<:FlatFourier{P,T}} = Cℓ_to_2D(P,T,bp.Wℓ)
    

# ### logdets
# logdet(L::Diagonal{<:Complex,<:FlatFourier}) = batch(real(sum_kbn(nan2zero.(log.(L.diag[:Il,full_plane=true])),dims=(1,2))))
# logdet(L::Diagonal{<:Real,   <:FlatMap})     = batch(real(sum_kbn(nan2zero.(log.(complex.(L.diag.Ix))),dims=(1,2))))
# ### traces
# tr(L::Diagonal{<:Complex,<:FlatFourier}) = batch(real(sum_kbn(L.diag[:Il,full_plane=true],dims=(1,2))))
# tr(L::Diagonal{<:Real,   <:FlatMap})     = batch(real(sum_kbn(complex.(L.diag.Ix),dims=(1,2))))


# ### misc
# Cℓ_to_Cov(f::FlatField{P,T,M}, args...; kwargs...) where {P,T,M} = adapt(M, Cℓ_to_Cov(P,T,spin(f),args...; kwargs...))

# function pixwin(f::FlatField) 
#     @unpack θpix,P,T,k = fieldinfo(f)
#     Diagonal(FlatFourier{P,T}((pixwin.(θpix,k) .* pixwin.(θpix,k'))[1:end÷2+1,:]))
# end

# global_rng_for(::Type{<:FlatField{<:Any,<:Any,M}}) where {M} = global_rng_for(M)

# """
#     fixed_white_noise(rng, F)

# Like white noise but the amplitudes are fixed to unity, only the phases are
# random. Currently only implemented when F is a Fourier basis. Note that unlike
# [`white_noise`](@ref), fixed white-noise generated in EB and QU Fourier bases
# are not statistically the same.
# """
# fixed_white_noise(rng, F::Type{<:FlatFieldFourier}) =
#      exp.(im .* angle.(basis(F)(white_noise(rng,F)))) .* fieldinfo(F).Nside
