from sys import argv
import pandas as pd

DEFAULT_PIN_FILENAME = 'pins.csv'
DEFAULT_READ_OPTION = 'manual'
TCL_PIN_FILENAME = '../synthesis/pins.tcl'
TCL_ASSIGNMENT_BASE_COMMAND = 'set_location_assignment {} -to {}\n'

def main():
    project_name, pin_filename, read_option = parse_input(argv)
    if read_option == 'manual':
        final_pins_df = pd.read_csv(pin_filename, comment='#')
    elif read_option == 'quartus':
        pins_df = pd.read_csv(pin_filename, comment='#')
        final_pins_df = process_quartus_csv(pins_df)
    else:
        raise ValueError('Unrecognised read mode; options are "manual" and "quartus"')

    write_tcl_pin_assignments(project_name, final_pins_df)


def parse_input(args):
    if len(args) < 2:
        raise ValueError('At least project name must be supplied.')
    if len(args) == 2:
        return args[1], DEFAULT_PIN_FILENAME, DEFAULT_READ_OPTION
    if len(args) == 3:
        return args[1], args[2], DEFAULT_READ_OPTION
    return args[1], args[2], args[3]

def process_quartus_csv(dataframe):
    ports = dataframe['To']
    pins = dataframe['Location']
    return pd.DataFrame({'port': ports, 'pin': pins})

def write_tcl_pin_assignments(name, dataframe):
    with open(TCL_PIN_FILENAME, 'wt', encoding='ascii') as file:
        file.write('package require ::quartus::project\n')
        file.write(f'project_open -revision {name} {name}\n')
        for _, (port, pin) in dataframe.iterrows():
            file.write(TCL_ASSIGNMENT_BASE_COMMAND.format(
                pin.strip(), port.strip()))
        file.write('export_assignments\n')
        file.write('project_close\n')

if __name__ == '__main__':
    main()
