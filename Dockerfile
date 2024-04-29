FROM ubuntu:22.04

# for the VNC connection
EXPOSE 5900
# for the browser VNC client
EXPOSE 5901
# Use environment variable to allow custom VNC passwords
ENV VNC_PASSWD=123456

# Default TimeZone
ENV TZ=Etc/UTC
ENV PUID=1000
ENV PGID=1000


# Make sure the dependencies are met
RUN apt-get update -y 
RUN apt-get install -y --no-install-recommends \
    tigervnc-standalone-server \
    tigervnc-common \
    tigervnc-tools \
    fluxbox \
    eterm \
    xterm \
    git \
    net-tools \
    python3 \
    python3-numpy \
    ca-certificates \
    scrot

# Install VNC. Requires net-tools, python and python-numpy
RUN git clone --branch v1.4.0 --single-branch https://github.com/novnc/noVNC.git /opt/noVNC
RUN git clone --branch v0.11.0 --single-branch https://github.com/novnc/websockify.git /opt/noVNC/utils/websockify
RUN ln -s /opt/noVNC/vnc.html /opt/noVNC/index.html

# Add Xterm entry to the container
RUN echo "?package(bash):needs=\"X11\" section=\"DockerCustom\" title=\"Xterm\" command=\"xterm -ls -bg black -fg white\"" >> /usr/share/menu/custom-docker && update-menus

# Install OBS
RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:obsproject/obs-studio
RUN apt-get update -y
RUN apt-get install -y obs-studio

# Clean
RUN apt-get clean -y
RUN rm -rf /var/lib/apt/lists/*

# Add OBS entry to the container
RUN echo "?package(bash):needs=\"X11\" section=\"DockerCustom\" title=\"OBS Screencast\" command=\"obs\"" >> /usr/share/menu/custom-docker && update-menus


# Set timezone
RUN echo ${TZ} > /etc/timezone

# Add in a health status
HEALTHCHECK --start-period=10s CMD bash -c "if [ \"`pidof -x Xtigervnc | wc -l`\" == "1" ]; then exit 0; else exit 1; fi"


# Add in non-root user
RUN groupadd -g ${PGID} obs
RUN useradd -m -s /bin/bash -g obs -u ${PUID} obs

# create obs-studio config dir
RUN mkdir -p /home/obs/.config/obs-studio
RUN ln -s /home/obs/.config/obs-studio /config
# change owner and permission of home directory
RUN chown -R obs:obs /home/obs
RUN chmod -R 700 /home/obs

# Copy various files to their respective places
RUN mkdir -p /opt/container
RUN chown -R obs:obs /opt/container
COPY --chown=obs:obs container_startup.sh /opt/container/container_startup.sh
COPY --chown=obs:obs x11vnc_entrypoint.sh /opt/container/x11vnc_entrypoint.sh
RUN chmod -R 755 /opt/container

USER obs

ENTRYPOINT ["/opt/container/container_startup.sh"]