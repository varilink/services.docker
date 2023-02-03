# Services - Docker

David Williamson @ Varilink Computing Ltd

------

See my blog article [Testing Ansible Roles Using Containers](https://www.varilink.co.uk/testing-ansible-roles-using-containers) to read about the purpose of this repository and how what it does was achieved.

## Contents of this Repository

| Item                             | Contents                                                                                                                                  |
| -------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| build/                           | Build contexts for the Docker Compose services defined by this repository.                                                                |
| envs/                            | Configuration of the [Deployment Environments](#deployment-environments).                                                                 |
| my&#8209;roles/                  | Ansible roles that provide a wrapper to the those in the [Libraries - Ansible](https://github.com/varilink/libraries-ansible) repository. |
| readme&#8209;images/             | Images that are used in this README.                                                                                                      |
| roles/                           | The [Libraries - Ansible](https://github.com/varilink/libraries-ansible) repository, included here as a submodule.                        |
| .env<br>docker&#8209;compose.yml | The master Docker Compose configuration for this repository.                                                                              |

### Deployment Environments

The `envs/` directory contains the Ansible inventories and playbooks and Docker Compose configuration for different deployment environments. Three deployment environments are defined:

*live*<br>
Simulation of the live hosts that the Varilink Computing Ltd services are deployed on. This reflects both the mapping of service roles to hosts and the Debian release on each host.

*to-be*<br>
Simulation of the to-be hosts that the Varilink Computing Ltd services will be deployed on. Relative to live this typically reflects planned upgrades to Debian releases on one or more hosts. It may also reflect changes to the list of hosts and the mapping of services to hosts.

*distributed*<br>
In live multiple services are deployed to a single host; for example, a WordPress host typically has the full stack of `reverse_proxy`, `wordpress_apache` and `database` roles on it. However, the roles are defined such that they could be distributed across hosts on a one-host to one-service basis. This environment is configured to test that distributed deployment model works.

Each deployment environment defines Ansible variables in `group_vars/` and `host_vars/` directories associated with their inventory and playbooks. Since those environments are **not** the Varilink Computing Ltd live environment, I share their Ansible inventories, playbooks and (most importantly) variables very openly in this repository. The serve as a useful example of how to use the [Libraries - Ansible](https://github.com/varilink/libraries-ansible) repository. The equivalent Ansible artefacts that I use to automate the management of the Varilink Computing Ltd live environment can not be shared as openly since they contain sensitive data.

For more information about the variables used by the [Libraries - Ansible](https://github.com/varilink/libraries-ansible) repository, see [Variables](https://github.com/varilink/libraries-ansible#variables) in its README.

## Enabling Integration with Third-Party Cloud Services

[Integration with Third-Party Cloud Services](https://github.com/varilink/libraries-ansible#integration-with-third-party-cloud-services) in the README of my [Libraries - Ansible](https://github.com/varilink/libraries-ansible) repository describes the integration with Dropbox, Let's Encrypt, Linode and Mailgun cloud services that repository supports. By default, none of those integrations are enabled within this repository, which has the following implications:

- The backup service will function normally in all aspects except that it will not use Dropbox to make off-site copies of backups that it makes of hosts that emulate those that reside on our internal, office network.

- Self-signed certificates will be used by the mail and WordPress site hosting services.

- Whilst the `dynamic_dns` and `mail_certificates` roles are deployed by playbooks in this repository, they don't do anything until/unless Linode integration is enabled here.

- The `mail_external` role deployed by this repository will send mail by direct SMTP connection to an addressee's MX host rather than by using Mailgun as a smarthost, with a likely, consequent adverse effect on deliverability.

The steps to enable these integrations are described in [Integration with Third-Party Cloud Services](https://github.com/varilink/libraries-ansible#integration-with-third-party-cloud-services) in the README of my [Libraries - Ansible](https://github.com/varilink/libraries-ansible) repository. For those steps that involve the setting of variable values, this repository contains inactive content that can easily be activated as follows, to give you a head start:

**Dropbox**<br>
Uncomment the line that sets `backup_linked_to_dropbox` to `yes` in the file `envs/[env]/inventory/group_vars/all/public.yml` where `[env]` is the environment that you're working with, either live or to-be or distributed.

Note that this repository overrides the value of `backup_copy_folder` to `bacula-test` rather than `bacula`, which is it's default value in the [Libraries - Ansible](https://github.com/varilink/libraries-ansible) repository. This is in case you're using the same Dropbox account for both off-site copies of on-site backups of a live server estate and backup testing using this repository.

So, if you're going to enable Dropbox integration in this repository then you'll need to create a `bacula-test` top-level folder in your Dropbox account, that is unless you choose to set `backup_copy_folder` to another folder name, in which case you'll have to use that folder name instead.

**Let's Encrypt**<br>
To enable integration with Let's Encrypt for the WordPress website hosts that are configured to use SSL in this environment, uncomment the line that sets `wordpress_site_uses_ca` to `yes` in the file `envs/[env]/inventory/group_vars/all/public.yml` where `[env]` is the environment that you're working with, either live or to-be or distributed.

To enable integration with Let's Encrypt for the mail service, uncomment the line that sets `mail_uses_ca` to `yes` in the file `envs/[env]/inventory/group_vars/all/public.yml` where `[env]` is the environment that you're working with, either live or to-be or distributed. You **must** also enable Linode integration - see below.

**Linode**<br>
Once you have obtained your API personal access token (see [Integration with Third-Party Cloud Services](https://github.com/varilink/libraries-ansible#integration-with-third-party-cloud-services) in the README of my [Libraries - Ansible](https://github.com/varilink/libraries-ansible) repository), to enable the integration with Linode in this repository:

1. Rename `envs/[env]/inventory/group_vars/all/template-private.yml` to `envs/[env]/inventory/group_vars/all/private.yml` since it will contain highly sensitive data and so will not be tracked by Git in this repository as the `.gitignore` includes any file named `private.yml`. This is a precaution in case you inadvertently share this file by pushing your clone of this repository to a public origin.

2. Uncomment the line that sets `dns_linode_api` in this file and replace the `...` in that line with the key of your API token.

**Mailgun**<br>


## Using this Repository

To use this repository to test the roles in my [Libraries - Ansible](https://github.com/varilink/libraries-ansible) repository, you step through the following tasks:

1. [Bring up an Environment](#bring-up-an-environment)
2. [Deploy the Composite Services](#deploy-the-composite-services)
3. [Activate Backup Synchronisation with Dropbox](#activate-backup-synchronisation-with-dropbox)
4. [Deploying the Projects](#deploying-the-projects)

### Bring up an Environment

To bring up the Docker Compose services that simulate an environment:

*Bash*
```bash
docker-compose run --rm -T raise-hosts [SERVICES...] | bash
```

*PowerShell*
```powershell
docker-compose run --rm -T raise-hosts [SERVICES...] | PowerShell.exe
```

All commands shown in this README should be invoked in this repository's root folder. Here the `docker-compose run --rm -T raise-hosts [SERVICE...]` command generates a list of other `docker-compose` and `docker` commands that are in turn executed by piping them into the shell command. You could if you wished exclude the pipe if you want to see what those commands are rather than execute them, though this would do nothing of course.

Note that the `docker-compose` and `docker` command syntaxes are shell neutral and it is the other aspects that wrap around these commands that vary across shell environment; in this case the pipe action, `| bash` for Bash and `| PowerShell.exe` for PowerShell environments, which are the two that I have tested this repository in.

#### Selecting the Environment

The commands above will bring up services in the *live* environment, because this is set as the value of the `MYENV` environment variable in the `.env` file. If you wish to work with one of the other [Deployment Environments](#deployment_environments) then you're likely to want to do so for an extended period that includes the running of many of the commands given in this README. For that reason, I recommend that you change the default value of `MYENV` to do this, either by editing the `.env` file or by setting the value in your desktop shell session; for example, if you wanted to work in the *to-be* environment for a while:

*Bash*
```bash
export MYENV=to-be
```

*PowerShell*
```powershell
$env:MYENV = 'to-be'
```

To subsequently clear a value set in your desktop shell session:

*Bash*
```bash
unset MYENV
```

*PowerShell*
```powershell
Remove-Item Env:\MYENV
```

#### Limiting the "Composite Services"

The `[SERVICES...]` argument(s) in the command to bring up an environment's Docker Compose services is an optional (can be omitted) list of one or more *composite* services that can be used to limit the Docker Compose services brought up. Those composite services group one or more Docker Compose services that coordinate to deliver a higher-level service than the individual Docker Compose services. If this argument is omitted then all the Docker Compose services are brought up.

The composite services are:
- backup
- calendar
- dns
- dynamic_dns
- mail
- web

Each of these composite services can be stood up and tested independently of the others, though note that the *dns* service is a dependency for all of the other composite services and so is always in scope.

To bring up all of the composite services and deploy all Ansible roles to them is time consuming. Therefore you might want to limit the composite services that you're working with, because to do so speeds everything up.

Here are some examples of bringing up composite services. All of the examples from this point onwards are based on Bash as we have now covered the variations between Bash and Powershell environments.

- Bring up all composite services:

```bash
docker-compose run --rm -T raise-hosts | bash
```

- Bring up only the *backup* composite service:

```bash
docker-compose run --rm -T raise-hosts backup | bash
```

- Bring up only the *backup* and *calendar* composite services:

```bash
docker-compose run --rm -T raise-hosts backup calendar | bash
```

As explained above, the *dns* service will come up in all three of these examples.

#### Passing options to docker-compose up

When we run the `raise-hosts` service above, we pipe its output into a shell. If you run it without piping it output into a shell, you will of course see the commands that it generates instead.

For example, running this command in the default, *live* environment:
```bash
docker-compose run --rm raise-hosts backup calendar
```

Generates these `docker` and `docker-compose` commands:
```
docker-compose --env-file envs/live/.env stop dns-external hub
docker-compose --env-file envs/live/.env rm --force dns-external hub
docker volume rm services_bacula-home
docker-compose --env-file envs/live/.env up dns-external hub
```

Note there that we've dropped the `-T` option, which disables pseudo-tty allocation. We only need to do this when we pipe the output, which we're not doing here. Of course, not piping the output displays the commands but doesn't run any of them, so it's pointless other than that it let's us see them.

Any argument to the `raise-hosts` Docker Compose service that starts with `-` is passed directly through to the last of the generated commands.

For example, running this command in the default, *live* environment:
```bash
docker-compose run --rm raise-hosts backup calendar --build --remove-orphans
```

Generates these `docker` and `docker-compose` commands:
```
docker-compose --env-file envs/live/.env stop dns-external hub
docker-compose --env-file envs/live/.env rm --force dns-external hub
docker volume rm services_bacula-home
docker-compose --env-file envs/live/.env up --build --remove-orphans dns-external hub
```

Observe that the `--build --remove-orphans` have been passed through to the `docker-compose --env-file envs/live/.env up` command. Normally, you don't have to think about this but if say you had edited the build instructions for the `varilink/services/sshd` image, requiring a rebuild, or altered any Docker Compose services that use it, creating orphans, then you can see that this feature would come in useful.

### Deploy the Composite Services

Now that we have the required (as defined by the scope of composite services) Docker Compose services up as containers, we can proceed to deploy the composite services to them as follows:

```bash
docker-compose run --rm playbook services [SERVICES...] [OPTIONS...]
```

Since we must run the above command in a different shell session to the one that we used to bring the services up in, we must again take heed to the instructions under [Selecting the Environment](#selecting-the-environment) above. If we had set `MYENV` within the shell session in which we brought the composite services up, then we must do so again to use the same environment in the shell session that run the deploy command in, otherwise it will try to deploy using the wrong environment specification.

By contrast, if you edited the value of the `MYENV` variable in the `.env` file instead, then this will take effect in any and all shell sessions that you open.

The `[SERVICES...]` argument(s) work exactly as they did in the previous step. As you run through each step in this [Using this Repository](#using_this_repository) section, then you **must** be consistent and keep repeating the `[SERVICES...]` setting that you used in the [Bring up an Environment](#bring-up-an-environment) step. If you limit the composite services then that has the effect of not only limiting the Docker Compose services brought up, but also limiting the target hosts and tasks run in this step, according to the same functional scope.

`OPTIONS...` is an optional (can be omitted) list of any of the options that the `ansible-playbook` command accepts, with the exception of the `--inventory`, `--limit` or `--tags` options as these are set by the wrapper provided by our `playbook` Docker Compose service. For example, you could enter the following to include the `--step` option of the `ansible-playbook` command, while also limiting its action to the roles and hosts required by the *backup* and *calendar* composite services:

```bash
docker-compose run --rm playbook services backup calendar --step
```

#### Unreachable/Failed Tasks During Deployment

There are a couple of reasons why you may see *unreachable* or *failed* task results reported during the deployment of the composite services.

Firstly, if you are running with anything other than all composite services then you will see repeated *unreachable* reports for the `Gather IP address for each host matching a pattern` task in the `dns` role. These can just be ignored.

This is because that task tries to connect to every host that it is configured to provide DNS lookups for in order to gather the value of the `ansible_default_ipv4` variable of each host. If it can't connect, then it will simply omit the lookup for that host in its configuration.

In live deployment this situation could happen and in that circumstance it would require investigation and resolution. When we test with a limit on the composite services that are brought up, then this is used to only bring up a subset of the Docker Compose services that are configured in the test environment in order to speed everything up. Consequently this situation becomes inevitable and expected.

Secondly, if your testing scope includes the backup composite service then the `Install Dropbox python helper script` task in the `backup_dropbox` role may fail with the response *HTTP Error 404: Not Found* and immediately halt the Ansible playbook. This task uses the `ansible.builtin.get_url` module to get a helper script that Dropbox provide for managing Dropbox in a headless environment. For some reason that I don't understand, this intermittently gives a `404: Not Found` response.

If this occurs the simply rerun the `docker-compose run --rm playbook` command above and keep doing so until it completes, which has never taken more than one or two reruns in my experience.

### Activate Backup Synchronisation with Dropbox

This is an optional step that is only required if the *backup* composite service is in your current scope and then only if you have enabled the backup integration with Dropbox - see above under [Enabling Integration with Third-Party Cloud Services](#enabling-integration-with-third-party-cloud-services). If both of those things are true, then when you run the `playbook services` command you will see something like the following reported in the containers sysout at the appropriate point in the playbook execution:

```
hub_1           | dropboxd   : Starting
hub_1           | dropboxd   : Started
hub_1           | dropboxd   : This computer isn't linked to any Dropbox account...
hub_1           | dropboxd   : Please visit https://www.dropbox.com/cli_link_nonce?nonce=99ba504e9c5a41ae7de014ca86280d3f to link this device.
```

The value of the nonce in the URL to link the device will be different every time and the hostname can differ depending on what environment you're using. In this example the hostname is `hub`. The last two lines above will periodically repeat in the sysout until you take action to link the device.

At the same time, the playbook will pause at the prompt "Link host to [hostname] to your Dropbox account before acknowledging this prompt:". Of course [hostname] in the example above will again be `hub`.

So, now you must:

1. Click on the link appearing in the container sysout to link the container to your Dropbox account.

>>You should then see something like this reported in the container sysout:

```
This computer is now linked to Dropbox. Welcome Dave
```

>>Of course, you might not be called Dave! If you examine the linked devices for your Dropbox account you will see that an entry has appeared that looks something like this:

![Dropbox linked device](./readme-images/dropbox-linked-device.png)

>>Of course you might not live in Long Eaton, United Kingdom!

2. Once you have completed step 1, hit enter back at the playbook prompt to confirm it and continue the playbook's execution.

>>It's important that you don't hang about too long before doing this. Once you've linked the container to your Dropbox account, content will start synchronising into the container. If you use your Dropbox account extensivey, this could be a lot of content. Shortly after you've confirmed the prompt, playbook tasks will run that limit this synchronisation to the `backukp_copy_folder`.

### Deploying the Projects

Once the `playbook services` command has completed you can continue to run the project playbooks. There are playbooks provided in this repository for two projects, one for a simulation of a *customer* domain and one for a simulation of our *home* domain. You run these playbooks using the following commands:

*customer*<br>
```bash
docker-compose run --rm playbook customer [SERVICES...]
```

*home*<br>
```bash
docker-compose run --rm playbook customer [SERVICES...]
```

Note that these playbooks are only applicable if your current scope includes the *mail* or *web* composite services or, for the *home* domain only, the *calendar* compose service. If you don't have these composite services in your scope, then these playbooks will do nothing. If you include other composite services that are in your current scope when running these playbooks then nothing will happen in respect of those composite services.
