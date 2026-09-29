#!/bin/bash
set -eo pipefail

# Install Web Browser
wget -O /tmp/firefox.tar.bz2 "https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=en-US"
tar xf /tmp/firefox.tar.bz2 -C /opt/
ln -s /opt/firefox/firefox /usr/bin/firefox

cat << 'EOF' > /usr/share/applications/firefox.desktop
[Desktop Entry]
Version=1.0
Name=Firefox
Comment=Browse the World Wide Web
Exec=/opt/firefox/firefox %u
Terminal=false
X-MultipleArgs=false
Type=Application
Icon=/opt/firefox/browser/chrome/icons/default/default128.png
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;application/xml;application/rss+xml;application/rdf+xml;image/gif;image/jpeg;image/png;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;x-scheme-handler/chrome;video/webm;application/x-xpinstall;
StartupNotify=true
EOF

update-alternatives --install /usr/bin/x-www-browser x-www-browser /opt/firefox/firefox 200
update-alternatives --install /usr/bin/gnome-www-browser gnome-www-browser /opt/firefox/firefox 200

mkdir -p /etc/xdg

cat << 'EOF' >> /etc/xdg/mimeapps.list
[Default Applications]
x-scheme-handler/http=firefox.desktop
x-scheme-handler/https=firefox.desktop
x-scheme-handler/about=firefox.desktop
x-scheme-handler/unknown=firefox.desktop
text/html=firefox.desktop
EOF

mkdir -p /etc/xdg/xfce4
echo "WebBrowser=firefox" >> /etc/xdg/xfce4/helpers.rc

rm /tmp/firefox.tar.bz2

sudo apt update
wget -O /tmp/google-chrome.deb "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
apt-get install -y /tmp/google-chrome.deb
rm /tmp/google-chrome.deb


curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
sudo apt update
apt-get install -y google-cloud-cli

# Download the Microsoft GPG key
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /usr/share/keyrings/packages.microsoft.gpg

# Add the VS Code repository
echo "deb [arch=amd64,arm64,armhf signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | tee /etc/apt/sources.list.d/vscode.list

# Install VS Code
apt-get update
apt-get install -y code


apt-get autoremove -y
rm -rf /var/lib/apt/lists/*