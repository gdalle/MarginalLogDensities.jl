using MarginalLogDensities
using Distributions
using StatsPlots
using Random
using Optim

Random.seed!(123)
ncategories = 8
categories = 1:ncategories
μ0 = 5.0
σ0 = 5.0
aa = rand(Normal(μ0, σ0), ncategories)
b = 4.5
σ = 0.5
category = repeat(categories, inner=50)
n = length(category)
x = rand(Uniform(-1, 1), n)
μ = [aa[category[i]] + b * x[i] for i in 1:n]
y = rand.(Normal.(μ, σ))

scatter(x, y, color=category, label="")

function loglik(θ)
    μ0 = θ[1]
    σ0 = exp(θ[2])
    aa = θ[3:10]
    b = θ[11]
    σ = exp(θ[12])
    μ = [aa[category[i]] + b * x[i] for i in 1:n]
    return loglikelihood(Normal(μ0, σ0), aa) + sum(logpdf.(Normal.(μ, σ), y))
end

θtrue = [μ0; log(σ0); aa; b; log(σ)]
nθ = length(θtrue)
loglik(θtrue)


mll = MarginalLogDensity(loglik, nθ, collect(3:10))
    # Cubature(-10ones(nθ-3), 10ones(nθ-3)))
mll(aa, [μ0, log(σ0), b, log(σ)])
mll([μ0, log(σ0), b, log(σ)])
mll(randn(4))

opt = optimize(θjoint -> -mll(θjoint), ones(4))
μ0_opt, logσ0_opt, b_opt, logσ_opt = opt.minimizer

μ0_opt
exp(logσ0_opt)
b_opt
exp(logσ_opt)

μ0_opt - μ0
exp(logσ0_opt) - σ0
b_opt - b
exp(logσ_opt) - σ