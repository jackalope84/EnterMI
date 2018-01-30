#!/bin/bash

# Bash script for updating Linux
#   Author: Floris van Enter
#   Date: 2018-01-30

sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get -y dist-upgrade
sudo apt-get -y autoremove
sudo reboot