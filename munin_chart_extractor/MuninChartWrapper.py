from settings import chart_y, chart_x, host, chart_settings, user, passwd, LOGGING

import urllib3

import argparse

import logging, logging.config

logging.config.dictConfig(LOGGING)

logger = logging.getLogger('__main__')


class MuninWrapper:

    def __init__(self, ts_start, ts_end):
        self.http = urllib3.PoolManager()
        self.ts_start = ts_start
        self.ts_end = ts_end


    def get_chart(self, vm, plugin):
        """
         Return the png data into memory or raises an error:
        """
        url = '{}/munin-cgi/munin-cgi-graph/{}/{}-pinpoint={},{}.png?&lower_limit=&upper_limit=&size_x={}&size_y={}'\
            .format(host, vm, plugin, self.ts_start, self.ts_end, chart_x, chart_y)

        r = self.http.request(
            'GET',
            url,
            headers=urllib3.make_headers(basic_auth='{}:{}'.format(user, passwd))
        )

        if r.status == 200:
            return r.data
        else:
            raise Exception("Error on retrieving chart !!\nstatus={}\nurl={}".format(url, r.status))

    def save_charts(self, prefix, folder):

        for vm, plugins in chart_settings.iteritems():
            for plugin in plugins:
                try:
                    r = m.get_chart(vm, plugin)
                except Exception as e:
                    logger.info("Error for vm={} and pluging={}\nskipping ...".format(vm, plugin))
                    logger.error(e)
                    continue
                with open("{}/{}-{}.png".format(folder, prefix, plugin), 'w') as f:
                    f.write(r)


if __name__ == '__main__':

    parser = argparse.ArgumentParser(description='Collect Charts on Munin based on parameters and settings file')
    parser.add_argument('-p', '--prefix', type=str, help='Prefix to use in every chart file name', required=True)
    parser.add_argument('-f', '--folder', type=str, help='Folder to store the chart files', required=True)
    parser.add_argument('-s', '--start-time', type=int, help='Start time in epoch seconds', required=True)
    parser.add_argument('-e', '--end-time', type=int, help='End time in epoch seconds', required=True)

    args = parser.parse_args()

    logger.debug("Collecting Munin charts with timestamps s={} e={}".format(args.start_time, args.end_time))

    m = MuninWrapper(ts_start=args.start_time, ts_end=args.end_time)
    m.save_charts(args.prefix, args.folder)

