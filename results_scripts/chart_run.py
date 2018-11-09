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

    parser.add_argument('-s', '--start-test', type=int, help='Start time (in seconds) of the parallel test load ',
                        required=False)

    parser.add_argument('-e', '--end-test', type=int, help='End time (in seconds) of the parallel test load ',
                        required=False)

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
    start_t = end_t = None

    if args.start_test and args.start_test > 0:
        start_t = args.start_test

    if args.end_test and args.end_test > 0:
        end_t = args.end_test


    f_prefix_name = "run_{}_{}_{}"
    file_name = cf + os.sep + f_prefix_name

    y = m.tpsV
    x = m.get_x_axis(y)
    if start_t and end_t:
        vlines = [start_t, end_t]
    else:
        vlines = None

    single_plot(x, y, 'Elapsed Time (seconds)', 'tpsV', 18,  rts,
                file_name.format(rn, rts, 'tpsV'), "Run {}".format(rn),
                vlines)

    y = m.all_transactions
    x = m.get_x_axis(y)

    single_plot(x, y, 'Elapsed Time (seconds)', 'Overall Transactions', 4500,  rts,
                file_name.format(rn, rts, 'tps'), "Run {}".format(rn), vlines)

    d = m.get_all_tx_dict()

    multi_plot(d, "Elapsed Seconds", "Transactions", 700,  rts,
               file_name.format(rn, rts, 'tps_all'), "Run {}".format(rn), vlines)






