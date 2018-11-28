mkdir /tmp/kubeinstall 
cd /tmp/kubeinstall


TARNAME="etcd-v3.2.9-linux-amd64"

echo "get etcd software"
wget https://storage.googleapis.com/etcd/v3.2.9/$TARNAME.tar.gz
tar -zxvf $TARNAME.tar.gz
cp etcd-v3.2.9-linux-amd64/etcd* /usr/bin/
mkdir /var/lib/etcd
mkdir /etc/etcd
touch /etc/etcd/etcd.conf


echo "test etcd install"
etcd --version
etcdctl --version

echo "register etcd for systemd"
cat > /usr/lib/systemd/system/etcd.service << EOF
[Unit]
Description=etcd
After=network.target
After=network-online.target
Wants=network-online.target
Documentation=https://github.com/coreos/etcd
[Service]
Type=notify
WorkingDirectory=/var/lib/etcd
EnvironmentFile=-/etc/etcd/etcd.conf
ExecStart=/usr/bin/etcd --config-file /etc/etcd/etcd.conf
Restart=on-failure
LimitNOFILE=65536
Restart=on-failure
RestartSec=5
LimitNOFILE=65536
[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable etcd.service
systemctl start etcd

etcd cluster-health
