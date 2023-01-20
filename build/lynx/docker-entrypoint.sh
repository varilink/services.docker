#!/usr/bin/env bash

set -e

cat /addn-hosts >> /etc/hosts

lynx -accept_all_cookies $1
