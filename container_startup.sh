#!/bin/bash
OUR_IP=$(hostname -i)

# start VNC server (Uses VNC_PASSWD Docker ENV variable)
mkdir -p $HOME/.vnc && echo "$VNC_PASSWD" | vncpasswd -f > $HOME/.vnc/passwd
# Remove potential lock files created from a previously stopped session
rm -rf /tmp/.X*
vncserver :0 -localhost no -nolisten -rfbauth $HOME/.vnc/passwd -xstartup /opt/container/x11vnc_entrypoint.sh
# start noVNC web server
/opt/noVNC/utils/novnc_proxy --vnc localhost:5900 --listen 5901 &

echo -e "\n\n------------------ VNC environment started ------------------"
echo -e "\nVNCSERVER started on DISPLAY= $DISPLAY \n\t=> connect via VNC viewer with $OUR_IP:5900"
echo -e "\nnoVNC HTML client started:\n\t=> connect via http://$OUR_IP:5901/?password=$VNC_PASSWD\n"

# CLEANUP Close OBS on container exit

# Define cleanup procedure
cleanup() {
  echo "Killing $(pidof obs)"
  kill $(pidof obs)
  sleep 5s
  echo "Container stopped, performing cleanup..."
}

#Trap SIGTERM
trap cleanup SIGTERM

# Start OBS

# base command

# Disables the unclean shutdown detection that would prompt a safe mode start
OBS_START_COMMAND="obs --disable-shutdown-check"

# Automatically start streaming.
if [ "$OBS_START_STREAMING" == "true" ]; then
  OBS_START_COMMAND="${OBS_START_COMMAND} --startstreaming"
fi

# Automatically start recording.
if [ "$OBS_START_RECORDING" == "true" ]; then
  OBS_START_COMMAND="${OBS_START_COMMAND} --startrecording"
fi

# Start minimized to system tray.
if [ "$OBS_MINIMIZE_TO_TRAY" == "true" ]; then
  OBS_START_COMMAND="${OBS_START_COMMAND} --minimize-to-tray"
fi

# https://obsproject.com/kb/launch-parameters
OBS_START_COMMAND="${OBS_START_COMMAND} ${OBS_LAUNCH_PARAMETERS}"


echo "Starting OBS with command: '${OBS_START_COMMAND}'"

DISPLAY=:0.0 ${OBS_START_COMMAND} & DISPLAY=:0.0 wait $!
