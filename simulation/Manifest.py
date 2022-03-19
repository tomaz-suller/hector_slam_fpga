TOPLEVEL = ''
VCD_NAME = TOPLEVEL
VIEW_WAVE = False # TODO fix; does nothing

###################################################

action = "simulation"
sim_tool = "modelsim"
sim_top = TOPLEVEL + "_tb"

sim_pre_cmd = "python write_vsim_do.py " + VCD_NAME+" "+str(VIEW_WAVE)
sim_post_cmd = "vsim -voptargs=+acc -do vsim.do -i " + sim_top

modules = {
    "local" : [
        "../testbenches/",
        "../toplevel/",
    ],
}
