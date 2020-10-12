#!/bin/bash

panel() {
  clear
  echo "Welcome- do you wish to proceed to upgrade your panel to v1.0? Please note that this WILL not install pterodactyl for you, this is only a tool to upgrade quickly to 1.0. Y/N " read question1
  if [[ "$question1" == "^[Yy]" ]]; then
  echo "Getting to work..."
  cd /var/www/pterodactyl
  php artisan down

  curl -L -o panel.tar.gz https://github.com/pterodactyl/panel/releases/download/v1.0.0/panel.tar.gz
  rm -rf $(find app public resources -depth | head -n -1 | grep -Fv "$(tar -tf panel.tar.gz)")

  tar -xzvf panel.tar.gz && rm -f panel.tar.gz

  composer install --no-dev --optimize-autoloader

  php artisan view:clear
  php artisan config:clear

  php artisan migrate --force
  php artisan db:seed --force

  php artisan up

  else
  echo "exiting"
  exit
  fi
}

daemon() {
  echo "Are you sure you want to upgrade the daemon? " read question2
  if [[ "$question2" == "^[Yy]" ]]; then
  echo "Getting to work..."
  service wings stop
  rm -f /etc/systemd/system/wings.service
  service wings stop
  rm -rf /srv/daemon

  mkdir -p /etc/pterodactyl
  curl -L -o /usr/local/bin/wings https://github.com/pterodactyl/wings/releases/download/v1.0.0/wings_linux_amd64
  chmod u+x /usr/local/bin/wings

  echo -e "[Unit]
Description=Pterodactyl Wings Daemon
After=docker.service

[Service]
User=root
WorkingDirectory=/etc/pterodactyl
LimitNOFILE=4096
PIDFile=/var/run/wings/daemon.pid
ExecStart=/usr/local/bin/wings
Restart=on-failure
StartLimitInterval=600

[Install]
WantedBy=multi-user.target" >> /etc/systemd/system/wings.service
systemctl daemon-reload

  else
  echo "exiting"
  exit
  fi
}


panel
daemon

echo "/!\ WARNING /!\"
echo "If you upgrade your panel, you need to properly set permissions. Todo this please visit the pterodactyl docs (https://pterodactyl.io/panel/1.0/upgrade/0.7_to_1.0.html#set-permissions), and follow what the docs says about editing permissions. You should then visit your /var/www/pterodactyl folder to run the command."
echo "/!\ WARNING /!\"
echo "If you installed the daemon, please visit the panel, configure the daemon, then visit paste the automated command it gives you."
