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
        self.data_maintenance = None
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
            ("market_watch", "Market-Watch Transactions:"),
            ("data_maintenance", "Data-Maintenance Transactions:")
        ]

        import os
        for root, dirs, files in os.walk(folder):
            for f in files:
                if f == mfile:
                    self.parse(root + os.sep + f)

        self.tpsV = [x/30.0 for x in self.trade_result]

        # Maximum number of samples
        self.samples = max(map(len, self.get_all_tx_dict().itervalues()))


    def get_all_tx_dict(self):

        d = {
            "BV": self.broker_volume,
            "CP": self.customer_position,
            "DM": self.data_maintenance,
            "MF": self.market_feed,
            "MW": self.market_watch,
            "SD": self.security_detail,
            "TL": self.trade_lookup,
            "TS": self.trade_status,
            "TO": self.trade_order,
            "TR": self.trade_result,
            "TU": self.trade_update
        }

        return d

    def get_x_axis(self, value):
        if list == type(value):
            size = len(value)
        else:
            size = value
        return [x * 30 for x in xrange(1, size + 1)]

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

