host = 'http://oxum.speed.dcc.ufmg.br'

authenticate = True
user = "asda"
passwd = "private"


# Default of munin is 800x400
chart_x = '800'
chart_y = '400'

# Plugins:
#  xen traffic all

chart_settings = {
    'oxum.speed.dcc.ufmg.br/xenhost.oxum.speed.dcc.ufmg.br': [
        'xen_cpu_time', 'xen_disk', 'diskstats_iops', 'diskstats_latency',
        'diskstats_throughput', 'diskstats_utilization',
        'netstat', 'xen_cpu_v2', 'xen_traffic_all',  'xen_net'
    ]
}

LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'verbose': {
            'format': '%(levelname)s %(asctime)s %(module)s %(process)d %(thread)d %(message)s'
        },
    },
    'handlers': {
        'console':{
            'level':'DEBUG',
            'class':'logging.StreamHandler',
            'formatter': 'verbose',
        },
        'file': {
            'level': 'DEBUG',
            'class': 'logging.FileHandler',
            'filename': '/var/tmp/tpc_report.log',
            'formatter': 'verbose',
        },
    },
    'loggers': {
        '__main__': {
            'handlers':['console','file'],
            'propagate': True,
            'level':'DEBUG',
        },
    }
}

try:
    from local_settings import *
except ImportError:
    pass

