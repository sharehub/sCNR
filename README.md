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
This script will merge the adjacent IP rangs if they less than a GAP(we use 2^19) defined by user. By this way,we could make the size of this routing table very tiny but still cover 100% of chinese IP. 

Of course, it will also covere some other Asia(Hongkong, Taiwan, etc) IP rangs that not belong to China. But as we see from statistic, most of the international IP traffic is finally going to EU/NAM region, which will still rightly routed. So, consider this weight, it still have 99% accuracy.
