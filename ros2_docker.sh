#!/bin/bash
set -e

# One container per workspace. The name is shared by default so that the usual
# commands and procedures keep working; set TARI_CONTAINER_NAME to run a second
# workspace alongside the first.
CONTAINER_NAME="${TARI_CONTAINER_NAME:-ros2-workstation}"
IMAGE_NAME="ros2-iron-jammy:latest"
BASE_IMAGE="cloud-workstations/kasm-cloud-workstation:latest"

# This script lives in <workspace>/container, and every mount below is relative
# to the workspace, NOT to the directory it happens to be invoked from. Resolve
# both from the script's own location so it works from anywhere.
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE="$(cd "${HERE}/.." && pwd)"

WS_DIR="${WORKSPACE}/ros_ws"
SOFTWARE_WS="${WORKSPACE}/software_ws"
CONTAINER_LOCAL="${WORKSPACE}/container_local"

function print_usage() {
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  start   - Create and start the ROS2 Docker container (or start if stopped)"
    echo "  stop    - Stop the running ROS2 Docker container"
    echo "  rm      - Remove the ROS2 Docker container"
    echo "  restart - Stop and remove the existing container, then start a fresh one"
    echo "  shell   - Open an interactive bash shell as 'user' inside the container"
    echo "  logs    - View the logs for KasmVNC and the container startup"
    echo "  build   - Build both images from scratch (base, then the ROS image)"
}

if [ $# -eq 0 ]; then
    print_usage
    exit 1
fi

COMMAND=$1

case "$COMMAND" in
    build)
        # The ROS image is FROM the base image, so the base has to exist first.
        # Tag a rollback before overwriting :latest -- docker only moves the tag
        # on success, but a SUCCESSFUL build of a subtly different image is the
        # case that costs time.
        if docker image inspect "${IMAGE_NAME}" >/dev/null 2>&1; then
            docker tag "${IMAGE_NAME}" "${IMAGE_NAME%%:*}:rollback"
            echo "Tagged the current image as ${IMAGE_NAME%%:*}:rollback"
        fi
        echo "Building ${BASE_IMAGE} ..."
        docker build -t "${BASE_IMAGE}" "${HERE}/images/kasm-base"
        echo "Building ${IMAGE_NAME} ..."
        docker build -t "${IMAGE_NAME}" "${HERE}/images/ros2-iron-jammy"
        echo "Done. Run \"$0 start\" to create the container."
        ;;
    start)
        # A container of this name may belong to a DIFFERENT workspace. Adopting
        # it would silently give you that workspace's sources under this one's
        # path, so compare what it actually has mounted and refuse instead.
        if [ "$(docker ps -aq -f name=^/${CONTAINER_NAME}$)" ]; then
            existing_ws="$(docker inspect "${CONTAINER_NAME}" \
                --format '{{range .Mounts}}{{if eq .Destination "/home/user/ros_ws"}}{{.Source}}{{end}}{{end}}' \
                2>/dev/null)"
            if [ -n "${existing_ws}" ] && [ "${existing_ws}" != "${WS_DIR}" ]; then
                echo "Container ${CONTAINER_NAME} already exists and belongs to another workspace:" >&2
                echo "    its ros_ws:   ${existing_ws}" >&2
                echo "    this ros_ws:  ${WS_DIR}" >&2
                echo "Use that workspace, or set TARI_CONTAINER_NAME to a different name." >&2
                exit 1
            fi
        fi

        # Check if container exists
        if [ "$(docker ps -aq -f name=^/${CONTAINER_NAME}$)" ]; then
            if [ "$(docker ps -q -f name=^/${CONTAINER_NAME}$)" ]; then
                echo "Container ${CONTAINER_NAME} is already running."
            else
                echo "Starting existing container ${CONTAINER_NAME}..."
                docker start ${CONTAINER_NAME}
            fi
        else
            echo "Creating and starting new container ${CONTAINER_NAME}..."
            # Ensure the local workspace directories exist
            mkdir -p "${WS_DIR}" "${SOFTWARE_WS}" "${CONTAINER_LOCAL}" "${WORKSPACE}/scandata"
            # A bind-mount source that does not exist is created by docker as a
            # root-owned directory, which then shadows a later checkout and is
            # not writable to remove. test_data is a separate repository and may
            # legitimately be absent, so make it rather than mount a surprise.
            mkdir -p "${WORKSPACE}/test_data"

            # --shm-size: docker defaults /dev/shm to 64 MB, and both spatialnde2
            # recordings and the FastDDS shared memory transport live there. A
            # 16000 sample A-scan is 64 KB, so a digitizer at 20 Hz fills 64 MB in
            # under a minute; the symptom is a SIGBUS inside numpy or
            # "RTPS_TRANSPORT_SHM Failed to create segment", not an out-of-space
            # error. tmpfs only consumes what is actually used, so this is a
            # ceiling rather than a reservation. Matches the host's own default.

            # --ulimit nofile: every live spatialnde2 recording holds an open fd
            # for its /dev/shm segment, and the default soft limit of 1024 is
            # reached after only a few hundred. A scan legitimately has that many
            # in flight, and a mutable math channel keeps them alive longer still.
            # The symptom is "POSIX runtime error 24 (Too many open files) ...
            # shared_memory_allocator_posix::calloc", after which the whole
            # process falls apart -- even the control port stops accepting.
            # The container's hard limit is 524288, so this is well within range.

            # scandata is SCAN_STORAGE_DIR: every acquired scan volume, trace
            # list, reconstructed mesh and generated X3D is written there. It
            # was NOT a mount, and `restart` is rm + start, so a container
            # recreate destroyed an afternoon of scans silently. Mounted now.
            #
            # test_data is the fixture repository (test_data_staging): recorded
            # scan datasets the host test suites open, and the generated
            # eddy-current response table that the SIMULATED instrument reads at
            # run time. Mounted READ-ONLY -- nothing in the container should
            # write a fixture, and the git-lfs fetch that populates it happens on
            # the host. Without it, EC_TABLE cannot name the table from where it
            # lives and ec_real_table_test.py skips every case in here.
            #
            # AT /opt, NOT UNDER /home/user, AND THAT IS NOT A STYLE CHOICE.
            # entrypoint.sh is `set -e` and runs `chown -R user:user /home/user`
            # before it starts anything. A read-only mount anywhere under that
            # path makes the chown fail, which aborts the entrypoint, which
            # fails kasm-init.service -- so the X server on :10 never starts.
            # What you then see is a cell that looks half-alive: gzserver runs,
            # the controllers execute, /profiles publishes (the simulated
            # Keyence is a CPU raycaster and needs no rendering), and gzclient
            # and rviz2 are dead with exit -6 while the Azure publishes nothing
            # at all, because libgazebo_ros_camera renders through OGRE and OGRE
            # needs X. Nothing in any of that points at a mount. Measured
            # 2026-10-04, by doing exactly this.
            #
            # TARI_TEST_DATA is passed in the environment rather than left to
            # test_data.py's walk-up search, which looks for a directory NAMED
            # test_data above the test file and would not find /opt/test_data.
            #
            # Do not comment inside the docker run below: every line ends in a
            # backslash, so the whole block is ONE logical line and a '#'
            # anywhere in it comments out every argument that follows.
            # NOTE: dgpython-ros2motion is deliberately NOT mounted into software_ws.
            # It lives in the ROS workspace (ros_ws/src/dgpython-ros2motion, mounted
            # below as /home/user/ros_ws) so colcon builds its action server and
            # interface, and so the dataguzzler-python module has exactly ONE path to
            # be pip-installed editable from. Mounting it in two places is what let
            # the two checkouts diverge.
            docker run -d --name ${CONTAINER_NAME} --privileged \
                -v /sys/fs/cgroup:/sys/fs/cgroup:rw --cgroupns=host \
                --network host --add-host $(cat /etc/hostname):127.0.0.1 \
                --device /dev/dri:/dev/dri \
                --shm-size=8g \
                --ulimit nofile=65536:65536 \
                -e INTEL_FORCE_PROBE=b090 \
                -v "${WS_DIR}:/home/user/ros_ws" \
                -v "${WORKSPACE}/dataguzzler-python:/home/user/software_ws/dataguzzler-python" \
                -v "${WORKSPACE}/spatialnde2:/home/user/software_ws/spatialnde2" \
                -v "${WORKSPACE}/ROS-Scanning:/home/user/software_ws/ROS-Scanning" \
                -v "${WORKSPACE}/dgpython-nidaqmx:/home/user/software_ws/dgpython-nidaqmx" \
                -v "${WORKSPACE}/dgpython-uniwest:/home/user/software_ws/dgpython-uniwest" \
                -v "${WORKSPACE}/dgpython-param-manager:/home/user/software_ws/dgpython-param-manager" \
                -v "${WORKSPACE}/dgpython-local:/home/user/software_ws/dgpython-local" \
                -v "${WORKSPACE}/spatialnde2-ec-functions:/home/user/software_ws/spatialnde2-ec-functions" \
                -v "${WORKSPACE}/software_ws/SOFA:/home/user/software_ws/SOFA" \
                -v "${WORKSPACE}/scandata:/home/user/scandata" \
                -v "${WORKSPACE}/test_data:/opt/test_data:ro" \
                -e TARI_TEST_DATA=/opt/test_data \
                -v "${CONTAINER_LOCAL}:/home/user/.local" \
                -v "$HOME/.ssh:/home/user/.ssh" \
                -v /tmp/.X11-unix:/tmp/.X11-unix \
                -v "${HERE}/entrypoint.sh:/entrypoint.sh" \
                ${IMAGE_NAME}
            
            echo "Container started. KasmVNC is available at http://localhost:8443"
        fi
        ;;
    stop)
        echo "Stopping container ${CONTAINER_NAME}..."
        docker stop ${CONTAINER_NAME} || true
        ;;
    rm)
        echo "Removing container ${CONTAINER_NAME}..."
        docker rm -f ${CONTAINER_NAME} || true
        ;;
    restart)
        echo "Restarting container ${CONTAINER_NAME}..."
        $0 rm
        $0 start
        ;;
    shell)
        echo "Opening shell in ${CONTAINER_NAME}..."
        docker exec -it -u user ${CONTAINER_NAME} /bin/bash
        ;;
    logs)
        docker exec ${CONTAINER_NAME} journalctl -xeu kasm-init
        ;;
    *)
        echo "Unknown command: $COMMAND"
        print_usage
        exit 1
        ;;
esac
