#!/bin/bash
set -e

# 0. Fix X11 Socket Permissions
mkdir -p /tmp/.X11-unix
chmod 1777 /tmp/.X11-unix

# 1. Fix home directory and permissions
mkdir -p /home/user
chown -R user:user /home/user
chmod 755 /home/user

# 2. Start SSH Server
#mkdir -p /run/sshd
#ssh-keygen -A
#/usr/sbin/sshd
# Create the XFCE autostart directory
mkdir -p /home/user/.config/autostart

# Create a desktop file that updates the systemd environment on login
cat << 'EOF' > /home/user/.config/autostart/dbus-update.desktop
[Desktop Entry]
Type=Application
Name=Update DBus Environment
Exec=dbus-update-activation-environment --systemd DISPLAY XAUTHORITY
StartupNotify=false
Terminal=false
Hidden=false
EOF

# Ensure proper ownership
chown -R user:user /home/user/.config

# 3. Set Default Password
export VNC_PW=${VNC_PW:-password}

# 4. Persistence Handling 
if [ ! -f /home/user/.vnc/kasmvnc.yaml ]; then
  echo "Initializing KasmVNC configuration..."
  mkdir -p /home/user/.vnc
  cat <<EOF > /home/user/.vnc/kasmvnc.yaml
network:
  protocol: http
  interface: 0.0.0.0
  websocket_port: 8443
  ssl:
    require_ssl: false
  udp:
    public_ip: 127.0.0.1
desktop:
  resolution:
    width: 1920
    height: 1080
  gpu:
    hw3d: true
EOF
  chown -R user:user /home/user/.vnc
fi

# 4. GPU & SSL Permission Fixes
usermod -aG video,render,ssl-cert user

if [ -d /dev/dri ]; then
  chmod 666 /dev/dri/*
fi

# 5. VirtualGL & NVIDIA Context Scoping
if [ ! -f /home/user/.bashrc ] || ! grep -q "VGL_DISPLAY" /home/user/.bashrc; then
  echo "Writing bash aliases and NVIDIA paths to persistent disk..."
  
  # Copy the default Ubuntu bash configuration if the file is missing
  if [ ! -f /home/user/.bashrc ]; then
    cp /etc/skel/.bashrc /home/user/.bashrc
  fi

  # Append the environment variables and aliases
  echo "export PATH=/var/lib/nvidia/bin:\$PATH" >> /home/user/.bashrc
  echo "export LD_LIBRARY_PATH=/var/lib/nvidia/lib64:/var/lib/nvidia/lib:\$LD_LIBRARY_PATH" >> /home/user/.bashrc
  echo "export __EGL_VENDOR_LIBRARY_NAME=nvidia" >> /home/user/.bashrc
  echo "export VGL_DISPLAY=egl" >> /home/user/.bashrc

  echo "export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/nvidia_icd.json" >> /home/user/.bashrc
  
  echo "alias glxinfo='vglrun glxinfo'" >> /home/user/.bashrc
  echo "alias glxgears='vglrun glxgears'" >> /home/user/.bashrc
  echo "alias vulkaninfo='vglrun vulkaninfo'" >> /home/user/.bashrc
  echo "alias vkcube='vglrun vkcube'" >> /home/user/.bashrc
  echo "alias gimp='vglrun gimp'" >> /home/user/.bashrc

  echo "export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus" >> /home/user/.bashrc
  echo "export XDG_RUNTIME_DIR=/run/user/1000" >> /home/user/.bashrc
  
  # Ensure the user account owns the file so it can be edited without sudo
  chown user:user /home/user/.bashrc
fi

# Register GKE-injected NVIDIA libraries to the dynamic linker cache
if [ ! -f /etc/ld.so.conf.d/99-nvidia-dynamic.conf ]; then
  echo "Registering GKE dynamic libraries..."
  mkdir -p /etc/ld.so.conf.d
  echo "/var/lib/nvidia/lib" > /etc/ld.so.conf.d/99-nvidia-dynamic.conf
  echo "/var/lib/nvidia/lib64" >> /etc/ld.so.conf.d/99-nvidia-dynamic.conf
  ldconfig
fi

# 6. Automated Kasm User Creation
echo "Setting KasmVNC credentials..."
su - user -c "echo -e '${VNC_PW}\n${VNC_PW}' | vncpasswd -u user -w"

# 7. Execute downstream layer startup scripts
if [ -d /docker-entrypoint.d ]; then
  echo "Executing scripts in /docker-entrypoint.d/..."
  # Loop through any .sh files in the directory and source them
  for f in /docker-entrypoint.d/*.sh; do
    if [ -x "$f" ]; then
      echo "Running $f..."
      "$f"
    else
      echo "Sourcing $f..."
      . "$f"
    fi
  done
fi

# 8. Start KasmVNC 
echo "Starting KasmVNC Server..."
su - user -c "vncserver -hw3d -select-de xfce -port 8443 -disableBasicAuth"

# 9. Keep Container Alive 
#sleep 2
#tail -f /home/user/.vnc/*.log