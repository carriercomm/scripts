#!/bin/bash

/sbin/iptables -F -t nat

/sbin/iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

sysctl -w net.ipv4.ip_forward=1
