# Base image: the KasmVNC cloud workstation
FROM cloud-workstations/kasm-cloud-workstation:latest

# Switch to root to modify the system-level entrypoint script
USER root

# ---------------------------------------------------------------------------
# Robotics Layer: ROS2 iron & Gazebo
# ---------------------------------------------------------------------------
# The ROS package list below overlaps what `rosdep install --from-paths src` would
# work out from ros_ws/src. That is deliberate: installing it here puts it in one
# cached image layer, so a source change does not reinstall several gigabytes of
# apt. It is not the authority on what is required, though. The runtime plugins
# in it (ros-iron-pick-ik, ros-iron-pose-broadcaster, the ros2_control
# controllers, the MoveIt planners) are named as strings in configs, and each is
# declared as an exec_depend by the package that ships the config naming it,
# which is what makes them arrive on a machine not built from this image.
# tari_bringup/test/test_plugin_dependencies.py checks those declarations.
RUN apt-get update && apt-get install -y software-properties-common curl && \
    add-apt-repository universe && \
    curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] https://ftp.osuosl.org/pub/ros2/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null && \
    add-apt-repository -y ppa:kisak/turtle && \
    apt-get update && apt-get install -y \
        ros-iron-desktop \
        ros-iron-ros-base \
        ros-iron-gazebo-ros-pkgs \
        ros-iron-ros-gz \
        python3-colcon-common-extensions \
        ros-dev-tools \
        python3-rosdep \
        python3-vcstool \
        ros-iron-rmw-cyclonedds-cpp \
        binfmt-support \
        blender \
        blender-data \
        clang \
        clang-14 \
        docbook-xml \
        fonts-dejavu \
        fonts-roboto \
        fonts-roboto-unhinted \
        gnome-terminal \
        gnome-terminal-data \
        gstreamer1.0-gl:amd64 \
        gstreamer1.0-plugins-good:amd64 \
        gstreamer1.0-x:amd64 \
        iwyu \
        lcov \
        mesa-common-dev \
        lib32gcc-s1 \
        lib32stdc++6 \
        libaa1:amd64 \
        libastcenc1d:amd64 \
        libbenchmark-dev:amd64 \
        libbenchmark1:amd64 \
        libc6-i386 \
        libcap-dev:amd64 \
        libclang-14-dev \
        libclang-common-14-dev \
        libclang-cpp13 \
        libclang-cpp14 \
        libclang-dev \
        libcommon-sense-perl:amd64 \
        libdcmtk16 \
        libdv4:amd64 \
        libdw-dev:amd64 \
        libelf-dev:amd64 \
        libembree3-3:amd64 \
        libfftw3-double3:amd64 \
        libfilament1.9:amd64 \
        libgc1:amd64 \
        libgd-perl \
        libglfw3-dev:amd64 \
        libglfw3:amd64 \
        libgraphene-1.0-0:amd64 \
        libgstreamer-gl1.0-0:amd64 \
        libgstreamer-plugins-good1.0-0:amd64 \
        libhandy-1-0:amd64 \
        libharfbuzz-icu0:amd64 \
        libjavascriptcoregtk-4.0-18:amd64 \
        libjemalloc2:amd64 \
        libjson-perl \
        libjson-xs-perl \
        liblapacke:amd64 \
        libllvm13:amd64 \
        liblog4cplus-2.0.5:amd64 \
        liblzf1:amd64 \
        libmanette-0.2-0:amd64 \
        libmeshoptimizer1d:amd64 \
        libnautilus-extension1a:amd64 \
        libncurses-dev:amd64 \
        libobjc-11-dev:amd64 \
        libobjc4:amd64 \
        libomp-14-dev \
        libomp-dev:amd64 \
        libomp5-14:amd64 \
        libopen3d0.14:amd64 \
        libopencolorio1v5 \
        libopenimageio2.2:amd64 \
        libopenvdb8.1 \
        libosdcpu3.4.4:amd64 \
        libperlio-gzip-perl \
        libpfm4:amd64 \
        libpipewire-0.3-0:amd64 \
        libpipewire-0.3-common \
        libpipewire-0.3-modules:amd64 \
        libpugixml1v5:amd64 \
        libshout3:amd64 \
        libsocket++-dev:amd64 \
        libspa-0.2-modules:amd64 \
        libspirv-cross-c-shared0:amd64 \
        libsquish0:amd64 \
        libstb0:amd64 \
        libtinfo-dev:amd64 \
        libtinyexr1d:amd64 \
        libtmglib3:amd64 \
        libtypes-serialiser-perl \
        libv4l-0:amd64 \
        libv4lconvert0:amd64 \
        libwavpack1:amd64 \
        libwebkit2gtk-4.0-37:amd64 \
        libyelp0:amd64 \
        libz3-dev:amd64 \
        llvm-14 \
        llvm-14-dev \
        llvm-14-linker-tools \
        llvm-14-runtime \
        llvm-14-tools \
        nautilus-extension-gnome-terminal \
        open3d-gui-data \
        pipewire-bin \
        pipewire-media-session \
        pipewire:amd64 \
        python-babel-localedata \
        python3-babel \
        python3-jinja2 \
        python3-markupsafe \
        python3-open3d \
        python3-typeguard \
        ros-iron-backward-ros \
        ros-iron-control-msgs \
        ros-iron-control-toolbox \
        ros-iron-controller-interface \
        ros-iron-controller-manager \
        ros-iron-controller-manager-msgs \
        ros-iron-diagnostic-updater \
        ros-iron-eigen-stl-containers \
        ros-iron-filters \
        ros-iron-force-torque-sensor-broadcaster \
        ros-iron-forward-command-controller \
        ros-iron-gazebo-ros2-control \
        ros-iron-generate-parameter-library \
        ros-iron-generate-parameter-library-py \
        ros-iron-geometric-shapes \
        ros-iron-google-benchmark-vendor \
        ros-iron-graph-msgs \
        ros-iron-gripper-controllers \
        ros-iron-hardware-interface \
        ros-iron-joint-state-broadcaster \
        ros-iron-joint-state-publisher \
        ros-iron-joint-state-publisher-gui \
        ros-iron-joint-trajectory-controller \
        ros-iron-launch-param-builder \
        ros-iron-librealsense2 \
        ros-iron-moveit-common \
        ros-iron-moveit-configs-utils \
        ros-iron-moveit-core \
        ros-iron-moveit-kinematics \
        ros-iron-moveit-msgs \
        ros-iron-moveit-planners \
        ros-iron-moveit-planners-ompl \
        ros-iron-moveit-planners-stomp \
        ros-iron-moveit-resources-fanuc-description \
        ros-iron-moveit-resources-fanuc-moveit-config \
        ros-iron-moveit-resources-panda-description \
        ros-iron-moveit-resources-panda-moveit-config \
        ros-iron-moveit-ros-move-group \
        ros-iron-moveit-ros-occupancy-map-monitor \
        ros-iron-moveit-ros-planning \
        ros-iron-moveit-ros-planning-interface \
        ros-iron-moveit-ros-robot-interaction \
        ros-iron-moveit-ros-visualization \
        ros-iron-moveit-ros-warehouse \
        ros-iron-moveit-servo \
        ros-iron-moveit-simple-controller-manager \
        ros-iron-moveit-visual-tools \
        ros-iron-object-recognition-msgs \
        ros-iron-octomap \
        ros-iron-octomap-msgs \
        ros-iron-ompl \
        ros-iron-parameter-traits \
        ros-iron-pcl-ros \
        ros-iron-pick-ik \
        ros-iron-pilz-industrial-motion-planner \
        ros-iron-pose-broadcaster \
        ros-iron-position-controllers \
        ros-iron-py-binding-tools \
        ros-iron-random-numbers \
        ros-iron-realsense2-camera \
        ros-iron-realsense2-camera-msgs \
        ros-iron-realsense2-description \
        ros-iron-realtime-tools \
        ros-iron-ros2-control-test-assets \
        ros-iron-ros2-controllers-test-nodes \
        ros-iron-rsl \
        ros-iron-ruckig \
        ros-iron-rviz-visual-tools \
        ros-iron-srdfdom \
        ros-iron-stomp \
        ros-iron-tcb-span \
        ros-iron-tl-expected \
        ros-iron-ur \
        ros-iron-ur-calibration \
        ros-iron-ur-client-library \
        ros-iron-ur-controllers \
        ros-iron-ur-dashboard-msgs \
        ros-iron-ur-description \
        ros-iron-ur-moveit-config \
        ros-iron-ur-msgs \
        ros-iron-ur-robot-driver \
        ros-iron-urdfdom-py \
        ros-iron-velocity-controllers \
        ros-iron-warehouse-ros \
        ros-iron-warehouse-ros-sqlite \
        ros-iron-apriltag-msgs \
        sgml-data \
        xdg-dbus-proxy \
        xdg-desktop-portal \
        xdg-desktop-portal-gtk \
        yelp \
        yelp-xsl \
        libglvnd-dev \ 
        libgl1-mesa-dev \
        mesa-common-dev \
        swig4.0 \
        libopenscenegraph-dev \ 
        libopenthreads-dev \
        freeglut3-dev \
        opencl-headers \
        ocl-icd-opencl-dev \
        clinfo \
        # Debugging a wedged dgpy/ROS process means attaching to it, so the
        # tracer belongs in the image rather than in a live container, where it
        # would be lost on the next recreate.
        strace \
    && rm -rf /var/lib/apt/lists/*

# ---------------------------------------------------------------------------
# SpatialNDE2 and Dataguzzler-Python Dependencies
# ---------------------------------------------------------------------------
RUN apt-get update && apt-get install -y \
    cmake swig python3 python3-dev cython3 python3-pip python3-numpy \
    python3-setuptools python3-wheel python3-tomli-w python3-setuptools-scm \
    libxml2-dev libeigen3-dev libhdf5-dev opencl-headers ocl-icd-opencl-dev \
    opencl-clhpp-headers libpng-dev libopenscenegraph-dev freeglut3-dev \
    qtbase5-dev qttools5-dev ipython3 jupyter-qtconsole python3-pyqt5 \
    python3-matplotlib python3-pyopencl \
    python3-collada python3-networkx python3-pint python3-progress python3-transforms3d \
    && rm -rf /var/lib/apt/lists/*

# ---------------------------------------------------------------------------
# Install policy: system-wide, never editable, never --user.
#
# Every pip install in this file, here and below, is deliberately a plain
# system-wide install. Do not "fix" one into --user or -e.
#
# The workspace rule is that a Python package is installed with
#
#     sudo pip install --no-deps --no-build-isolation .
#
# and nothing else. An image build is already root and has no reason to call
# sudo, so the privilege half of that is satisfied by construction: pip3 here is
# the image's only python3 and writes to /usr/local/lib/python3.10/dist-packages,
# which every user and every service in the container reads. What must still
# hold is the rest of the rule -- never editable, and never into a per-user tree.
# A per-user install would be worse than useless here: ~/.local is a mount from
# the host, so it would not be part of the image at all, and it precedes the
# system directories on sys.path, which makes it shadow what the image provides.
#
# --no-deps is NOT used for the third-party packages below. These are ordinary
# dependencies being resolved on purpose; the flag belongs on installs of our own
# source, where pip must not substitute a version nobody chose.
#
# No dataguzzler package is installed at image build time. spatialnde2,
# dataguzzler-python and the dgpython-* modules are built from the mounted
# sources by dgpy_install.sh inside the running container, because they are
# developed here and the image must not pin a commit.
# ---------------------------------------------------------------------------
RUN pip3 install pyquaternion trimesh zstandard

# TOPP-RA, for tari_toppra's primary time-parameterization backend.
#
# PINNED, AND THE PIN IS LOAD-BEARING. 0.6.1 through 0.6.3 carry an open issue
# (#244) where the solver fails on feasible problems at particular gridpoint
# counts, which on a scan row is indistinguishable from the TOTG conditioning
# failure the package exists to avoid. toppra exposes no __version__, so
# tari_toppra reads the version from package metadata and warns on a mismatch.
#
# Not declared in tari_toppra/package.xml: there is no rosdep key for it, and
# backend_toppra imports it lazily so the package builds, installs and runs its
# whole host suite without it -- which is deliberate, because the trapezoid
# backend is the fallback and has to work with no toppra at all. It is here so
# that a container recreate does not silently take the primary backend away;
# before this line it was a `sudo pip install` into a live container and was
# lost on every recreate.
#
# cp310 only matters inside this image. There is no cp314 wheel, so toppra
# cannot be installed on the Arch host at all, and the host runs the trapezoid
# half of the suite.
RUN pip3 install "toppra==0.6.10"

# Ubuntu 22.04 ships setuptools_scm 6.4.2, which predates the "version_file" option.
# spatialnde2's build writes that option into the generated pyproject.toml
# (python/pyproject_assign_git_root.py), so the pip install step fails with
#   TypeError: Configuration.__init__() got an unexpected keyword argument 'version_file'
# unless a newer setuptools_scm shadows the distro package.
RUN pip3 install -U "setuptools_scm[toml]>=8"

# SWIG 4.1 or newer, for spatialnde2's Python directors.
#
# Ubuntu 22.04 ships SWIG 4.0.2, and spatialnde2 switches directors off below
# 4.1.0 (snde/recstore_transaction_manager.i) because 4.0.x writes the names of
# two-character C++ operators into the generated director class with the
# characters separated -- "operator  =  = " for operator== -- which does not
# compile. The consequence on a 4.0.2 build is that measurement_clock and
# measurement_time cannot be subclassed from Python, so a piece of hardware's own
# clock cannot be used as the measurement clock of a timed_transaction_manager,
# and spatialnde2's test/measurement_clock_python.py skips.
#
# SWIG is a build-time tool: it emits a .cxx file and leaves nothing behind in
# the installed library, so a newer one changes no runtime behaviour. The wheel
# below carries a self-contained binary at /usr/local/bin/swig.
#
# The distribution's swig4.0 is deliberately left installed. CMake's FindSWIG
# looks for the versioned names first (swig4.0 before swig), so /usr/bin/swig4.0
# would still win on PATH order alone -- which is why SWIG_EXECUTABLE has to be
# passed to cmake explicitly. dgpy_install.sh does that; a build by hand needs
# -DSWIG_EXECUTABLE=/usr/local/bin/swig.
RUN pip3 install "swig>=4.1,<4.6" && /usr/local/bin/swig -version

# ---------------------------------------------------------------------------
# Intel GPU OpenCL runtime
# ---------------------------------------------------------------------------
# The image otherwise has only PoCL, which is a CPU-only OpenCL implementation.
# spatialnde2 falls back to CPU for every accelerated function and says so --
# "Performing normal calculation on CPU. This will be slow.",
# "Performing projinfo calculation on CPU", the vertex_arrays/texvertex_arrays
# pair -- all of which are the `else` branch of an #ifdef SNDE_OPENCL block and
# would run on a GPU if one were visible. ros2_docker.sh already passes
# --device /dev/dri and the container user is in the video and render groups,
# so the device nodes are reachable; this layer supplies the userspace driver.
#
# Intel's own repo rather than Ubuntu's: 22.04 ships intel-opencl-icd 22.14
# (2022), which predates every recent GPU. The "unified" component carries the
# current client driver line.
#
# This does NOT cover every Intel GPU. A Core Ultra 5 325 (PCI 0xb090, driven
# by the `xe` KMD) needs NEO >= 26.x; 25.18, the newest Intel package for
# either jammy or noble, enumerates zero platforms for it even with
# INTEL_FORCE_PROBE. Upstream NEO 26.x .debs declare libc6 >= 2.38 and
# libstdc++6 >= 13.1, while Ubuntu 22.04 has glibc 2.35 and libstdc++ 12, so
# they cannot be installed here at all. GPU OpenCL on that class of part needs
# a newer base than ROS Iron's Ubuntu 22.04, which is a ROS-distro decision,
# not a package one.
#
# Installing it anyway is deliberate and cheap: it is a no-op on hardware it
# cannot drive (the loader falls back to PoCL), and it does give real GPU
# acceleration on any Intel GPU that 25.18 supports -- which may well be what
# the deployed scanner has.
RUN curl -fsSL https://repositories.intel.com/gpu/intel-graphics.key \
        | gpg --dearmor --yes --output /usr/share/keyrings/intel-graphics.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/intel-graphics.gpg] https://repositories.intel.com/gpu/ubuntu jammy unified" \
        > /etc/apt/sources.list.d/intel-gpu-jammy.list && \
    apt-get update && \
    apt-get install -y intel-opencl-icd && \
    rm -rf /var/lib/apt/lists/*

RUN apt-add-repository -y 'deb http://archive.ubuntu.com/ubuntu/ focal universe' && \
    apt-get install -y libsoundio1 && \
    apt-add-repository -r -y 'deb http://archive.ubuntu.com/ubuntu/ focal universe' && \
    curl -sSL -O https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    rm packages-microsoft-prod.deb && \
    apt update && \
    echo 'libk4a1.4 libk4a1.4/accepted-eula-hash string 0f5d5c5de396e4fee4c0753a21fee0c1ed726cf0316204edda484f08cb266d76' | debconf-set-selections && \
    echo 'libk4a1.4 libk4a1.4/accept-eula boolean true' | debconf-set-selections && \
    DEBIAN_FRONTEND=noninteractive apt install k4a-tools libk4a1.4* && \
    rm /etc/apt/sources.list.d/microsoft-prod.list && \
    rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://antigravity.google/cli/install.sh | bash \
    && mkdir -p /opt/antigravity-2.0 /opt/antigravity-ide \
    && curl -fsSL "https://storage.googleapis.com/antigravity-public/antigravity-hub/2.0.10-5119448496078848/linux-x64/Antigravity.tar.gz" | tar -xz -C /opt/antigravity-2.0 --strip-components=1 \
    && curl -fsSL "https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/2.0.3-6242596486512640/linux-x64/Antigravity%20IDE.tar.gz" | tar -xz -C /opt/antigravity-ide --strip-components=1 \
    && ln -s /opt/antigravity-2.0/antigravity /usr/local/bin/antigravity \
    && ln -s /opt/antigravity-ide/antigravity-ide /usr/local/bin/antigravity-ide

RUN apt-get update && apt-get install -y wget \
    && mkdir -p -m 755 /etc/apt/keyrings \
    && wget -qO /etc/apt/keyrings/githubcli-archive-keyring.gpg https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    && chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list \
    && apt-get update \
    && apt-get install -y gh \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://opencode.ai/install | bash


# ---------------------------------------------------------------------------
# Downstream Entrypoint Configuration
# ---------------------------------------------------------------------------
RUN mkdir -p /docker-entrypoint.d && \
    sed -i 's/drinode: \/dev\/dri\/renderD128/#drinode: \/dev\/dri\/renderD128/g' /usr/share/kasmvnc/kasmvnc_defaults.yaml && \
    sed -i 's/-hw3d //g' /entrypoint.sh && \
    sed -i 's/hw3d: true/hw3d: false/g' /entrypoint.sh && \
    sed -i '/Writing bash aliases and NVIDIA paths/,+15d' /entrypoint.sh

# Write the ROS2 Aliases to a dedicated drop-in script
RUN cat <<'EOF' > /docker-entrypoint.d/10-ros2-aliases.sh
#!/bin/bash

# --- INJECTED ROS2 ALIASES ---
if [ ! -f /home/user/.bashrc ] || ! grep -q "RMW_IMPLEMENTATION" /home/user/.bashrc; then
    echo "Writing ROS2 environment variables to persistent disk..."
    echo "source /opt/ros/iron/setup.bash" >> /home/user/.bashrc
    echo "export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp" >> /home/user/.bashrc
    echo "export INTEL_FORCE_PROBE=b090" >> /home/user/.bashrc
    echo "alias gazebo='gazebo'" >> /home/user/.bashrc
    echo "alias ign='ign'" >> /home/user/.bashrc
    echo "alias rviz2='rviz2'" >> /home/user/.bashrc
    echo "alias ros2='ros2'" >> /home/user/.bashrc
    echo "alias blender='blender'" >> /home/user/.bashrc
                
    # Ensure the user still owns their bashrc
    chown user:user /home/user/.bashrc
fi
EOF

# Ensure the drop-in script is executable
RUN chmod +x /docker-entrypoint.d/10-ros2-aliases.sh

# ---------------------------------------------------------------------------
# YOLO's Python stack
# ---------------------------------------------------------------------------
# yolo_bringup's launch file otherwise provisions exactly this list into a
# private venv by shelling out to `uv sync` -- at launch-DESCRIPTION time, so a
# missing `uv` is not a node that fails to start, it is an exception that takes
# the whole cell down. The venv only ever contains yolo_ros/pyproject.toml's
# five dependencies, so installing them here removes the need for `uv` at all;
# yolo.launch.py is patched to skip the sync when they already import.
#
# CPU wheels deliberately: this container has no usable GPU compute (GL is
# llvmpipe, OpenCL is pocl on the CPU), and the CUDA build of torch is several
# GB larger for nothing.
#
# numpy is PINNED <2. ROS Iron's Python stack is built against numpy 1.x and
# ultralytics will happily pull numpy 2 otherwise, which breaks cv_bridge and
# every rclpy message conversion in the image.
RUN pip3 install --no-cache-dir --index-url https://download.pytorch.org/whl/cpu \
        torch torchvision \
    && pip3 install --no-cache-dir \
        "numpy<2" \
        "opencv-python-headless>=4.8.1.78" \
        "typing-extensions>=4.4.0" \
        "ultralytics==8.4.6" \
        "lap>=0.5.12"

# The opencv wheel above bundles its own Qt and puts it on the Qt plugin path,
# and then RVIZ2 LOADS THAT INSTEAD OF THE SYSTEM QT and aborts before it draws
# anything:
#   qt.qpa.plugin: Could not load the Qt platform plugin "xcb" in
#   "/usr/local/lib/python3.10/dist-packages/cv2/qt/plugins"
#   ... [rviz2-22]: process has died ... exit code -6
# rviz2 is C++ and never imports cv2 itself; it inherits the hijacked plugin
# path from the `ros2 launch` process, which is Python and does. A *headless*
# build has no business shipping a platform plugin at all, so remove it.
RUN rm -rf /usr/local/lib/python3.10/dist-packages/cv2/qt