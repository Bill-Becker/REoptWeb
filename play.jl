using REopt 

electric_load = simulated_load(Dict("load_type" => "electric",
    "doe_reference_name" => "LargeOffice",
    "latitude" => 41.8781136,
    "longitude" => -87.6297982,
    "annual_kwh" => 1.0))
