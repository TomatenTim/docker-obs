# Dockerised OBS

A Docker container that runs OBS in a virtual desktop environment that can be accessed using VNC in the Browser

---

Heavily "inspired" by [`bandi13/docker-obs`](https://github.com/bandi13/docker-obs) and [`bandi13/gui-docker`](https://github.com/bandi13/gui-docker)

## Changes: 
- Restructured the Dockerfiles
- Bundled both Dockerfiles from both repos
- OBS autostart
- option to automatically start streaming/recording
- option to minimize to tray on start

## Usage

- Run the `docker-compose.yml`
- Connect to `http://<server-ip>:5901` in the Browser
- Login using the `VNC_PASSWD` (default: `123456`)
- Setup obs in the container
- add environment variables to your liking 
  - `OBS_START_STREAMING` Starts streaming on container start
  - `OBS_START_RECORDING` Starts recording on container start
  - `OBS_MINIMIZE_TO_TRAY` minimizes the obs windows to the tray icon on start
  - `OBS_LAUNCH_PARAMETERS` custom launch parameters (see [OBS docs](https://obsproject.com/kb/launch-parameters))