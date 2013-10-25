sCNR
====

精简中国IP地址表，是一个只有不到200条记录但覆盖**100%**中国IP的IP网段列表。相对完备精确的中国IP地址表近10000条记录，该表简单精小但仍然能保证**99%**的正确率（可能将其它亚洲国家的IP段也覆盖）

Small China Router(sCNR) that cover **100%** chinese IP but keep a small size(less than 200 IP/Mask pairs), avoid to use thousands of routing rules(exact CN IP/Mask pairs nearly 10,000 rules).

These IP list may contain other Asia countries/regions IP address, but it works correctly for **99%** cases.

sCNR.ip.list
------------

IP地址/掩码表

This file contain the raw IP/Mask pairs for general purpose

sCNR.openvpn.conf
-----------------

共OpenVPN使用的路由配置表（大陆版）

This file is intend for OpenVPN client route configuration

More Details
-------------
This script will merge the adjacent IP rangs if they are less than a GAP(we use 2^13 as default) defined by user. By this way,it makes the size of this routing table really small but still covers 100% of chinese IP. 

Of course, it will also covere a few other Asia(Hongkong, Taiwan, etc) IP rangs that do not belong to China. But some statistic show, most of the international IP traffic finally go to EU/NAM regions, which will still be rightly routed. So, consider these weight, it still could get 99% accuracy.
