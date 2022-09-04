

# Services - Docker

David Williamson @ Varilink Computing Ltd

------

This repository provides the means to test the roles in my [Libraries - Ansible](https://github.com/varilink/libraries-ansible) repository using Docker containers as their targets. Those Docker containers simulate the Varilink Computing Ltd server estate on the developer desktop and support the use of Ansible to manage them via SSH. This is an artificial/unusual use of Docker. You wouldn't normally use Ansible and SSH to configure Docker containers but I find this useful for the purpose of testing Ansible roles because it's so easy to tear down and rebuild containers.

## Contents of this Repository

| Location(s)                                                                | Item(s)                                                                                  |
| -------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------- |
| .env<br />deploy.env<br />docker/<br />bin/                                | Docker Compose environments, services and associated helper shell scripts.               |
| hosts.ini<br />group_vars/<br />host_vars/                                 | Ansible inventory and associated variables for the Docker containers.                    |
| roles/                                                                     | The library of Ansible roles that this repository tests, included as a submodule.        |
| hosts.yml,<br />dropbox&#8209;excludes.yml<br />hosts&#8209;completion.yml | Ansible playbooks for deploying host roles to the Docker containers.                     |
| domain.yml<br />domains/                                                   | Ansible playbook and domain details for deploying domain roles to the Docker containers. |
| readme&#8209;images/                                                       | Images that are used in this README.                                                     |

The Ansible inventory, variables and playbooks in this repository reflect the Docker containers used here to test the roles in [Libraries - Ansible](https://github.com/varilink/libraries-ansible). Of course for live deployment to the Varilink Computing Ltd server estate I use a different inventory, variables and playbooks that reflect the live environment. However the inventory, variables and playbooks in this repository serve as a useful guide to the structure required to deploy the Ansible roles, regardless of target environment.

For the most part I share the contents of `group_vars/` and `host_vars/` openly in this repository as:

- To do so is generally not a security risk because the values therein are only used in this local client testing. I'm not so stupid as to use the same values for live deployment of course!

- It gives an insight into setting values for the variables used by my Ansible roles library that might be useful to any body who wants to copy and use those roles.

## Using this Repository

To use this repository to test the roles in my [Libraries - Ansible](https://github.com/varilink/libraries-ansible) repository, you step through the following tasks:

1. [Initial Host Role Deployment](#initial-host-role-deployment)
2. [Bringing the Services up in Test Mode](#bringing-the-services-up-in-test-mode)
3. [Completing the Host Role Deployment](#completing-the-host-role-deployment)
4. [Activating Backup Synchronisation with Dropbox](#activating-backup-synchronisation-with-dropbox)
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
- mail
- web

The key consideration for scoping these composite services is that independent testing guidance is given for each under [Testing the Deployed Composite Services](#testing-the-deployed-composite-services) below.

So, for example:

- `./bin/deploy.sh` - brings up the Docker Compose services associated with **all** the composite services
- `./bin/deploy.sh backup` - limits to the *backup* composite service only
- `./bin/deploy.sh backup calendar` - limits to the *backup* and *calendar* composite services

This will bring up the required Docker Compose services as containers that will initiallly be the targets for the associated *host* roles in my [Libraries - Ansible](https://github.com/varilink/libraries-ansible) repository. That repository contains both host roles and domain roles; for example the *database* host role configures a server to host MariaDB databases whereas the *domain-wordpress-database* domain role deploys the WordPress database for a specific WordPress site to a MariaDB host server. The deployment of domain roles is dependent on the host roles having already been deployed, so we're starting with the deployment of host roles.

Whereas for testing purposes, this repository generally uses a separate Docker Composer service and associated container for each host role, in the live setup servers generally host multiple host roles; for example a live web server might host both the *wordpress* and *database* roles. It's more natural for Docker containers to provide a single service and applying this principle here is useful validation that the roles aren't defined in such a way that they can't reside on separate hosts.

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

1. To implement the *dns* composite service, the *dns_client* role in my [Libraries - Ansible](https://github.com/varilink/libraries-ansible) repository modifies the `/etc/hosts` and `/etc/resolv.conf` files in target hosts. In a Docker environment these are automatically overwritten by Docker each time a container is recreated. If we had applied that role when the containers were in *for deploy* mode then we would have lost the changes when switched to *for test* mode, so we didn't do that then and it is still pending.

2. The complete deployment of host roles can be dependent on access to services that have been deployed by Ansible. As we noted above, these were not started during the [Initial Host Role Deployment](#initial-host-role-deployment), they only became available when we brought the services up in *for test* mode. Consequently, again we have aspects of the deployment pending.

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

### Activating Backup Synchronisation with Dropbox

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

Aspects of one or more domains may now be deployed on top of the host services. The domains correspond to development projects. Each development project delivers web services and/or a mail service for a domain and may also require that maintenance of dynamic DNS entries for that domain.

A project's web services correspond to one or more host names for a project domain; for example dev.example.com, test.example.com and www.example.com. Typically the bare domain name also redirects to the www host name, i.e. example.com redirects to www.example.com. Where I provide a mail service I do so only for the domain, i.e. I don't provide separate, subdomain mail services for a domain.

A domain deployment playbook is provided within this repository, `domain.yml` to deploy a domain on top of the host roles. This playbook requires that the `domain_name` variable is provided.

So, for example:

```bash
ansible-playbook --extra-vars "domain_name=customer.com" --inventory hosts.ini domain.yml
```

Deploys **all** the configured web and mail services as well as any required dynamic DNS entries for the `customer.com` domain. Of course if you're going to deploy all aspects of a domain then you must have the containers associated with the *dynamic_dns*, *mail* and *web* composite services up in *for test* mode.

To restrict the deployment of the domain to one or more of these aspect, you can use tags, for example:

```bash
ansible-playbook --extra-vars "domain_name=home.com" --tags "dynamic_dns,web" --inventory hosts.ini domain.yml
```

Restricts the deployment to the dynamic DNS and web services requirements of the `home.com` domain, i.e. it excludes any email service requirement.

For a domain's web services, another level of filtering is possible. As explained above, a project's web services correspond to one or more host names for a project domain. If you wanted to deploy the web service for only the *test* host name within the *customer.com* domain then you can do so as follows:

```bash
ansible-playbook --extra-vars "domain_name=customer.com" --extra-vars "hostname_filter=test" --tags web --inventory hosts.ini domain.yml
```

The variable hostname_filter can also take a regular expression that each defined web service hostname must match for it to be included in the deployment.

So, for example:

```bash
ansible-playbook --extra-vars "domain_name=customer.com.yml" --extra-vars "hostname_filter=(?:dev|test)" --tags web --inventory hosts.ini domain.yml
```

Will deploy the `dev` and `test` web services for `customer.com` but not the `www` web service.

The mock-up domains `customer.com` and `home.com` are provided within this repository to provide the facility to test domain deployments - see the YAML files in this repository's `domains/` folder. These illustrate how those YAML files serve as a specification for the services to be deployed for a project domain.

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
List the collections that have been created:

```
dav:/> ls
Listing collection `/': succeeded.
Coll:   office                                 0  Jan  1  1970
Coll:   username1                              0  Jan  1  1970
Coll:   username2                              0  Jan  1  1970
dav:/>
```

Get the properties of one of the calendars that have been created:

```
dav:/> propget office/calendar
Fetching properties for `office/calendar':
DAV: principal-collection-set = <DAV:href>/</DAV:href>
DAV: current-user-principal = <DAV:unauthenticated></DAV:unauthenticated>
DAV: current-user-privilege-set = <DAV:privilege><DAV:read></DAV:read></DAV:privilege><DAV:privilege><DAV:all></DAV:all></DAV:privilege><DAV:privilege><DAV:write></DAV:write></DAV:privilege><DAV:privilege><DAV:write-properties></DAV:write-properties></DAV:privilege><DAV:privilege><DAV:write-content></DAV:write-content></DAV:privilege>
DAV: supported-report-set = <DAV:supported-report><DAV:report><DAV:expand-property></DAV:expand-property></DAV:report></DAV:supported-report><DAV:supported-report><DAV:report><DAV:principal-search-property-set></DAV:principal-search-property-set></DAV:report></DAV:supported-report><DAV:supported-report><DAV:report><DAV:principal-property-search></DAV:principal-property-search></DAV:report></DAV:supported-report><DAV:supported-report><DAV:report><DAV:sync-collection></DAV:sync-collection></DAV:report></DAV:supported-report><DAV:supported-report><DAV:report><urn:ietf:params:xml:ns:caldavcalendar-multiget></urn:ietf:params:xml:ns:caldavcalendar-multiget></DAV:report></DAV:supported-report><DAV:supported-report><DAV:report><urn:ietf:params:xml:ns:caldavcalendar-query></urn:ietf:params:xml:ns:caldavcalendar-query></DAV:report></DAV:supported-report>
DAV: resourcetype = <urn:ietf:params:xml:ns:caldavcalendar></urn:ietf:params:xml:ns:caldavcalendar><DAV:collection></DAV:collection>
DAV: owner = <DAV:href>/office/</DAV:href>
DAV: getetag = "6c6ba96cdd5b411b856ce2c4d9bcd96c"
DAV: getlastmodified = Fri, 08 Jul 2022 16:45:26 GMT
DAV: getcontenttype = text/calendar
DAV: getcontentlength = 202
DAV: displayname =
        office

DAV: sync-token = http://radicale.org/ns/sync/d41d8cd98f00b204e9800998ecf8427e
http://calendarserver.org/ns/ getctag = "6c6ba96cdd5b411b856ce2c4d9bcd96c"
urn:ietf:params:xml:ns:caldav supported-calendar-component-set = <urn:ietf:params:xml:ns:caldavcomp name='VEVENT'></urn:ietf:params:xml:ns:caldavcomp><urn:ietf:params:xml:ns:caldavcomp name='VJOURNAL'></urn:ietf:params:xml:ns:caldavcomp><urn:ietf:params:xml:ns:caldavcomp name='VTODO'></urn:ietf:params:xml:ns:caldavcomp>
urn:ietf:params:xml:ns:caldav calendar-description =
        Calendar for office

http://apple.com/ns/ical/ calendar-color =
        #2c8323ff

dav:/>
```

#### dns

A Docker Compose *dig* client is provided that can be directed to use either the *dns-external* or *dns-internal* Docker Compose services via a positional, command line parameter. Here are a series of example tests:

- An external, Internet domain:

```bash
docker-compose run --rm dig external bbc.co.uk
```

Confirms that the *dns-external* DNS is correctly using the host network's for upstream resolution.

```bash
docker-compose run --rm dig internal bbc.co.uk
```

Confirms that the *dns-internal* DNS is correctly using the *dns-external* DNS for upstream resolution.

- A host on the internal office network:

```bash
docker-compose run --rm dig external caldav
```

Confirms that the host is unknown to dns-external DNS service.

```bash
docker-compose run --rm dig internal caldav
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

When the *dynamic_dns* Docker Compose service comes up it will start running the cron scheduled jobs that update the configured dynamic records in DNS domains. These jobs write execution reports to the syslog and the service comes up with a monitor of the syslog attached to the terminal.

It is overwhelmingly probable that no DNS updates are required currently and so you will simply see something like the following three lines continuously repeating at a frequency dictated by the value of the `dynamic_dns_crontab_stride` variable:

```
Jul  3 08:30:01 dynamic-dns CRON[149]: (root) CMD (/usr/local/sbin/dynamic-dns.pl)
Jul  3 08:30:01 dynamic-dns dynamic-dns[150]: Started check for Dynamic DNS updates
Jul  3 08:30:12 dynamic-dns dynamic-dns[150]: Finished check for Dynamic DNS update
```

Of course, the cron execution numbers, date and time will be different. This tells us that the *Dynamic DNS updates* check resulted in no actions required. To test that the script does update a DNS record when required, the easiest thing is simply to go into the Linode management portal, change the IP address of one of the dynamic DNS records and then on the next scheduled execution of the script we see something like this:

```
Jul  3 08:50:01 dynamic-dns CRON[161]: (root) CMD (/usr/local/sbin/dynamic-dns.pl)
Jul  3 08:50:01 dynamic-dns dynamic-dns[162]: Started check for Dynamic DNS updates
Jul  3 08:50:12 dynamic-dns dynamic-dns[162]: The target was changed from 86.146.221.112 to 86.146.221.111 for record test in domain varilink.co.uk
Jul  3 08:50:12 dynamic-dns dynamic-dns[162]: Finished check for Dynamic DNS updates
```

Of course, the details of the target that was changed will differ.

#### mail

The main objective when testing the mail service is to confirm that emails sent are received in multiple combinations of sender and receiver. The mail sender and receiver scenarios vary according to three factors:

- Whether the client sending the email is connected *internal* or *external* to the office network
- Whether the sender's domain is the *home* domain, the domain of a *customer* that we host the mail service for or an *other* domain
- Whether the recipient's domain is the *home* domain, a *customer* domain that we host the mail service for or an *other* domain

To follow the testing steps below you must have deployed the mail service for both the *customer.com* and *home.com* domains.

##### Sender internal (to the office network) connected client

First we consider scenarios where the sender is using a client connected to our office network. In this scenario sending is only supported for senders in our *home* domain or *customer* domains, because our staff sometimes send emails from user accounts in the domains of our customers.

The recipient can be an email address in any domain. Therefore the table below contains every combination of sender domain (vertical axis) and recipient domain (horizontal axis). At each intersection the steps in transporting the mail from the sender to the receiver are listed. The steps in *italics* require manual action, the other steps are automated.

|            | Home                                                                      | Customer                                                                                                       | Other                                                                                                                                                                                                                                        |
| ---------- | ------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| *Home*     | - *Send via internal mail server*<br />- *Read from internal mail server* | - *Send via internal mail server*<br />- Relay to external mail server<br />- *Read from external mail server* | - *Send via internal mail server*<br />- Relay to external mail server<br />- Relay to mail gateway service provider using home domain's smarthost<br />- Relay to receipient's domain's MX host<br />- *Read from receipient's mailbox*     |
| *Customer* | - *Send via internal mail server*<br />- *Read from internal mail server* | - *Send via internal mail server*<br />- Relay to external mail server<br />- *Read from external mail server* | - *Send via internal mail server*<br />- Relay to external mail server<br />- Relay to mail gateway service provider using customer domain's smarthost<br />- Relay to receipient's domain's MX host<br />- *Read from receipient's mailbox* |

There follows notes on how to execute each of the manual steps highlighted above.

###### Home -> Home

*Send via internal mail server*

```bash
docker-compose run --rm mutt user1fname.user1lname@home.com internal
```

Send a test mail to `user2fname.user2lname@home.com`.

*Read from internal mail server*

```bash
docker-compose run --rm mutt user2fname.user2lname@home.com internal
```

Validate receipt of the test email from `user1fname.user1lname@home.com`.

###### Home -> Customer

*Send via internal mail server*

```bash
docker-compose run --rm mutt user1fname.user1lname@home.com internal
```

Send a test email to `userfname.userlname@customer.com`.

*Read from external mail server*

```bash
docker-compose run --rm mutt userfname.userlname@customer.com external
```

- Note that certificate by which the IMAP connection is encrypted belongs to and is issued by `customer.com`.
- Validate receipt of the test email from `user1fname.user1lname@home.com`.

###### Home -> Other

*Send via internal mail server*

```bash
docker-compose run --rm mutt user1fname.user1lname@home.com internal
```

Send a test email to any real world recipient, i.e. not in either of the mock-up domains `home.com` or `customer.com`.

*Read from recipient's mailbox*

Use whatever means you normally use to access that mailbox, of course it has to be one that you have access to.

###### Customer -> Home

*Send via internal mail server*

```bash
docker-compose run --rm mutt userfname.userlname@customer.com internal
```

- Note that certificate by which the IMAP connection is encrypted belongs to and is issued by `customer.com`.
- Send a test email to `user2fname.user2lname@home.com`.

*Read from internal mail server*

```bash
docker-compose run --rm mutt user2fname.user2lname@home.com internal
```

Validate receipt of the test email from `userfname.userlname@customer.com`.

###### Customer -> Customer

*Send via internal mail server*

```bash
docker-compose run --rm mutt userfname.userlname@customer.com internal
```

- Note that certificate by which the IMAP connection is encrypted belongs to and is issued by `customer.com`.
- Send a test email to `rolename@customer.com`.

*Read from external mail server*

```bash
docker-compose run --rm mutt rolename@customer.com external
```

- Note that certificate by which the IMAP connection is encrypted belongs to and is issued by `customer.com`.
- Validate receipt of the test email from `userfname.userlname@customer.com`.

###### Customer -> Other

*Send via internal mail server*

```bash
docker-compose run --rm mutt userfname.userlname@customer.com internal
```

- Note that certificate by which the IMAP connection is encrypted belongs to and is issued by `customer.com`.
- Send a test email to any real world recipient, i.e. not in either of the mock-up domains `home.com` or `customer.com`.

*Read from recipient's mailbox*

Use whatever means you normally use to access that mailbox, of course it has to be one that you have access to.

##### Sender external (to the office network) connected client

|              | Home                                                                                                                                                                                                     | Customer                                                                                                                                                                | Other                                                                                                                                                                                                   |
| ------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Customer** | - *Send via external mail server*<br />- Fetch by internal mail server<br />- *Read from internal mail server*                                                                                           | - *Send via external mail server*<br />- *Read from external mail server*                                                                                               | - *Send via external mail server*<br />- Relay to mail gateway service provider using customer domain's smarthost<br />- Relay to receipient's domain's MX host<br />- *Read from receipient's mailbox* |
| **Other**    | - *Send via other domain mail service provider*<br />- Relay according to MX record for home domain to external mail server<br />- Fetch by internal mail server<br />- *Read from internal mail server* | - *Send via other domain mail service provider*<br />- Relay according to MX record for customer domain to external mail server<br />- *Read from external mail server* | This scenario does not involve our services in any way and so does not concern us                                                                                                                       |

###### Customer -> Home

*Send via external mail server*

```bash
docker-compose run --rm mutt userfname.userlname@customer.com external
```

- Note that certificate by which the IMAP connection is encrypted belongs to and is issued by `customer.com`.
- Send a test email to `user2fname.user2lname@home.com`.
- Note that certificate by which the SMTP connection is encrypted belongs to and is issued by `customer.com`.

*Read from internal mail server*

```bash
docker-compose run --rm mutt user2fname.user2lname@home.com internal
```

Validate email just sent from `userfname.userlname@customer.com` has been received.

###### Customer -> Customer

*Send via external mail server*

```bash
docker-compose run --rm mutt userfname.userlname@customer.com external
```

- Note that certificate by which the IMAP connection is encrypted belongs to and is issued by `customer.com`.
- Send a test email to `rolename@customer.com`.
- Note that certificate by which the SMTP connection is encrypted belongs to and is issued by `customer.com`.

*Read from external mail server*

```bash
docker-compose run --rm mutt rolename@customer.com external
```

- Note that certificate by which the IMAP connection is encrypted belongs to and is issued by `customer.com`.
- Validate receipt of the test email from `userfname.userlname@customer.com`.

###### Customer -> Other

###### Other -> Home

*Send via other domain mail server provider*

For testing the sending of emails from a domain other than our home or customer domains, a *swaks* client tool rather than one based on *mutt*. This is because we don't need to provide an IMAP service for the *other* domain.

```bash
docker-compose run --rm swaks user2fname.user2lname@home.com
```

*Read from internal mail server*

```bash
docker-compose run --rm mutt user2fname.user2lname@home.com internal
```

Validate email just sent from `root@other.com` has been received.

###### Other -> Customer

*Send via other domain mail server provider*

```bash
docker-compose run --rm swaks userfname.userlname@customer.com
```

*Read from external mail server*

```bash
docker-compose run --rm mutt userfname.userlname@customer.com external
```

- Note that certificate by which the IMAP connection is encrypted belongs to and is issued by `customer.com`.
- Validate receipt of the test email from `userfname.userlname@customer.com`.

#### web

### Testing Limitations

Or, what can't be tested here.
