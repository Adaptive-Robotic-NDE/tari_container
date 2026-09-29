# ---------------------------------------------------------------------------
# Base layer. Ubuntu 22.04 (jammy) is not a free choice: ROS 2 Iron targets it,
# and the ROS image built on top of this one installs Iron from apt.
# ---------------------------------------------------------------------------
FROM ubuntu:22.04 AS base

# Tell systemd it is running inside a container
ENV container=docker

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive



# FORCE APT TO RETRY DOWNLOADS ON TIMEOUT -- needed sometimes on GCP
RUN echo 'Acquire::Retries "5";' > /etc/apt/apt.conf.d/80-retries && \
    echo 'Acquire::http::Timeout "20";' >> /etc/apt/apt.conf.d/80-retries

# Install ca-certificates early
RUN apt-get update && apt-get install -y ca-certificates && update-ca-certificates

# ---------------------------------------------------------------------------
# System Layer: Desktop Environment & Utilities
# ---------------------------------------------------------------------------
RUN apt-get update && apt-get install -y \
    systemd \
    systemd-sysv \
    dbus \ 
    dbus-x11 \ 
    curl \
    wget \
    git \
    vim \
    nano \
    python3-pip \
    python3-venv \
    xfce4 \
    xfce4-goodies \
    terminator \
    dbus-x11 \
    x11-utils \
    mesa-utils \
    libgl1 \
    libglx-mesa0 \
    libgl1-mesa-dri \
    libegl1 \
    pciutils \
    openssh-server \
    ssl-cert \
    sudo \
    libvulkan1 \
    vulkan-tools \
    mesa-vulkan-drivers \
    intel-media-va-driver \
    wget \
    bzip2 \
    libgtk-3-0 \
    libx11-xcb1 \
    libdbus-glib-1-2 \
    libpci3 \
    libasound2 \
    libpam-systemd \
    dbus-user-session \
    inkscape \ 
    gimp \
    libreoffice \
    && apt-get purge -y xfce4-power-manager \ 
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*    

# Set up dbus
RUN systemd-machine-id-setup

# Mask services that will fail or are unnecessary in a container
RUN systemctl mask dev-mqueue.mount dev-hugepages.mount \
    systemd-remount-fs.service sys-kernel-config.mount \
    sys-kernel-debug.mount sys-fs-fuse-connections.mount \
    getty.target console-getty.service && \
    systemctl enable dbus

# Install and generate locales
RUN apt-get update && apt-get install -y locales && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Enable systemd --user for the 'user' account at boot
RUN mkdir -p /var/lib/systemd/linger && touch /var/lib/systemd/linger/user

# Kasm refuses to start without a certificate. GCP terminates SSL, so a
# self-signed one is enough.
RUN make-ssl-cert generate-default-snakeoil --force-overwrite

# Prevent Polkit from prompting for colord permissions in remote VNC sessions
RUN mkdir -p /etc/polkit-1/localauthority/50-local.d && \
    echo '[Allow Colord all Users]\n\
Identity=unix-user:*\n\
Action=org.freedesktop.color-manager.create-device;org.freedesktop.color-manager.create-profile;org.freedesktop.color-manager.delete-device;org.freedesktop.color-manager.delete-profile;org.freedesktop.color-manager.modify-device;org.freedesktop.color-manager.modify-profile\n\
ResultAny=yes\n\
ResultInactive=yes\n\
ResultActive=yes' > /etc/polkit-1/localauthority/50-local.d/45-allow-colord.pkla

# ---------------------------------------------------------------------------
# Install Programs
# ---------------------------------------------------------------------------
# Copy the script into the container
COPY install-programs.sh /tmp/install-programs.sh

# Make it executable, run it, and then remove it to keep the image clean
RUN chmod +x /tmp/install-programs.sh && /tmp/install-programs.sh && rm /tmp/install-programs.sh


# ---------------------------------------------------------------------------
# VirtualGL Layer
# ---------------------------------------------------------------------------
RUN wget -q -O- https://packagecloud.io/dcommander/virtualgl/gpgkey | gpg --dearmor > /etc/apt/trusted.gpg.d/VirtualGL.gpg && \
    wget -qO /etc/apt/sources.list.d/VirtualGL.list https://raw.githubusercontent.com/VirtualGL/repo/main/VirtualGL.list && \
    apt-get update && apt-get install -y virtualgl && rm -rf /var/lib/apt/lists/*

# ---------------------------------------------------------------------------
# Streaming Layer: KasmVNC
# ---------------------------------------------------------------------------
RUN curl -L -O https://github.com/kasmtech/KasmVNC/releases/download/v1.4.0/kasmvncserver_jammy_1.4.0_amd64.deb && \
    apt-get update && apt-get install -y ./kasmvncserver_*.deb && \
    rm kasmvncserver_*.deb && \
    setcap 'cap_net_bind_service=+ep' $(readlink -f /usr/bin/Xvnc)

# ---------------------------------------------------------------------------
# User Configuration Layer
# Note default username is user and password is password
# Passwordless sudo is enabled
# ---------------------------------------------------------------------------
RUN userdel -r ubuntu || true && \
    useradd -m -u 1000 -s /bin/bash user && \
    echo "user ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    echo "user:password" | chpasswd

# ---------------------------------------------------------------------------
# Entrypoint Configuration
# ---------------------------------------------------------------------------
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Copy and enable custom systemd service for KasmVNC & init setup
COPY kasm-init.service /etc/systemd/system/kasm-init.service
RUN systemctl enable kasm-init.service ssh.service

EXPOSE 8443
EXPOSE 22

# Graceful shutdown signal for systemd
STOPSIGNAL SIGRTMIN+3

# Hand off PID 1 to systemd
CMD ["/sbin/init"]