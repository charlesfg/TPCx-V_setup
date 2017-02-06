from matplotlib import pyplot as plt


def single_plot(x, y, x_label, y_label, ts, out_file=None):

    plt.figure(figsize=(8, 4), dpi=360)
    line, = plt.plot(x, y)
    plt.setp(line, color='g', linewidth=0.7, marker='+', ms=3)
    plt.ylabel(y_label)
    plt.xlabel(x_label)
    plt.grid(True)
    plt.title('Run {} '.format(ts))
    # line.set_label("Run 20170124-\n171536")
    # plt.legend(loc="lower left", bbox_to_anchor=(0.1, 0.1))
    if out_file:
        plt.savefig(out_file, dpi=300, bbox_inches='tight')
    else:
        plt.show()


if __name__ == '__main__':
    pass