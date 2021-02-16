#!/bin/bash

_TENSORBOARD_LOGDIR=/tmp
_TENSORBOARD_PORT=6006

if [ "${TENSORBOARD_LOGDIR}x" != x ]
then
  _TENSORBOARD_LOGDIR=${TENSORBOARD_LOGDIR}
fi
if [ "${TENSORBOARD_PORT}x" != x ]
then
  _TENSORBOARD_PORT=${TENSORBOARD_PORT}
fi
if [ "${TENSORBOARD_RELOAD_INTERVAL}x" != x ]
then
  _TENSORBOARD_RELOAD_INTERVAL=${TENSORBOARD_RELOAD_INTERVAL}
fi


LISTEN_IP=`ip route list scope link | awk '{ print $7 }'`

# Run Tensorboard
echo "Start Tensorboard at http://${LISTEN_IP}:${_TENSORBOARD_PORT}"
echo "Tensorboard reads logs from ${_TENSORBOARD_LOGDIR}"
tensorboard  --host ${LISTEN_IP} --logdir ${_TENSORBOARD_LOGDIR} --port ${_TENSORBOARD_PORT} --reload_interval ${_TENSORBOARD_RELOAD_INTERVAL} &

# Run jupyter
echo "Start Jupyter notebook at http://${LISTEN_IP}:${JUPYTERPORT}"
jupyter-notebook --ip ${LISTEN_IP} --port=${JUPYTERPORT} -y --no-browser --notebook-dir=/home/${user}/notebooks --log-level=INFO 

