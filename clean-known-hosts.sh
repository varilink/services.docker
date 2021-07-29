#!/usr/bin/env bash

# Clean entries from known_hosts after containers have been recreated for any
# reason.

for PORT in 5522 5523 5524 5525
do

  ssh-keygen -f ~/.ssh/known_hosts -R [localhost]:$PORT

done
