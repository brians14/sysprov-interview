#!/usr/bin/env python3
from netaddr import *

dotted_address = "192.168.101.255"

subnetlist = [
    '192.168.1.0/22',
    '192.168.10.0/24',
    '192.168.20.0/22',
    '192.168.100.0/20',
    '192.168.101.0/24',
]


def subnetsHaveHosts(subnets, address):
    inSubnet = False
    for subnet in subnets:
        ipset = IPSet([subnet])
        ipaddr = IPAddress(address)
        if ipaddr in ipset:
            inSubnet =  True
            break
    return inSubnet


if(subnetsHaveHosts(subnetlist, dotted_address)):
    print("Addres IS in subnet list")
else:
    print("Address NOT in subnet list")
