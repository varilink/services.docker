

# Services - Docker

David Williamson @ Varilink Computing Ltd

------

This repository provides the means to test the roles in my [Libraries - Ansible](https://github.com/varilink/libraries-ansible) repository using Docker containers as their targets. Those Docker containers simulate the Varilink Computing Ltd server estate on the developer desktop and support the use of Ansible to manage them via SSH. This is an artificial/unusual use of Docker. You wouldn't normally use Ansible and SSH to configure Docker containers but I find this useful for the purpose of testing Ansible roles because it's so easy to tear down and rebuild containers.

## Contents of this Repository

| Location(s)                                                                    | Item(s)                                                                          |
| ------------------------------------------------------------------------------ | -------------------------------------------------------------------------------- |
| .env<br />deploy.env<br />docker/<br />bin/                                    | Docker Compose environments, services and associated helper shell scripts        |
| hosts.ini<br />group_vars/<br />host_vars/                                     | Ansible inventory and associated variables for the Docker containers             |
| roles/                                                                         | The library of Ansible roles that this repository tests, included as a submodule |
| hosts.yml,<br />domain.yml<br />dropbox-excludes.yml<br />hosts-completion.yml | Ansible playbooks for deploying those roles to the Docker containers             |
| readme-images/                                                                 | Images that are used in this README                                              |

The Ansible inventory, variables and playbooks in this repository reflect the Docker containers used here to test the roles in [Libraries - Ansible](https://github.com/varilink/libraries-ansible). Of course for live deployment to the Varilink Computing Ltd server estate I use a different inventory, variables and playbooks that reflect the live environment. However the inventory, variables and playbooks in this repository serve as a useful guide to the structure required to deploy the Ansible roles, regardless of target environment.

For the most part I share the contents of `group_vars/` and `host_vars/` openly in this repository as:

- To do so is generally not a security risk because the values therein are only used in this local client testing. I'm not so stupid as to use the same values for live deployment of course!

- It gives an insight into setting values for the variables used by my Ansible roles library that might be useful to any body who wants to copy and use those roles.

## Using this Repository

To use this repository to test the roles in my [Libraries - Ansible](https://github.com/varilink/libraries-ansible) repository, you step through the following tasks:

1. [Initial Host Role Deployment](#initial-host-role-deployment)
2. [Bringing the Services up in Test Mode](#bringing-the-services-up-in-test-mode)
3. [Completing the Host Role Deployment](#completing-the-host-role-deployment)
4. [Activating Dropbox Synchronisation for the Backup Composite Service](#activating-dropbox-synchronisation-for-the-backup-composite-service)
5. [Deploying the Domain Roles](#deploying-the-domain-roles)
6. [Testing the Deployed Composite Services](#testing-the-deployed-composite-services)

### Initial Host Role Deployment

This repository relies on the concept of bringing the Docker services that simulate the Varilink Computing Ltd server estate up in one of two modes, *for deploy* and *for test*. To begin the deployment of the Ansible roles to containers we must first bring the required containers up in *for deploy* mode. In this mode the containers are all identical implementations of an SSH server for Ansible to connect to.

To bring containers up in *for deploy* mode you **must** use a provided helper script that wraps the relevant `docker-compose` commands with other required actions. This script can be called from the project's root folder as follows:

```bash
./bin/deploy.sh [SERVICE]...
```

Where `[SERVICE]...` is an optional (can be omitted) list of one or more *composite* services to limit the Docker Compose services brought up. Those composite services group one or more Docker Compose services that coordinate to deliver a higher-level service than the individual Docker Compose services.

The composite services are:

- backup
- calendar
- dns
- dynamic_dns
- email
- web

The key consideration for scoping these composite services is that independent testing guidance is given for each under [Testing the Deployed Composite Services](#testing-the-deployed-composite-services) below.

So, for example:

- `./bin/deploy.sh` - brings up the Docker Compose services associated with **all** the composite services
- `./bin/deploy.sh backup` - limits to the *backup* composite service only
- `./bin/deploy.sh backup calendar` - limits to the *backup* and *calendar* composite services

This will bring up the required Docker Compose services as containers that will initiallly be the targets for the associated **host** roles in my [Libraries - Ansible](https://github.com/varilink/libraries-ansible) repository. That repository contains both host roles and domain roles; for example the *database* host role configures a server to host MariaDB databases whereas the *domain-wordpress-database* domain role deploys the WordPress database for a specific WordPress site to a MariaDB host server. The deployment of domain roles is dependent on the host roles having already been deployed, so we're starting with the deployment of host roles.

Whereas for testing purposes, this repository uses a separate Docker Composer service and associated container for each host role, in the live setup servers generally host multiple host roles; for example a live web server might host both the *wordpress* and *database* roles. It's more natural for Docker containers to provide a single service and applying this principle here is useful validation that the roles aren't defined in such a way that they can't reside on separate hosts.

With the required Docker Compose services up in this *for deploy* state, the associated Ansible roles can now be deployed to them, either for **all** host roles:

```bash
ansible-playbook --inventory hosts.ini hosts.yml
```

Or only for those Ansible roles associated with a single composite service; for example the *web* composite service:

```bash
ansible-playbook --inventory hosts.ini --limit web hosts.yml
```

Or only for those Ansible roles associated with multiple composite services; for example the *calendar* and *dns* composite services.

```bash
ansible-playbook --inventory hosts.ini --limit "calendar,dns" hosts.yml
```

The composite services correlate between the Docker Compose and Ansible configurations. You should of course use the same composite service(s) for the Ansible deployment that you used to bring up Docker containers in *for deploy* mode.

### Bringing the Services Up In Test Mode

As we noted above, when we brought the Docker Compose services up in *for deploy* mode their associated containers are purely acting as SSH servers. If we had just deployed host roles to true servers then the associated services would already be up and running on those servers. The packages installed via APT would have automatically started Apache, MySQL, Radicale, etc. using the  *systemd* system and service manager.

However, here we've used Docker containers that do not use such a system and service manager and instead typically run a single service as defined by their ENTRYPOINT and CMD. So, in contrast to what would happen in a deployment to true servers, the services that are associated with the host roles that we've just deployed are **not** yet running.

We must now stop the Docker Compose services that are running in *for deploy* mode and bring them up again in *for test* mode. Again, a helper script that is provided **must** be used to do this. First, stop the services that are in *for deploy* mode using `Ctrl+C` and then bring up the *required* composite services again as follows:

```bash
./bin/test.sh [SERVICE]...
```

Where `[SERVICE]...` is again optional and if provided must be a list of one or more composite services as described above for the `./bin/deploy.sh` script. If you're working through each of the steps required to deploy and test one or more composite services then you should of course use the same value, values of absence of a value that you used in [Initial Host Role Deployment](#initial-host-role-deployment).

When using *for test* mode, before the Docker Compose services come up again, you will notice that a series of Docker commits and the recreation of Docker Compose services has happened. The Docker Compose services used in *for deploy* mode all use a common image, which is tagged `varilink/services`. As already stated, this implements an SSH server for Ansible to connect to.

When we bring the services up in *for test* mode, it recreates the containers, since their Docker Compose service definition is changed from that which was used to create them in *for deploy* mode. We will lose the results of the Ansible deployment so far to those containers unless we do something about that. To retain the results of that Ansible deployment, the `./bin/test.sh` helper script first commits the containers in their current state to service specific images that are used in *for test* mode.


### Completing the Host Role Deployment ###

When the services are initially brought up in `for test` mode the deployment of host roles is incomplete. There are two reasons for this:

1. To implement the *dns* composite service, the Ansible deployment modifies the `/etc/hosts` and/or `/etc/resolv.conf` files in target hosts. In a Docker environment these are automatically overwritten by Docker each time a container is recreated. Thus when we switched from *for deploy* to *for test* mode we lost the changes that Ansible had made to these files.
2. The complete deployment of host roles can be dependent on access to services that have been deployed by Ansible. As we noted above, these were not started during the [Initial Host Role Deployment](#initial-host-role-deployment), they only became available when we brought the services up in *for test* mode.

With the services now up in *for test* mode, you must complete the host role deployment by running:

```bash
ansible-playbook --inventory hosts.ini hosts-completion.yml
```

if you're testing all composite services, or:

```bash
ansible-playbook --inventory hosts.ini --limit web hosts-completion.yml
```

if you're testing just the web composite service, or:

```bash
ansible-playbook --inventory hosts.ini --limit "calendar,dns" hosts-completion.yml
```

if you're testing the *calendar* and *dns* composite services. You get the picture.

Note that if you're testing include the *backup* composite service then when you first bring the services up in *for test* mode you will see these errors in the sysout:

```
backup-director_1         | ERROR 2002 (HY000): Can't connect to MySQL server on 'database-internal' (115)
backup-director_1         | Creation of Bacula MySQL tables failed.
backup-director_1         | bacula-dir: dird.c:1229-0 Could not open Catalog "MyCatalog", database "bacula".
```

This happens because the *backup-director* Docker Compose service immediately tries to connect to the database provided by the *database-internal* Docker Compose service in order to create its catalog tables. However it finds itself unable to do so because the database user that it tries to connect as has not yet been created by the *database-internal* Docker Compose service.

Anticipating this, the *backup-director* Docker Compose service restarts on failure but you must take the steps above to complete the host role deployment in good time, before it stops attempting to restart. This will complete the deployment of the *database* role to the *database-internal* Docker Compose service, which includes the database user that the *backup-director* Docker Compose service is attempting to connect as. Afterwards you will soon see this message in the sysout:

```
backup-director_1         | Creation of Bacula MySQL tables succeeded.
```

### Activating Dropbox Synchronisation for the Backup Composite Service

The *backup* composite service utilises synchronisation with Dropbox for making off-site copies of backup files. If you're using the *backup* composite service then it is now necessary to activate synchronisation between the *backup-director* Docker Compose service and the Dropbox account that you're using for your off-site copies.

With the *backup-director* Docker Compose service now up in *for test* mode, you exec into its container from your desktop host:

```bash
docker exec -it services_backup-director /bin/bash
```

Start the Dropbox daemon from within the container:

```bash
gosu bacula bash -c '~/.dropbox-dist/dropboxd'
```

Soon, this message but with a different nonce value will appear in the sysout:

```
This computer isn't linked to any Dropbox account...
Please visit https://www.dropbox.com/cli_link_nonce?nonce=f9864c49d1068e386ffd2c43081bbec7 to link this device.
```

Copy the link, paste it into the address bar of a web browser on the host and action the steps needs to link the container with your Dropbox account. When you've done this successfully, as message like this will appear in the sysout where you're executing the Dropbox daemon:

```
This computer is now linked to Dropbox. Welcome Dave
```

Of course, you might not be called Dave! If you examine the linked devices for your Dropbox account you will see that an entry has appeared that looks something like this:

![Dropbox linked device](./readme-images/dropbox-linked-device.png)

Of course you might not live in Long Eaton, United Kingdom!

You can now stop the Dropbox daemon that you started in the foreground using `Ctrl+C` and restart it in the background using the Python helper script that Dropbox supply and which Ansible has deployed to the container for the *backup-director* Docker Compose service:

```bash
gosu bacula bash -c '~/dropbox.py start'
```

As things stand, the container for the *backup-director* Docker Compose service is now synchronising with your Dropbox account for all files, which is not what we want. So, in pretty short order, before too much superfluous content is downloaded to the container, you should run this command in your desktop host:

```bash
ansible-playbook --inventory hosts.ini dropbox-excludes.yml
```

This limits the synchronisation to a singe folder dictated by the `backup_copy_folder` variable in Ansible.

### Deploying the Domain Roles

*To be done*

### Testing the Deployed Composite Services

You can now start testing the deployed composite services! The testing of each composite service is specific to the functionality of that service. To facilitate the testing, this repository provides a number of related client tools, implemented as Docker Compose services. Testing instructions follow for each composite service in turn.

#### backup

Run the provided *bconsole* client:

```bash
docker-compose run --rm bconsole
```

It should successfully connect to the backup director service:

```
Connecting to Director services_backup-director:9101
1000 OK: 103 services_backup_director Version: 9.4.2 (04 February 2019)
Enter a period to cancel a command.
*
```

Confirm that you can successfully check the status of the *Director*, *Storage* and a sample of *Client* resources. If the *backup* composite service is running then it should be possible to do this for any of the `backup-director`, `database-internal`, `dns-external` and `dns-internal` clients. If you also have other composite services up then that list will be longer.

#### calendar

Run the provided *cadaver* client:

```bash
docker-compose run --rm cadaver
```

You should successfully connect to the calendar (caldav) service:

```
dav:/> 
```

#### dns

A Docker Compose *dig* client is provided that can be directed to use either the *dns-external* or *dns-internal* Docker Compose services via a positional, command line parameter. Here are a series of example tests:

- An external, Internet domain:

```bash
docker-compose run --rm external dig bbc.co.uk
```

Confirms that the *dns-external* DNS is correctly using the host network's for upstream resolution.

```bash
docker-compose run --rm internal dig bbc.co.uk
```

Confirms that the *dns-internal* DNS is correctly using the *dns-external* DNS for upstream resolution.

- A host on the internal office network:

```bash
docker-compose run --rm dig external calendar
```

Confirms that the host is unknown to dns-external DNS service.

```bash
docker-compose run --rm dig internal calendar
```

Confirms that the host is known to the dns-internal DNS service.

- A service alias that should resolve differently on the office network to the Internet:

```imap
docker-compose run --rm dig internal imap
```

Confirms that imap clients on the office network will resolve *imap* to the *email-internal* host.

```bash
docker-compose run --rm dig external imap
```

Confirms that imap clients on the Internet will resolve *imap* to the *email-external* host.

#### dynamic_dns

When the `dynamic_dns` Docker Compose service comes up it runs the *cron* in the foreground. All being well the *cron* scheduled jobs that update the dynamic records in our DNS domains will start running. Open a shell CLI within the service's container:

```bash
docker exec -it services_dynamic-dns /bin/bash
```

Start following the *syslog* output:

```bash
tail -f /var/log/syslog
```

It's overwhelmingly probable that no DNS updates are required currently, so we should probably just see pairs of lines as follows appearing in the *syslog* according to the schedule:

```
Jun 22 09:45:01 dynamic-dns dynamic-dns[136]: Started check for Dynamic DNS updates
Jun 22 09:45:11 dynamic-dns dynamic-dns[136]: Finished check for Dynamic DNS updates
```

In other words, the check resulted in no actions required. To test that the script does update a DNS record when required, the easiest thing is simply to go into the Linode management portal, change the IP address of one of the dynamic DNS records and then on the next scheduled execution of the script we see something like this:

#### email

There are multiple email scenarios that vary according to the following conditions:

- Whether the client sending the email is connecting via the office network (*office*) or via the *Internet*
- Whether the sender domain is the *home domain*, the domain of a *customer* that we host the email service for or an *other* domain
- Whether the recipient domain is the *home* domain, a *customer* domain that we host the email service for or an *other* domain

Two tables follow. The first reflects the scenario where the sender is using a client connected to our office network. In this scenario sending is only supported for our *home* domain or *customer* domains that we host - see vertical column.

##### Office client

|              | Home                                                         | Customer                                                     | Other                                                        |
| ------------ | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| **Home**     | - Send to internal email server via SMTP<br />- Read from internal email server via IMAP | - Sent via SMTP to internal email server<br />- Relayed to external email server<br />- Read via IMAP from external email server | - Send to internal email server via SMTP <br />- Relay to external email server<br />- Relay to email gateway service provider using home domain's smarthost |
| **Customer** | - Sent via SMTP to internal email server<br />- Relayed to external email server<br />- Read via IMAP from external email server | - Sent via SMTP to internal email server<br />- Relayed to external email server<br />- Read via IMAP from external email server | - Sent via SMTP to internal email server<br />- Relayed to external email server<br />- Relayed to external email gateway service provider using customer domain's smarthost |

###### Home -> Home

Send to internal email server via SMTP:

```bash
docker-compose run --rm mutt office username1
```

In mutt send a test email to username2@varilink.co.uk

Read from internal email server via IMAP:

```bash
docker-compose run --rm mutt office username2
```

Read the email just sent from username1@varilink.co.uk

###### Home -> Customer

###### Home -> Other

Send to internal email server via SMTP

```bash
docker-compose run --rm mutt office username1
```

In mutt send a test email to any real world recipient in another domain. I use ping@tools.mxtoolbox.com so that I get an [MxToolbox deliverability report](https://mxtoolbox.com/deliverability).

###### Customer -> Home

###### Customer -> Customer

###### Customer -> Other

##### Internet client

|              | Home                                                         | Customer                                                     | Other                                                        |
| ------------ | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| **Home**     | - Sent via SMTP to external email server<br />- Fetched by internal email server<br />- Read via IMAP from internal email server | - Sent via SMTP to external email server<br />- Read via IMAP from external email server | - Sent via SMTP to external email server<br />- Relayed to external email gateway server provider using home domain's smarthost |
| **Customer** | - Sent via SMTP to external email server<br />- Fetched by internal email server<br />- Read via IMAP from internal emal server | - Sent via SMTP to external email server<br />- Read via IMAP from external email server | - Sent via SMTP to external email server<br />- Relayed to external email gateway server provider using customer domain's smarthost |
| **Other**    | - Sent via SMTP to other domains email service provider<br />- Relayed according to MX record for home domain to external email server<br />- Fetched by internal email server<br />- Read via IMAP from internal email server | - Sent via SMTP to other domains email service provider<br />- Relayed according to MX record for customer domain to external email server<br />- Read via IMAP from external email server | This scenario does not involve our services in any way and so does not concern us |

###### Home -> Home

###### Home -> Customer

###### Home -> Other

###### Customer -> Home

###### Customer -> Customer

###### Customer -> Other

###### Other -> Home

###### Other -> Customer

#### web

*To be done*
