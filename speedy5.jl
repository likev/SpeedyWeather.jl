#=
Gravity waves on the sphere
=#

using SpeedyWeather

spectral_grid = SpectralGrid(trunc=127, nlev=1)

time_stepping = SpeedyWeather.Leapfrog(spectral_grid, Δt_at_T31=Minute(30))

# We set the αα parameter of the semi-implicit time integration to 0.50.5 
# to have a centred implicit scheme which dampens the gravity waves less than a backward implicit scheme would do. 
implicit = SpeedyWeather.ImplicitShallowWater(spectral_grid, α=0.5)
orography = EarthOrography(spectral_grid, smoothing=false)

# The initial conditions are set to RandomWaves which set the spherical harmonic coefficients of η to between given wavenumbers to some random values
initial_conditions = SpeedyWeather.RandomWaves()
output = OutputWriter(spectral_grid, ShallowWater, output_dt=Hour(12), output_vars=[:u, :pres, :div, :orography])

model = ShallowWaterModel(; spectral_grid, orography, output, initial_conditions, implicit, time_stepping)
simulation = initialize!(model)

#=
Note that the gravity wave speed here is gHgH
​ so almost 300m/s. Let us also output divergence, as gravity waves are quite pronounced in that variable. 
But given the speed of gravity waves we don't have to integrate for long. 
=#
run!(simulation, period=Day(2), output=true)

using PythonPlot, NCDatasets

id = model.output.id
ds = NCDataset("run_$id/output.nc")
timestep = ds.dim["time"]
div = Matrix{Float32}(ds["div"][:, :, 1, timestep])
lat = ds["lat"][:]
lon = ds["lon"][:]

fig, ax = subplots(1, 1, figsize=(10, 6))
ax.pcolormesh(lon, lat, div')
ax.set_xlabel("longitude")
ax.set_ylabel("latitude")
ax.set_title("Divergence")

fig.savefig("plot5.png")