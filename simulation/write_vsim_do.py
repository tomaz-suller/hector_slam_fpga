from sys import argv

VSIM_DO_BASE = '''vcd file {}.vcd;
vcd add -r /*;
add wave *
run -all;
'''
DEFAULT_VIEW_WAVE = False

def main():
    if len(argv) < 2:
        raise ValueError('VCD file name must be passed as command line argument.')

    view_wave = DEFAULT_VIEW_WAVE
    if len(argv) == 3:
        view_wave = argv[2].lower() == 'true'

    vsim_string = VSIM_DO_BASE.format(argv[1])
    if view_wave:
        vsim_string += 'view wave;\n'
    with open('vsim.do', 'wt', encoding='ascii') as file:
        file.write(vsim_string)

if __name__ == '__main__':
    main()
