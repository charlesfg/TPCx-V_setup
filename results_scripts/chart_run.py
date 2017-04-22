import argparse
from mix_log_parser import MixLogParser
from tpc_plot import single_plot, multi_plot
import os

if __name__ == '__main__':

    parser = argparse.ArgumentParser(description='Generate the stats charts based on a folder run and save them to a '
                                                 'specificied folder')
    parser.add_argument('-r', '--run-folder', type=str, help='The folder where lives the results for the run. '
                                                             'Named by the integer that identifies it!', required=True)
    parser.add_argument('-f', '--folder', type=str, help='Folder to store the chart files', required=True)

    args = parser.parse_args()

    # Run folder
    rf = args.run_folder
    if rf.endswith('/'):
        rf = rf.rstrip('/')
    # Chart folder
    cf = args.folder

    # Run number
    rn = os.path.basename(rf)

    m = MixLogParser(rf)
    # Run timestamp
    rts = m.ts

    f_prefix_name = "run_{}_{}_{}"
    file_name = cf + os.sep + f_prefix_name

    y = m.tpsV
    x = m.get_x_axis(y)
    single_plot(x, y, 'Elapsed Time (seconds)', 'tpsV', rts,
                file_name.format(rn, rts, 'tpsV'), "Run {}".format(rn))

    y = m.all_transactions
    x = m.get_x_axis(y)

    single_plot(x, y, 'Elapsed Time (seconds)', 'Overall Transactions', rts,
                file_name.format(rn, rts, 'tps'), "Run {}".format(rn))

    d = m.get_all_tx_dict()

    multi_plot(d, "Elapsed Seconds", "Transactions", rts,
               file_name.format(rn, rts, 'tps_all'), "Run {}".format(rn))






