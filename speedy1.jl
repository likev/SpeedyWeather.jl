using SpeedyWeather

spectral_grid = SpectralGrid(trunc=31, Grid=OctahedralGaussianGrid, nlev=8)
model = PrimitiveWetModel(; spectral_grid, orography = EarthOrography(spectral_grid))
simulation = initialize!(model)
run!(simulation, period=Day(10), output=true)