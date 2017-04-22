from matplotlib import pyplot as plt


def single_plot(x, y, x_label, y_label, ts, out_file=None, title=None):

    plt.figure(figsize=(8, 4), dpi=360)
    line, = plt.plot(x, y)
    plt.setp(line, color='g', linewidth=0.7, marker='+', ms=3)
    plt.ylabel(y_label)
    plt.xlabel(x_label)
    plt.grid(True)

    if title:
        plt.title(title)
    else:
        plt.title('Run {} '.format(ts))

    if out_file:
        plt.savefig(out_file, dpi=300, bbox_inches='tight')
    else:
        plt.show()

def multi_plot(y_dict,  x_label, y_label, ts, out_file=None, title=None):
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
    plt.xlabel(x_label)
    plt.grid(True)

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