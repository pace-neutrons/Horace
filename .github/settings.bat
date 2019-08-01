#!/bin/bash
#
# Set up the username and user e-mail variables
#user.name=abuts
#user.email=Alex.Buts@stfc.ac.uk
#
#echo "one "
git config --global core.autocrlf true
#echo "two"
git config --global core.eof native
#echo "three "
git config --global -l
#
echo "set up:"
echo ">>git config --global user.name [you github user name]"
echo " and "
echo ">>git config --global user.email [your github email]"
echo "variables if they have not been already set up"
pause
