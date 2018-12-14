import matplotlib
matplotlib.use('Agg')

from matplotlib import pyplot as plt

vlines_limits = [0, 8340]
vlines_ramp = [120]
vlines_phases = [840, 1560, 2280, 3000, 3720, 4440, 5160, 5880, 6600, 7320, 8040]

def grid_chart(plt,default_cfg):

    if default_cfg:
        plt.grid(False)
        for x in vlines_limits:
            plt.axvline(x=x, linewidth=0.3, linestyle='-', color='red')
        for x in vlines_ramp:
            plt.axvline(x=x, linewidth=0.4, linestyle='-', color='gray')
        for x in vlines_phases:
            plt.axvline(x=x, linewidth=0.5, linestyle='-', color='black')
    else:
        plt.grid(True)


def single_plot(x, y, x_label, y_label, y_max, ts, out_file=None, title=None, vlines=None, default_cfg=True):

    plt.figure(figsize=(8, 4), dpi=360)
    line, = plt.plot(x, y)
    plt.setp(line, color='g', linewidth=0.7, marker='+', ms=3)
    plt.ylabel(y_label)
    plt.ylim(ymax=y_max)
    plt.xlabel(x_label)

    grid_chart(plt, default_cfg)

    if vlines and len(vlines) > 0:
        for x in vlines:
            plt.axvline(x=x, linewidth=0.7, linestyle=':', color='black')

    if title:
        plt.title(title)
    else:
        plt.title('Run {} '.format(ts))

    if out_file:
        plt.savefig(out_file, dpi=300, bbox_inches='tight')
    else:
        plt.show()

def multi_plot(y_dict,  x_label, y_label, y_max, ts, out_file=None, title=None,
               vlines=None, default_cfg=True):
    """
    :param x:
    :param y_dict: with spec =  'str(label): array(values)'
    :param x_label:
    :param y_labels:
    :param ts:
    :param out_file:
    :return:
    """

    fig = plt.figure(figsize=(8, 4), dpi=360)
    ax = plt.subplot(111)

    for k, v in y_dict.iteritems():
        plt.plot([x * 30 for x in xrange(1, len(v) + 1)], v, linewidth=0.7, ms=3, label=k)

    plt.ylabel(y_label)
    plt.ylim(ymax=y_max)
    plt.xlabel(x_label)
    grid_chart(plt, default_cfg)

    if vlines and len(vlines) > 0:
        for x in vlines:
            plt.axvline(x=x, linewidth=0.7, linestyle=':', color='black')

    if title:
        plt.title(title)
    else:
        plt.title('Run {} '.format(ts))

    # Shrink current axis's height by 10% on the bottom
    box = ax.get_position()
    ax.set_position([box.x0, box.y0 + box.height * 0.1,
                     box.width, box.height * 0.9])

    # Put a legend below current axis
    ax.legend(loc='upper center', bbox_to_anchor=(0.5, -0.15),
              fancybox=False, shadow=True, ncol=6)

    if out_file:
        plt.savefig(out_file, dpi=300, bbox_inches='tight')
    else:
        plt.show()

if __name__ == '__main__':
    pass
