# Services - Docker

David Williamson @ Varilink Computing Ltd

------

There are a range of services deployed across the Varilink Computing Ltd server estate; for example, backup, monitoring, web hosting, etc. Management of these services is automated using Ansible.

This repository implements containers using Docker Compose that facilitates a simulation of that server estate on a client machine. Furthermore, they support the use of Ansible to manage those containers via SSH. This provides the means for testing the Ansible playbooks and roles that are used to manage Varilink Computing Ltd services.

This is an artificial/unusual use of Docker but I find it useful for testing purposes because it's so easy to tear down and rebuild containers.

## Build Service Containers

The containers use a common image that can be built via this command:

```bash
docker-compose --file ssh.yml build [service]
```

The *service* is optional. If you don't provide it then the build will happen multiple times but since the second build and onward use the cached result of the first build this isn't an issue. Throughout this repository, the Docker Compose services map to the various roles of servers that host Varilink Computing Ltd services; for example, "backup director", "database", "reverse proxy", etc.

## Deploy Services to Containers Using Ansible

```bash
docker-compose --file ssh.yml up
```

## Test Outcome of Ansible Deployment

