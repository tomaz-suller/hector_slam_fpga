PROCESS_PINS = True

TOPLEVEL = ''
PINS_CSV = '../toplevel/'+TOPLEVEL+'.csv'
PINS_READ_MODE = 'manual'

############################################

target = "altera"
action = "synthesis"

syn_family = "Cyclone V"
syn_device = "5ceba4"
syn_package = "f23"
syn_grade = "c7"
syn_top = TOPLEVEL
syn_project = TOPLEVEL
syn_tool = "quartus"

if PROCESS_PINS:
    syn_pre_project_cmd = "python ../toplevel/plan_pins.py "+TOPLEVEL+" "+PINS_CSV+" "+PINS_READ_MODE
    syn_post_project_cmd = "quartus_sh -t pins.tcl compile "+TOPLEVEL+" "+TOPLEVEL
syn_post_bitstream_cmd = "quartus_sh --archive "+TOPLEVEL

modules = {
    "local" : [
        "../toplevel"
    ],
}
