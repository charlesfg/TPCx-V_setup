import argparse
import os
import shutil
import re
import time
from bs4 import BeautifulSoup

from settings import html_base, template_html, site_base

html_template_dir = os.path.dirname(os.path.abspath(__file__)) + os.sep + '../html_template'

def check_setup():
    """
    List the runs that already exist on the site
    Also check if the site was not configured and setup it there
    :return:  List of runs that resides in the site
    """

    # check if the initial setup is already done
    html_base_files = os.listdir(html_base)
    index = 'index.html'
    if index not in html_base_files:
        shutil.copy(html_template_dir + os.sep + index, html_base + os.sep + index)

    initial_files = ['css', 'fonts', 'js']
    for i in initial_files:
        if i not in html_base_files:
            shutil.copytree(html_template_dir + os.sep + i, html_base + os.sep + i)
    pass


def list_runs():
    """
    List the runs that already exist on the site
    Also check if the site was not configured and setup it there
    :return:  List of runs that resides in the site
    """
    dirs = filter(os.path.isdir, [html_base + os.sep + x for x in os.listdir(html_base)])
    runs = [os.path.basename(x) for x in filter(lambda x: os.path.basename(x).startswith('run_'), dirs)]

    runs.sort()

    return runs


def update_global_index(rn, tpsv, report_date, alias):

    index = html_base + os.sep + 'index.html'
    content = read_file_at_once(index)

    if alias:
        r_name = "{} - {}".format(rn, alias)
    else:
        r_name = rn

    run_ref = "<a href='{}/run_{}/index.html'>{}</a>".format(site_base, rn, r_name)

    s = re.search("(\d+)##RUN_COUNT", content, re.DOTALL | re.MULTILINE)
    count = int(s.group(1)) + 1
    line = "<tr><th scope=\"row\">{}</th><td>{}</td><td>{}</td><td>{}</td></tr>\n<!--{}##RUN_COUNT-->"
    content = re.sub("<!--\d+##RUN_COUNT-->", line.format(count, run_ref,  tpsv, report_date, count), content)



    write_to_file(index, content)
    pass


def read_file_at_once(input_file):
    with open(input_file, 'r') as content_file:
        content = content_file.read()
    return content


def write_to_file(out_file, out_str):
    with open(out_file, 'w') as content_file:
        content_file.write(out_str)


def update_side_bar(runs):
    index_to_update = []

    for root, dirs, files in os.walk(html_base):
        for f in files:
            if f == 'index.html':
                index_to_update.append(root + os.sep + f)

    sb_pttr = re.compile(r"""<!--##RUN_LINK_START.*RUN_LINK_END##-->""", re.MULTILINE | re.DOTALL)

    sb_html = ["<!--##RUN_LINK_START##-->"]
    for i in runs:
        sb_html.append("<li><a href='{}/index.html'>{}</a></li>".format(site_base + os.sep + i,
                                                                        i.upper().replace("_", " ")))
    # Close the wrap markup
    sb_html.append("<!--##RUN_LINK_END##-->")

    for i in index_to_update:
        content = read_file_at_once(i)
        content = re.sub(sb_pttr, "\n".join(sb_html), content)
        write_to_file(i, content)

    pass


def generate_run_report(rn, tpsv, report_date, transaction_rate, transaction_mix, alias, test_time, measuremnt_time):

    # first create the run report
    run_report_dir = html_base + os.sep + "run_" + rn

    if not alias:
        alias = '-'

    if os.path.exists(run_report_dir):
        shutil.rmtree(run_report_dir)
    os.mkdir(run_report_dir)

    # Read the template in memory
    template_content = read_file_at_once(html_template_dir + os.sep + template_html)
    template_content = re.sub("##RUN##", "Run {}".format(rn), template_content)
    template_content = re.sub("##RUN_DATE##", report_date, template_content)
    template_content = re.sub("##RUN_TPSV##", tpsv, template_content)
    template_content = re.sub("##ALIAS##", alias, template_content)
    template_content = re.sub("##TEST_TIME##", test_time, template_content)
    template_content = re.sub("##TOTAL_TIME##", measuremnt_time, template_content)
    template_content = re.sub("##RUN_TRANSACTION_RT##", str(transaction_rate), template_content)
    template_content = re.sub("##RUN_TRANSACTION_MIX##", str(transaction_mix), template_content)

    img_dest_folder = run_report_dir + os.sep + "img"
    shutil.move(args.folder, img_dest_folder)
    images = os.listdir(img_dest_folder)

    system_images = filter(lambda x: x.startswith('system_run_'), images)
    tpc_images = filter(lambda x: x.startswith('run_'), images)

    system_images_html = []
    system_images.sort()
    for i in system_images:
        system_images_html.append('<div class="chart"><img src="img/{}"/></div>'.format(i))

    template_content = re.sub("##RUN_SYSTEM_CHARTS##", "\n".join(system_images_html), template_content)

    tpc_images_html = []
    tpc_images.sort()
    for i in tpc_images:
        tpc_images_html.append('<div class="chart"><img src="img/{}"/></div>'.format(i))

    template_content = re.sub("##RUN_TPC_CHARTS##", "\n".join(tpc_images_html), template_content)

    write_to_file(run_report_dir + os.sep + 'index.html', template_content)

    pass


def parse_run_info(rf):

    if rf.endswith('/'):
        rf = rf.rstrip('/')

    # Run number
    rn = os.path.basename(rf)

    run_tpc_report = rf + os.sep + 'Executive Summary Report.html'
    try:
        html_doc = open(run_tpc_report)
    except IOError:
        return None
    soup = BeautifulSoup(html_doc, 'html.parser')
    t = soup.find_all('table')

    run_info = {
        "rn" : rn ,
        "transaction_rate" : t[7],
        "transaction_mix" : t[8],
        "total_tx" : t[9].text.split('\n')[2][18:],
        "run_time" : t[9].text.split('\n')[5][20:],
        "tpsv" : t[4].text.split('\n')[-6][4:],
        "report_date" : t[0].text.split('\n')[8]
    }
    return run_info


if __name__ == '__main__':

    parser = argparse.ArgumentParser(description='Generate the html report on place configured on settings.'
                                                 'Create the initial setup if needed')
    parser.add_argument('-r', '--run-folder', type=str, help='The folder where lives the results for the run. '
                                                             'Named by the integer that identifies it!', required=True)
    parser.add_argument('-f', '--folder', type=str, help='The folder where lives the chart images for the run. ',
                        required=True)

    parser.add_argument('-s', '--start-test', type=int, help='Start time (in seconds) of the parallel test load ',
                        required=False)

    parser.add_argument('-e', '--end-test', type=int, help='End time (in seconds) of the parallel test load ',
                        required=False)

    parser.add_argument('-a', '--alias', type=str, help='Meaningful alias for the test',
                        required=False)

    args = parser.parse_args()

    # Check if web site is ok
    check_setup()

    alias = start_t = end_t = None

    if args.alias :
        alias = args.alias

    if args.start_test and args.start_test > 0:
        start_t = args.start_test

    if args.end_test and args.end_test > 0:
        end_t = args.end_test


    # Run folder
    rf = args.run_folder

    run_info = parse_run_info(rf)
    rn = run_info["rn"]
    tpsv = run_info["tpsv"]
    report_date = run_info["report_date"]
    transaction_rate = run_info["transaction_rate"]
    transaction_mix = run_info["transaction_mix"]
    measuremnt_time = run_info["run_time"]

    if start_t and end_t and end_t > start_t:
        test_time = time.strftime('%H:%M:%S', time.gmtime(end_t - start_t))
    else:
        test_time = '-'

    generate_run_report(rn, tpsv, report_date, transaction_rate, transaction_mix, alias, test_time, measuremnt_time)

    # update the global index  table of runs
    update_global_index(rn, tpsv, report_date, alias)

    # Replace the Runs on side bar
    runs = list_runs()
    update_side_bar(runs)









