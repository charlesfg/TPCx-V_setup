#!/usr/bin/python
# -*- coding: utf-8 -*-
from __future__ import  print_function
import os

import re


def get_int_array(line, sep=','):
    a = [int(x) for x in line.split(sep)]
    return a


class MixLogParser:
    def __init__(self, folder):
        mfile = "mixlog_validation.log"
        self.all_transactions = None
        self.all_transactions_count = None
        self.trade_result = None
        self.trade_order = None
        self.trade_lookup = None
        self.trade_update = None
        self.trade_status = None
        self.customer_position = None
        self.broker_volume = None
        self.security_detail = None
        self.market_feed = None
        self.market_watch = None
        # Timestamp for the Run
        self.ts = None
        self.stats_to_collect = [
            ("trade_order", "Trade-Order Transactions:"),
            ("trade_result", "Trade-Result Transactions:"),
            ("trade_lookup", "Trade-Lookup Transactions:"),
            ("trade_update", "Trade-Update Transactions:"),
            ("trade_status", "Trade-Status Transactions:"),
            ("customer_position", "Customer-Position Transactions:"),
            ("broker_volume", "Broker-Volume Transactions:"),
            ("security_detail", "Security-Detail Transactions:"),
            ("market_feed", "Market-Feed Transactions:"),
            ("market_watch", "Market-Watch Transactions:")
        ]

        self.parse(folder + os.sep + mfile)
        self.tpsV = [x/30.0 for x in self.trade_result]
        self.samples = len(self.trade_result)

    def get_x_axis(self, array):
        return [x * 30 for x in xrange(1, len(array) + 1)]

    def parse(self, mfile):
        with open(mfile) as f:
            section = 0
            l = f.readline()
            while l:
                m = re.search("Mixlog data for benchmark with run timestamp:\s+(\S+)", l)
                if m:
                    self.ts = m.group(1)
                if re.search("^={50,}",l):
                    # Using the ==== lines to define sections inside the mixlog file
                    section += 1
                if re.match("All Transactions", l):
                    l = f.readline()
                    self.all_transactions = get_int_array(l)
                    self.all_transactions_count = sum(self.all_transactions)
                for var, pattern in self.stats_to_collect:
                    if re.match(pattern, l) and section == 1:
                        l = f.readline()
                        setattr(self, var, get_int_array(l))
                l = f.readline()
        pass


def get_trade_results():
    folder = "/home/charles/Dropbox/Phd Portugal/oxum/31/results/20170124-171536"
    m = MixLogParser(folder)
    return m.trade_result


if __name__ == '__main__':
    folder = "/home/charles/Dropbox/Phd Portugal/oxum/31/results/20170124-171536"
    m = MixLogParser(folder)
    print(m.x_axis)
    print(len(m.x_axis))
    print(m.trade_order)
    print(len(m.trade_order))
    print(len(m.trade_status))
    print(m.trade_result)
    print(len(m.trade_result))
    print(m.all_transactions)
    print(len(m.all_transactions))
    print(m.all_transactions_count)

