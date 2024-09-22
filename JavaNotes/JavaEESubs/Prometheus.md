## Install Golang

```shell
wget https://studygolang.com/dl/golang/go1.15.2.linux-amd64.tar.gz

tar -xvf go1.15.2.linux-amd64.tar.gz
mv go /usr/local/

vim /etc/profile
...
export GOROOT=/usr/local/go
export PATH=$PATH:$GOROOT/bin
....

source /etc/profile

# check go 
go version
```

## Install  Prometheus

https://prometheus.io/

- https://prometheus.io/download/
- `wget https://github.com/prometheus/prometheus/releases/download/v2.21.0/prometheus-2.21.0.freebsd-amd64.tar.gz`
- `tar -xvf prometheus-2.21.0.linux-amd64.tar.gz `
- `mv prometheus-2.21.0.linux-amd64 /usr/local/prometheus`
- ./prometheus
- 访问IP地址:9090
- `chmod +x /usr/local/prometheus/prom*`
- `cp -rp /usr/local/prometheus/promtool /usr/bin/`
- `promtool -h`

#### Systemd  Service

```shell
cat > /etc/systemd/system/prometheus.service <<EOF
[Unit]
Description=Prometheus
Documentation=Prometheus

[Service]
ExecStart=/usr/local/prometheus/prometheus --config.file=/usr/local/prometheus/prometheus.yml --storage.tsdb.path=/data/prometheus --web.enable-lifecycle --storage.tsdb.retention.time=180d
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
```

#### Start Server

```shell
systemctl status prometheus
systemctl start prometheus
systemctl enable prometheus
```



## Install Grafana

```shell
wget https://dl.grafana.com/oss/release/grafana-6.7.3-1.x86_64.rpm
yum localinstall grafana-6.7.3-1.x86_64.rpm
```

#### Start Server

```shell
systemctl daemon-reload
systemctl enable grafana-server.service
systemctl start grafana-server.service
```

http://ip:3000



## Install node-exporter

- `wget https://github.com/prometheus/node_exporter/releases/download/v1.0.1/node_exporter-1.0.1.linux-amd64.tar.gz`
- `tar -xvf node_exporter-1.0.1.linux-amd64.tar.gz`
- `mv node_exporter-1.0.1.linux-amd64/ /usr/local/node_exporter`

#### Systemd Service

```shell
cat > /etc/systemd/system/node_exporter.service <<EOF
[Unit]
Description=node_exporter
After=network.target 

[Service]
ExecStart=/usr/local/node_exporter/node_exporter
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
```

#### Start server

```shell
systemctl daemon-reload
systemctl enable node_exporter
systemctl start node_exporter
systemctl status node_exporter
```

http://ip:9100/metrics



## Monitor Linux

```shell
vim /usr/local/prometheus/prometheus.yml


- job_name: 'Linux'
    static_configs:
    - targets: ['192.168.110.37:9100']
    
systemctl restart prometheus
```

http://ip:9090/targets



## Config gtafana

 https://grafana.com/grafana/dashboards 

