#!/bin/bash

cert_serv() {
    ser=$(
        cat <<-END
[Unit]
Description=Certbot Renewal

[Service]
ExecStart=/usr/bin/certbot renew --post-hook "systemctl restart nginx"
END
    )
    echo "$ser" >/etc/systemd/system/certbot-renewal.service
}
cert_timr() {
    ser=$(
        cat <<-END
[Unit]
Description=Timer for Certbot Renewal

[Timer]
OnBootSec=300
OnUnitActiveSec=1w

[Install]
WantedBy=multi-user.target
END
    )
    echo "$ser" >/etc/systemd/system/certbot-renewal.timer
}
cert_chk() {
    systemctl start certbot-renewal.timer
    systemctl enable certbot-renewal.timer
    systemctl status certbot-renewal.timer
    journalctl -u certbot-renewal.service
}
if [ $(whoami) != root ]; then
    zenity --width=350 --error \
        --text="Please Run This Scripts As <b>root</b> Or As <b>Sudo User</b>"
    exit
else
    cert_serv
    cert_timr
    cert_chk
fi
