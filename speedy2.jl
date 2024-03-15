#=
2D turbulence on a non-rotating sphere
=#

using SpeedyWeather

spectral_grid = SpectralGrid(trunc=63, nlev=1)
still_earth = Earth(spectral_grid, rotation=0)
initial_conditions = StartWithRandomVorticity()
model = BarotropicModel(; spectral_grid, initial_conditions, planet=still_earth)
simulation = initialize!(model)

run!(simulation, period=Day(5))
run!(simulation, period=Day(5))