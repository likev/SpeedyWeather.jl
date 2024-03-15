#=
Particle advection
=#

using SpeedyWeather

# are placed in random locations (using rand) initially. 
spectral_grid = SpectralGrid(n_particles = 100, nlev=1)

# A ParticleTracker is implemented as a callback which would output every 3 hours (the default).
# schedule = Schedule(every=Hour(3))
# particle_tracker = ParticleTracker(spectral_grid, schedule)
particle_tracker = ParticleTracker(spectral_grid, Δt=Hour(3))

particle_advection = ParticleAdvection2D(spectral_grid, layer = 1)

model = ShallowWaterModel(;spectral_grid, particle_advection)

# The callback is then added after the model is created which will give it a random key too in case you need to remove it again
add!(model.callbacks, particle_tracker)

simulation = initialize!(model)

# the particles live as Vector{Particle} inside the prognostic variables
simulation.prognostic_variables.particles

run!(simulation, period=Day(10))
simulation.prognostic_variables.particles

using NCDatasets
run_id = "run_$(model.output.id)"                    # create a run_???? string with output id
path = joinpath(run_id, particle_tracker.file_name)  # by default "run_????/particles.nc"
ds = NCDataset(path)
ds["lon"]
ds["lat"]

lon = ds["lon"][:,:]
lat = ds["lat"][:,:]

#=
using PythonPlot
fig, ax = subplots(1, 1, figsize=(10, 6))
ax.plot(lon', lat')
ax.set_xlabel("longitude")
ax.set_ylabel("latitude")
ax.set_title("Particle advection")

fig.savefig("plot7.png")

=#


#=
use a more advanced (but a little slower) projection With Makie.jl and plot the particle trajectories as geodetics. 
=#
using GeoMakie, CairoMakie # or GLMakie GUI backend

fig = Figure() # may conflict with PythonPlot.Figure
ga = GeoAxis(fig[1, 1]; dest = "+proj=ortho +lon_0=120 +lat_0=40")

lines!(ga, GeoMakie.coastlines())
ga.xticklabelsvisible[] = false
ga.yticklabelsvisible[] = false

n_particles = size(lon)[1]
[lines!(ga, lon[i,:], lat[i,:]) for i in 1:n_particles]
fig

save("plot8.png", fig)