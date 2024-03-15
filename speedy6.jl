#=
Jablonowski-Williamson baroclinic wave
=#

using SpeedyWeather

spectral_grid = SpectralGrid(trunc=31, nlev=8, Grid=FullGaussianGrid, dealiasing=3)

# The Jablonowski-Williamson initial conditions are in ZonalWind, the orography is just a ZonalRidge. 
orography = ZonalRidge(spectral_grid)
initial_conditions = ZonalWind()

#=
 we switch off all physics with physics=false. 
 There is no forcing and the initial conditions are baroclinically unstable which kicks off a wave propagating eastward. 
=#
model = PrimitiveDryModel(; spectral_grid, orography, initial_conditions, physics=false)
simulation = initialize!(model)

run!(simulation, period=Day(9), output=true)

using PythonPlot, NCDatasets

id = model.output.id
ds = NCDataset("run_$id/output.nc")
timestep = ds.dim["time"]
surface = ds.dim["lev"]
vor = Matrix{Float32}(ds["vor"][:, :, surface, timestep])
lat = ds["lat"][:]
lon = ds["lon"][:]

fig, ax = subplots(1, 1, figsize=(10, 6))
ax.pcolormesh(lon, lat, vor')
ax.set_xlabel("longitude")
ax.set_ylabel("latitude")
ax.set_title("Surface relative vorticity")

fig.savefig("plot6.png")