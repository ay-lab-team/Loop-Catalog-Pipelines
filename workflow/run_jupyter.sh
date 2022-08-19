#!/bin/bash

# add your email address here
EMAIL=kfetter@lji.org

# by default we use the system install of python 3.7.3
export LD_LIBRARY_PATH=/mnt/apps/python/python-3.7.3/lib:/mnt/apps/libs/openssl/openssl-1.1.1c/lib:$LD_LIBRARY_PATH
JUPYTER=/mnt/apps/python/python-3.7.3/bin/jupyter

# if instead, you want to use a virtual environemnt / pyenv that you've already created, replace the above with
#  - for virtualenv:
# source /path/to/virtual_env_with_jupyter/bin/activate
# JUPYTER=jupyter
#
#  - for pyenv:
# pyenv activate virtual_env_with_jupyter
# JUPYTER=jupyter
#

# find a port
PORT=$((RANDOM % 500 + 12000))

(while [ -z $SERVER_URL ]
do
sleep 10
# get the running server
SERVER_URL=`$JUPYTER notebook list | grep ^http | grep $PORT | cut -f1 -d" "`
#TODO  handle an error if the notebook is not started
done

# notify the user
mail -s "jupyter running at $SERVER_URL" $EMAIL <<< "Jupyter running at $SERVER_URL"
) &

# start jupyter
$JUPYTER \
notebook \
--no-browser \
--port=$PORT \
--ip=$(hostname -f)
