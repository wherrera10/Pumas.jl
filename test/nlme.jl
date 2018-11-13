using Test
using PuMaS

data = process_nmtran(example_nmtran_data("sim_data_model1"))

mdsl = @model begin
    @param begin
        θ ∈ ConstDomain(0.5)
        Ω ∈ PSDDomain(Matrix{Float64}(fill(0.04, 1, 1)))
        Σ ∈ ConstDomain(0.1)
    end

    @random begin
        η ~ MvNormal(Ω)
    end

    @pre begin
        CL = θ * exp(η[1])
        V  = 1.0
    end

    @vars begin
        conc = Central / V
    end

    @dynamics ImmediateAbsorptionModel

    @derived begin
        dv ~ @. Normal(conc,conc*sqrt(Σ)+eps())
    end
end

x0 = init_param(mdsl)
y0 = init_random(mdsl, x0)

subject = data.subjects[1]

cl = conditional_loglikelihood(mdsl,subject,x0,y0)
ml = sum(subject -> marginal_loglikelihood(mdsl,subject,x0,y0,Laplace()), data.subjects)

length(data.subjects)
using Optim
function f(η,subject)
  PuMaS.peanalized_conditional_loglikelihood(mdsl,subject, x0, (η=η,))
end

ηstar = [Optim.optimize(η -> f(η,data[i]),zeros(1),BFGS()).minimizer[1] for i in 1:10]
ml = sum(i -> -PuMaS.marginal_loglikelihood_nonmem(mdsl,data[i],x0,(η=[ηstar[i]],),Laplace()), 1:10)










@test_broken ml ≈ 56.810343602063618 rtol = 1e-6
