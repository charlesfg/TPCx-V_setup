from __future__ import print_function

import argparse
import re

know_errors = {
    "libxl:": [
        # Memory Error, maybe running out of memory"
        "libxl: notice: libxl_numa.c:(\d+):libxl__get_numa_candidate: NUMA placement failed, performance might be affected",
        "libxl: error: libxl_domain.c:(\d+):domain_destroy_cb: (Domain \d+):Destruction of domain failed",
        "libxl: error: libxl_aoutils.c:\d+:async_exec_timeout: killing execution of /etc/xen/scripts/block add because of timeout",
        "libxl: error: libxl_create.c:\d+:domcreate_launch_dm: Domain \d+:unable to add disk devices",
        "libxl: error: libxl_exec.c:\d+:libxl_report_child_exitstatus: /etc/xen/scripts/block remove \[\d+\] exited with error status \d+",
        "libxl: error: libxl_device.c:\d+:device_hotplug_child_death_cb: script: /etc/xen/scripts/block failed; error detected.",
        "libxl: error: libxl_exec.c:\d+:libxl_report_child_exitstatus: /etc/xen/scripts/block remove \[\d+\] exited with error status \d+",
        "libxl: error: libxl_device.c:\d+:device_hotplug_child_death_cb: script: /etc/xen/scripts/block failed; error detected.",
        "libxl: error: libxl_domain.c:\d+:libxl__destroy_domid: Domain \d+:Non-existant domain",
        "libxl: error: libxl_domain.c:\d+:domain_destroy_callback: Domain \d+:Unable to destroy guest ",
        "libxl: error: libxl_domain.c:\d+:domain_destroy_cb: Domain \d+:Destruction of domain failed",
    ]
}

error_prefixes = [x for x in know_errors.iterkeys()]

if __name__ == '__main__':

    # for l in ft:
    #     print has_error(l)
    #
    # sys.exit(1)

    parser = argparse.ArgumentParser(description='Script that parse TPCx-V logs for errors')
    parser.add_argument('fp', metavar='file_paths', type=str, nargs='+', help='File to POST Process')

    args = parser.parse_args()

    for fp in args.fp:
        with open(fp) as f:
            for l in f.readlines():
                # if any([l.startswith(x) for x in error_prefixes]):
                for p in error_prefixes:
                    if l.startswith(p):
                        for e in know_errors[p]:
                            if not re.match(e, l):
                                print("Error not found in " + fp + ":\n" + l)
