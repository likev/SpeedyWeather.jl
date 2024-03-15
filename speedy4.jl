#=
Polar jet streams in shallow water
=#

using SpeedyWeather

spectral_grid = SpectralGrid(trunc=63, nlev=1)

forcing = JetStreamForcing(spectral_grid, latitude=60)
drag = QuadraticDrag(spectral_grid)
output = OutputWriter(spectral_grid, ShallowWater, output_dt=Hour(6), output_vars=[:u, :v, :pres, :orography])

model = ShallowWaterModel(; spectral_grid, output, drag, forcing)
simulation = initialize!(model)

run!(simulation, period=Day(20))   # discard first 20 days

run!(simulation, period=Day(20), output=true)

using PythonPlot, NCDatasets

id = model.output.id
ds = NCDataset("run_$id/output.nc")
timestep = ds.dim["time"]
u = Matrix{Float32}(ds["u"][:, :, 1, timestep])
lat = ds["lat"][:]
lon = ds["lon"][:]

fig, ax = subplots(1, 1, figsize=(10, 6))
q = ax.pcolormesh(lon, lat, u')
ax.set_xlabel("longitude")
ax.set_ylabel("latitude")
ax.set_title("Zonal wind [m/s]")
colorbar(q, ax=ax)


fig.savefig("plot3.png")