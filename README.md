# TARI container

Everything needed to build the workspace's development container and run it:
two image definitions and one lifecycle script. Nothing here depends on the
rest of the workspace existing at build time, so the image can be rebuilt on a
machine that has only this repository.

Why a container at all: the ROS 2 stack targets Ubuntu 22.04, and the
development host does not have to be Ubuntu. Everything importing `rclpy` runs
in here; plain dataguzzler-python and spatialnde2 work runs on the host.

## Layout

    ros2_docker.sh              build, create, start, stop and enter the container
    entrypoint.sh               what runs inside it at startup
    images/kasm-base/           Ubuntu 22.04 plus an XFCE desktop over KasmVNC
    images/ros2-iron-jammy/     ROS 2 Iron, Gazebo, MoveIt, and the Python stack

The two images chain: `ubuntu:22.04` -> `cloud-workstations/kasm-cloud-workstation:latest`
-> `ros2-iron-jammy:latest`. The ROS image is `FROM` the base, so the base must
be built first. `ros2_docker.sh build` does both in order.

## From nothing

    git clone <this repo> <workspace>/container
    <workspace>/container/ros2_docker.sh build     # both images, from scratch
    <workspace>/container/ros2_docker.sh start     # create and start it
    <workspace>/container/ros2_docker.sh shell     # a shell inside, as 'user'

The desktop is served at <http://localhost:8443>. It connects with no login
prompt, because the VNC server runs with basic auth disabled; the container is
reachable only from the host.

`build` tags the existing image as `ros2-iron-jammy:rollback` before
overwriting `:latest`. Docker only moves a tag on success, but a *successful*
build of a subtly different image is the case worth being able to undo.

## What it expects of the workspace

The script lives at `<workspace>/container` and resolves every mount from its
own location, not from the directory it is invoked in, so it can be run from
anywhere. It mounts, into the container:

| Host | Container |
|---|---|
| `<workspace>/ros_ws` | `/home/user/ros_ws` |
| `<workspace>/{dataguzzler-python,spatialnde2,ROS-Scanning,spatialnde2-ec-functions,dgpython-*}` | `/home/user/software_ws/<name>` |
| `<workspace>/scandata` | `/home/user/scandata` |
| `<workspace>/container_local` | `/home/user/.local` |
| `$HOME/.ssh`, `/tmp/.X11-unix` | the same paths |

Directories that do not exist yet are created. A repository that has not been
cloned yet mounts as an empty directory rather than failing, so a partial
workspace still starts.

`container_local` is why editable installs survive a recreate: it is the
container's `~/.local`, kept on the host.

**`restart` is remove plus create.** Everything above survives it because it is
a mount; anything written elsewhere inside the container does not.

## Things worth knowing

**`docker exec` gives you an empty `DISPLAY`.** Anything with a GUI, or that
talks to one over IPC, needs `DISPLAY=:10` plus `XDG_RUNTIME_DIR` and
`DBUS_SESSION_BUS_ADDRESS`, because a non-interactive shell never sources the
profile that exports them. `ros2_docker.sh shell` sets all three.

**Run container commands as `user`, not root.** `docker exec` defaults to root,
and the cell's nodes run as `user`. A root client discovers every topic and
receives nothing from any of them, with no error anywhere.

**GPU OpenCL does not work here and cannot be fixed at this layer.** The
runtime this GPU class needs depends on a newer libc and libstdc++ than Ubuntu
22.04 ships, and the ROS distribution is what pins 22.04. The loader falls back
to a CPU implementation, which is correct but slow, and says so at startup. The
Intel runtime is still installed because it does work on GPUs the older driver
supports.

**The image is large** (~20 GB) and a full build takes a long time. Prefer
`start` over `build`; `build` is for a changed Dockerfile or a new machine.
