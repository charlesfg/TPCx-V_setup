# Folder where will hosted the reports
html_base = '/var/www'
template_html = 'run_/template.html'

try:
    from local_settings import *
except ImportError:
    pass

