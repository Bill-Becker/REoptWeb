module App
# set up Genie development environment
using GenieFramework
@genietools
using REopt, JuMP, HiGHS, DotEnv, JSON
DotEnv.config()

# add your data analysis code
function optimize()
    input_dict = JSON.parsefile("inputs.json")
    s = Scenario(input_dict)
    inputs = REoptInputs(s)
    m1 = Model(optimizer_with_attributes(HiGHS.Optimizer, "output_flag" => false, "log_to_console" => false, "mip_rel_gap" => 0.01))
    m2 = Model(optimizer_with_attributes(HiGHS.Optimizer, "output_flag" => false, "log_to_console" => false, "mip_rel_gap" => 0.01))
    results = run_reopt([m1,m2], inputs)
    
    return results 
end

function get_load_profile(doe_reference_name)
    input_dict = JSON.parsefile("inputs.json")

    electric_load = simulated_load(Dict("load_type" => "electric",
                                    "doe_reference_name" => doe_reference_name,
                                    "latitude" => input_dict["Site"]["latitude"],
                                    "longitude" => input_dict["Site"]["longitude"],
                                    "annual_kwh" => 100.0))
    return electric_load["loads_kw"]
end

# add reactive code to make the UI interactive
@app begin
    # This is not reactive but I can't get the drop down to display unless I do @out
    @out load_options = REopt.default_buildings
    
    # reactive variables are tagged with @in and @out
    @in load_chosen = ""
    @out load_profile = zeros(8760)

    # @private defines a non-reactive variable
    @private test = 1

    # watch a variable and execute a block of code when
    # its value changes
    @onchange load_chosen begin
        # the values of result and msg in the UI will
        # be automatically updated
        load_profile = get_load_profile(load_chosen)
    end
end

# register a new route and the page that will be
# loaded on access
@page("/", "app.jl.html")
end
