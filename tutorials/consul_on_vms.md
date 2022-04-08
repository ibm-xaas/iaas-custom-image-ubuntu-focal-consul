# Intro
This is based on the tutorial : https://learn.hashicorp.com/tutorials/consul/get-started?in=consul/getting-started

# Service Mesh
Read: https://learn.hashicorp.com/tutorials/consul/get-started?in=consul/getting-started#what-is-a-service-mesh

# What is Consul?
Consul is the control plane of Service Mesh.

Consul is a multi-networking tool that offers a fully-featured service mesh solution that solves the networking and security challenges of operationg microservices and cloud infrastructure.

# How does Consul work?

# Consul agent
Consul is available as a single binary and can be run as a long running daemon. A node running Consul binary is frequently referenced as a Consul agent. (server or client)

# Consul and proxies
The data plane in a Consul service mesh is supported and owned by the proxies.

Applications leveraging Consul will point to localhost and direct all traffic (both incoming and outgoing) to the local interface. The proxy will open up ports on localhost and direct traffic from the application to other microservices.

# Install Consul
The image has installed Consul already:
```
ubuntu@prefix-us-south-a380-in-from-the-image:~$ consul version
Consul v1.11.4
Revision 944e8ce6
Protocol 2 spoken by default, understands 2 to 3 (agent will automatically use protocol >2 when speaking to compatible agents)

ubuntu@prefix-us-south-a380-in-from-the-image:~$
```

# Run the Consul Agent

```
ubuntu@prefix-us-south-a380-in-from-the-image:~$ consul agent -dev -ui -client 0.0.0.0 -node machine
==> Starting Consul agent...
           Version: '1.11.4'
           Node ID: 'cb8f7511-8651-9175-0b14-e060f402f123'
         Node name: 'machine'
        Datacenter: 'dc1' (Segment: '<all>')
            Server: true (Bootstrap: false)
       Client Addr: [0.0.0.0] (HTTP: 8500, HTTPS: -1, gRPC: 8502, DNS: 8600)
      Cluster Addr: 127.0.0.1 (LAN: 8301, WAN: 8302)
           Encrypt: Gossip: false, TLS-Outgoing: false, TLS-Incoming: false, Auto-Encrypt-TLS: false

==> Log data will now stream in as it occurs:

```

# discover datacenter members
```
ubuntu@prefix-us-south-972d-in-from-the-image:~$ consul members
Node     Address         Status  Type    Build   Protocol  DC   Partition  Segment
machine  127.0.0.1:8301  alive   server  1.11.4  2         dc1  default    <all>
ubuntu@prefix-us-south-972d-in-from-the-image:~$
ubuntu@prefix-us-south-972d-in-from-the-image:~$ curl localhost:8500/v1/catalog/nodes
[
    {
        "ID": "341cbb2f-20c6-79b8-24d5-a6b1b8564587",
        "Node": "machine",
        "Address": "127.0.0.1",
        "Datacenter": "dc1",
        "TaggedAddresses": {
            "lan": "127.0.0.1",
            "lan_ipv4": "127.0.0.1",
            "wan": "127.0.0.1",
            "wan_ipv4": "127.0.0.1"
        },
        "Meta": {
            "consul-network-segment": ""
        },
        "CreateIndex": 13,
        "ModifyIndex": 14
    }
]
ubuntu@prefix-us-south-972d-in-from-the-image:~$
ubuntu@prefix-us-south-972d-in-from-the-image:~$ dig @127.0.0.1 -p 8600 machine.node.consul

; <<>> DiG 9.16.1-Ubuntu <<>> @127.0.0.1 -p 8600 machine.node.consul
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 50495
;; flags: qr aa rd; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 2
;; WARNING: recursion requested but not available

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;machine.node.consul.           IN      A

;; ANSWER SECTION:
machine.node.consul.    0       IN      A       127.0.0.1

;; ADDITIONAL SECTION:
machine.node.consul.    0       IN      TXT     "consul-network-segment="

;; Query time: 0 msec
;; SERVER: 127.0.0.1#8600(127.0.0.1)
;; WHEN: Thu Mar 24 03:27:06 UTC 2022
;; MSG SIZE  rcvd: 100

ubuntu@prefix-us-south-972d-in-from-the-image:~$
ubuntu@prefix-us-south-972d-in-from-the-image:~$ consul leave
Graceful leave complete
ubuntu@prefix-us-south-972d-in-from-the-image:~$
```

# Register a Service with Consul Service Discovery

## Define a service

```
ubuntu@prefix-us-south-972d-in-from-the-image:~$ cat consul.d/web.json
{
  "service": {
    "name": "web",
    "tags": [
      "rails"
    ],
    "port": 80
  }
}
ubuntu@prefix-us-south-972d-in-from-the-image:~$
ubuntu@prefix-us-south-972d-in-from-the-image:~$ consul agent -dev -ui -client 0.0.0.0 -node machine -enable-script-checks -config-dir=./consul.d
==> Starting Consul agent...
           Version: '1.11.4'
           Node ID: 'd6dabb9c-9605-2950-26fa-4974ce15ef47'
         Node name: 'machine'
        Datacenter: 'dc1' (Segment: '<all>')
            Server: true (Bootstrap: false)
       Client Addr: [0.0.0.0] (HTTP: 8500, HTTPS: -1, gRPC: 8502, DNS: 8600)
      Cluster Addr: 127.0.0.1 (LAN: 8301, WAN: 8302)
           Encrypt: Gossip: false, TLS-Outgoing: false, TLS-Incoming: false, Auto-Encrypt-TLS: false

==> Log data will now stream in as it occurs:

```

## Query services

```
ubuntu@prefix-us-south-972d-in-from-the-image:~$ dig @127.0.0.1 -p 8600 web.service.consul

; <<>> DiG 9.16.1-Ubuntu <<>> @127.0.0.1 -p 8600 web.service.consul
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 24365
;; flags: qr aa rd; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1
;; WARNING: recursion requested but not available

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;web.service.consul.            IN      A

;; ANSWER SECTION:
web.service.consul.     0       IN      A       127.0.0.1

;; Query time: 0 msec
;; SERVER: 127.0.0.1#8600(127.0.0.1)
;; WHEN: Thu Mar 24 04:17:58 UTC 2022
;; MSG SIZE  rcvd: 63

ubuntu@prefix-us-south-972d-in-from-the-image:~$ dig @127.0.0.1 -p 8600 web.service.consul SRV

; <<>> DiG 9.16.1-Ubuntu <<>> @127.0.0.1 -p 8600 web.service.consul SRV
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 47006
;; flags: qr aa rd; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 3
;; WARNING: recursion requested but not available

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;web.service.consul.            IN      SRV

;; ANSWER SECTION:
web.service.consul.     0       IN      SRV     1 1 80 machine.node.dc1.consul.

;; ADDITIONAL SECTION:
machine.node.dc1.consul. 0      IN      A       127.0.0.1
machine.node.dc1.consul. 0      IN      TXT     "consul-network-segment="

;; Query time: 0 msec
;; SERVER: 127.0.0.1#8600(127.0.0.1)
;; WHEN: Thu Mar 24 04:18:35 UTC 2022
;; MSG SIZE  rcvd: 142

ubuntu@prefix-us-south-972d-in-from-the-image:~$
ubuntu@prefix-us-south-972d-in-from-the-image:~$ dig @127.0.0.1 -p 8600 rails.web.service.consul

; <<>> DiG 9.16.1-Ubuntu <<>> @127.0.0.1 -p 8600 rails.web.service.consul
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 49121
;; flags: qr aa rd; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1
;; WARNING: recursion requested but not available

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;rails.web.service.consul.      IN      A

;; ANSWER SECTION:
rails.web.service.consul. 0     IN      A       127.0.0.1

;; Query time: 0 msec
;; SERVER: 127.0.0.1#8600(127.0.0.1)
;; WHEN: Thu Mar 24 04:20:31 UTC 2022
;; MSG SIZE  rcvd: 69

ubuntu@prefix-us-south-972d-in-from-the-image:~$
ubuntu@prefix-us-south-972d-in-from-the-image:~$ curl http://localhost:8500/v1/catalog/service/web
[
    {
        "ID": "d6dabb9c-9605-2950-26fa-4974ce15ef47",
        "Node": "machine",
        "Address": "127.0.0.1",
        "Datacenter": "dc1",
        "TaggedAddresses": {
            "lan": "127.0.0.1",
            "lan_ipv4": "127.0.0.1",
            "wan": "127.0.0.1",
            "wan_ipv4": "127.0.0.1"
        },
        "NodeMeta": {
            "consul-network-segment": ""
        },
        "ServiceKind": "",
        "ServiceID": "web",
        "ServiceName": "web",
        "ServiceTags": [
            "rails"
        ],
        "ServiceAddress": "",
        "ServiceWeights": {
            "Passing": 1,
            "Warning": 1
        },
        "ServiceMeta": {},
        "ServicePort": 80,
        "ServiceSocketPath": "",
        "ServiceEnableTagOverride": false,
        "ServiceProxy": {
            "Mode": "",
            "MeshGateway": {},
            "Expose": {}
        },
        "ServiceConnect": {},
        "CreateIndex": 15,
        "ModifyIndex": 15
    }
]
ubuntu@prefix-us-south-972d-in-from-the-image:~$
```

# service mesh and envoy

```
ubuntu@prefix-us-south-972d-in-from-the-image:~$ unzip counting-service_linux_amd64.zip
Archive:  counting-service_linux_amd64.zip
  inflating: counting-service_linux_amd64
ubuntu@prefix-us-south-972d-in-from-the-image:~$ unzip dashboard-service_linux_amd64.zip
Archive:  dashboard-service_linux_amd64.zip
  inflating: dashboard-service_linux_amd64
ubuntu@prefix-us-south-972d-in-from-the-image:~$ ls
consul.d                      counting-service_linux_amd64.zip  dashboard-service_linux_amd64.zip
counting-service_linux_amd64  dashboard-service_linux_amd64
ubuntu@prefix-us-south-972d-in-from-the-image:~$ mv counting-service_linux_amd64 counting-service
ubuntu@prefix-us-south-972d-in-from-the-image:~$ mv dashboard-service_linux_amd64 dashboard-service
ubuntu@prefix-us-south-972d-in-from-the-image:~$ envoy --version

envoy  version: d362e791eb9e4efa8d87f6d878740e72dc8330ac/1.18.2/clean-getenvoy-76c310e-envoy/RELEASE/BoringSSL

ubuntu@prefix-us-south-972d-in-from-the-image:~$
```

# service and consul config

```
ubuntu@prefix-us-south-70a9-in-from-the-image:~$ cat /etc/systemd/system/consul.service
[Unit]
Description="HashiCorp Consul - A service mesh solution"
Documentation=https://www.consul.io/
Wants=network-online.target
After=network-online.target
ConditionFileNotEmpty=/etc/consul.d/consul.hcl

[Service]
EnvironmentFile=-/etc/consul.d/consul.env
User=consul
Group=consul
ExecStart=/usr/bin/consul agent -config-file=/etc/consul.d/consul.hcl
ExecReload=/bin/kill --signal HUP $MAINPID
KillMode=process
KillSignal=SIGTERM
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
ubuntu@prefix-us-south-70a9-in-from-the-image:~$ cat /etc/consul.d/consul-vm.hcl
data_dir = "/tmp/consul/server"

server           = true
bootstrap_expect = 1
advertise_addr   = "52.118.149.52"
client_addr      = "0.0.0.0"
bind_addr        = "0.0.0.0"

ports {
  grpc = 8502
}

enable_central_service_config = true

ui_config {
  enabled          = true
}

connect {
  enabled = true
}

datacenter = "dc1"


config_entries {
  bootstrap = [
    {
      kind = "proxy-defaults"
      name = "global"
    }
  ]
}


ubuntu@prefix-us-south-70a9-in-from-the-image:~$ß
```
