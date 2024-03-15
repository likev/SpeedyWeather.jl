#=
Shallow water with and without mountains
=#

using SpeedyWeather

spectral_grid = SpectralGrid(trunc=63, nlev=1)

orography = EarthOrography(spectral_grid) # orography = NoOrography(spectral_grid)

initial_conditions = ZonalJet()

model = ShallowWaterModel(; spectral_grid, orography, initial_conditions)

simulation = initialize!(model)
run!(simulation, period=Day(6))


run!(simulation, period=Day(6), output=true)

id = model.output.id


using PythonPlot, NCDatasets
ds = NCDataset("run_$id/output.nc")

print(ds["vor"])

t = 1
vor = Matrix{Float32}(ds["vor"][:, :, 1, t]) # convert from Matrix{Union{Missing, Float32}} to Matrix{Float32}
lat = ds["lat"][:]
lon = ds["lon"][:]

fig, ax = subplots(1, 1, figsize=(10, 6))
ax.pcolormesh(lon, lat, vor')
ax.set_xlabel("longitude")
ax.set_ylabel("latitude")
ax.set_title("Relative vorticity")

fig.savefig("plot1.png")

t = ds.dim["time"]
vor = Matrix{Float32}(ds["vor"][:, :, 1, t])
ax.pcolormesh(lon, lat, vor')
fig.savefig("plot2.png")