# Services - Docker

David Williamson @ Varilink Computing Ltd

------

See my blog article [Testing Ansible Roles Using Containers](https://www.varilink.co.uk/testing-ansible-roles-using-containers) to read about the purpose of this repository and how what it does was achieved. This README contains three section:
- [Contents of this Repository](#contents-of-this-repository)
- [Using this Repository](#using-this-repository)
- [Testing the Services](#testing-the-services)

## Contents of this Repository

| Item                             | Contents                                                                                                                                  |
| -------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| build/                           | Build contexts for the Docker Compose services defined by this repository.                                                                |
| envs/                            | Configuration of the [Test Environments](#test-environments).                                                                             |
| libraries-ansible/               | The [Libraries - Ansible](https://github.com/varilink/libraries-ansible) repository, included here as a submodule.                        |
| my&#8209;roles/                  | Ansible roles that provide a wrapper to the those in the [Libraries - Ansible](https://github.com/varilink/libraries-ansible) repository. |
| readme&#8209;images/             | Images that are used in this README.                                                                                                      |
| .env<br>docker&#8209;compose.yml | The master Docker Compose configuration for this repository.                                                                              |

### Test Environments

The `envs/` directory contains the Ansible inventories and playbooks and Docker Compose configuration for different test environments. Three such test environments are defined:

*now*<br>
Simulation of the hosts that the Varilink Computing Ltd services are deployed on in the current live environment. This reflects both the mapping of service roles to hosts and the Debian release on each host.

*to-be*<br>
Simulation of the hosts that the Varilink Computing Ltd services will be deployed on in a future live environment. Relative to *now* this typically reflects planned upgrades to Debian releases on one or more hosts. It may also reflect changes to the list of hosts and the mapping of services to hosts.

*distributed*<br>
In live multiple services are deployed to a single host; for example, a WordPress host typically has the full stack of [reverse_proxy](https://github.com/varilink/libraries-ansible#reverse_proxy), [wordpress_apache](https://github.com/varilink/libraries-ansible#wordpress_apache) and [database](https://github.com/varilink/libraries-ansible#database) roles on it. However, the roles are defined such that they could be distributed across hosts on a one-host-to-one-service basis. This environment is configured to test that distributed deployment model works.

Each test environment defines Ansible variables in `group_vars/` and `host_vars/` directories associated with both their inventory and playbooks. Since those environments are **not** the Varilink Computing Ltd live environment, I share their Ansible inventories, playbooks and (most importantly) variables very openly in this repository. They serve as a useful example of how to use the [Libraries - Ansible](https://github.com/varilink/libraries-ansible) repository - see also under [List of Variables](https://github.com/varilink/libraries-ansible#list-of-variables) in the README of that repository. The equivalent Ansible artefacts that I use to automate the management of the Varilink Computing Ltd live environment can not be shared as openly since they contain sensitive data.

For more information about the variables used by the [Libraries - Ansible](https://github.com/varilink/libraries-ansible) repository, see [Variables](https://github.com/varilink/libraries-ansible#variables) in its README.

## Using this Repository

To use this repository to test the roles in my [Libraries - Ansible](https://github.com/varilink/libraries-ansible) repository, you must step through the following tasks:

1. [Clone or Download this Repository](#clone-or-download-this-repository)
2. [Raise Hosts](#raise-hosts)
3. [Run Services Playbook](#run-services-playbook)
4. [Run Project Playbooks](#run-project-playbooks)

### Clone or Download this Repository

The first thing that you must do is get this repository on to the host that you plan to use it on. If you have Git on that host then you could, for example, clone this repository using HTTPS as follows:

```bash
git clone --recurse-submodules https://github.com/varilink/services-docker.git
```

Note the use of the `--recurse-submodules` option. This repository uses [Libraries - Ansible](https://github.com/varilink/libraries-ansible) as a submodule and the contents of that submodule must be cloned too for this repository to work.

If you don't have Git on the host, then your other option is to use the [Download ZIP](https://github.com/varilink/services-docker/archive/refs/heads/main.zip) link for this repository. That will **not** bring with it the contents of submodules. So you must download [Libraries - Ansible](https://github.com/varilink/libraries-ansible) separately.

You **must** maintain the association between a commit of [Services - Docker](https://github.com/varilink/services-docker) and the commit of [Libraries - Ansible](https://github.com/varilink/libraries-ansible) that it uses. In order to do that, follow the *libraries-ansible @ &hellip;* link on the GitHub page of [Services - Docker](https://github.com/varilink/services-docker). The ellipsis there will refer to the specific commit of [Libraries - Ansible](https://github.com/varilink/libraries-ansible) that the commit of [Services - Docker](https://github.com/varilink/services-docker) uses.

Once you have downloaded both zip files, you must unzip them both and ensure that the contents of [Libraries - Ansible](https://github.com/varilink/libraries-ansible) are in the `libraries-ansible` folder of the contents of [Services - Docker](https://github.com/varilink/services-docker).

I will publish releases of [Services - Docker](https://github.com/varilink/services-docker) corresponding to the points at which I have tested everything published in posts on [my blog site](https://www.varilink.co.uk) to date. So you can isolate yourself from any instability in this repository by using the latest release of [Services - Docker](https://github.com/varilink/services-docker) rather than the latest commit on the main branch.

Using this repository then entails running `docker-compose` commands, referring to the instructions that follow. All commands shown in this README should be invoked in this repository's root folder on your host machine.

### Raise Hosts

To raise the hosts in a test environment, you must run the following command if using Bash or PowerShell respectively.

*Bash*
```bash
docker-compose run --rm -T raise-hosts [SERVICES...] [OPTIONS...] | bash
```

*PowerShell*
```powershell
docker-compose run --rm -T raise-hosts [SERVICES...] [OPTIONS...] | PowerShell.exe
```

Here the `docker-compose run --rm -T raise-hosts [SERVICES...]` command generates a list of other `docker-compose` and `docker` commands that are in turn executed by piping them into another shell. You could if you wished exclude the pipe if you want to see what those commands are rather than execute them, though this would do nothing of course.

Note that the `docker-compose` and `docker` command syntaxes are shell neutral and it is the other aspects that wrap around these commands that vary across shell environment; in this case the pipe action, `| bash` for Bash and `| PowerShell.exe` for PowerShell environments, which are the two that I have tested this repository in.

As my blog article [Testing Ansible Roles Using Containers](https://www.varilink.co.uk/testing-ansible-roles-using-containers/) describes, I have constructed this repository so that the dependencies on the desktop to use it successfully should be limited to:
- Docker, including Docker Compose.
- The ability to run Linux containers, so the Windows Subsystem for Linux (WSL) is needed on a Window desktop.
- A shell to use, which should come with your operating system of course.

I believe that this effectively means that this repository can be used on just about any desktop.

#### Selecting the Test Environment

By default, the commands above will raise the hosts in the *now* environment, because this is set as the value of the `MYENV` environment variable in the `.env` file. If you wish to work with one of the other [Test Environments](#test-environments) then you're likely to want to do so for an extended period that includes running the services and project playbooks and testing the services. For that reason, I recommend that you change the default value of `MYENV` to do this, either by editing the `.env` file or by setting the value in your desktop shell session; for example, if you wanted to work in the *to-be* environment for a while:

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

We have now covered both of the only differences that I have encountered when using this repository with *Bash* and *Powershell*; using a pipe and the setting and un-setting of environment variables. Consequently, in this README I limit examples to the *Bash* shell from now on for brevity.

#### Limiting the Services

The `[SERVICES...]` argument(s) in the command to raise an environment's hosts is an optional (can be omitted) list of one or more services that can be used to limit the hosts that are raised. Those services group one or more hosts that coordinate to deliver the service. If this argument is omitted then **all** the hosts are raised.

The services are:
- backup
- calendar
- dns
- dynamic_dns
- mail
- web

Each of these services can be stood up and tested independently of the others, though note that the *dns* service is a dependency for all of the other services and so is always in scope.

To raise the hosts for **all** of the services and deploy **all** Ansible roles to them is time consuming. Therefore you might want to limit the services that you're working with, because to do so speeds everything up. Here are some examples of raising the hosts for a subset of services.

- Raise the hosts for only the *backup* service:

```bash
docker-compose run --rm -T raise-hosts backup | bash
```

- Raise the hosts for the *backup* and *calendar* services:

```bash
docker-compose run --rm -T raise-hosts backup calendar | bash
```

As explained above, the hosts for the *dns* service will always be raised, even if the *dns* service is not explicitly requested.

#### Passing Options to `docker-compose up`

When we run `raise-hosts` above, we pipe its output into a shell. If you run it without piping it output into a shell, you will of course see the commands that it generates instead.

For example, running this command in the default, *now* environment:
```bash
docker-compose run --rm raise-hosts backup calendar
```

Generates these `docker` and `docker-compose` commands:

```bash
docker-compose --env-file envs/now/.env stop dns-external hub mail-external proxy-external proxy-internal router
docker-compose --env-file envs/now/.env rm --force dns-external hub mail-external proxy-external proxy-internal router
docker volume rm services_bacula-home
docker-compose --env-file envs/now/.env up proxy-external proxy-internal router dns-external hub mail-external
```

The `proxy-external`, `proxy-internal` and `router` Docker Compose services are not directly related to any of the services that are specified via the `[SERVICES...]` argument(s) nor are they the target of Ansible playbooks. They are ancillary Docker Compose services that support the function of the test environments.

Note above that we've dropped the `-T` option, which disables pseudo-tty allocation by `docker-compose run`. We only need to do this when we pipe the output, which we're not doing here. Of course, not piping the output displays the commands but doesn't run any of them, so it's pointless other than that it let's us see them.

`[OPTIONS...]` above is an optional (again, can be omitted) list of options to be provided to the `docker-compose up` command at the end of the list of commands above. Any argument provided that starts with `-` is passed directly through to this `docker-compose up` command.

For example, running this command in the default, *now* environment:

```bash
docker-compose run --rm raise-hosts backup calendar --build --remove-orphans
```

Generates these `docker` and `docker-compose` commands:

```bash
docker-compose --env-file envs/now/.env stop dns-external hub mail-external proxy-external proxy-internal router
docker-compose --env-file envs/now/.env rm --force dns-external hub mail-external proxy-external proxy-internal router
docker volume rm services_bacula-home
docker-compose --env-file envs/now/.env up --build --remove-orphans proxy-external proxy-internal router dns-external hub mail-external
```

Observe that the `--build` and `--remove-orphans` options have been passed through to the `docker-compose up` command. Normally, you don't have to think about this but if say you had edited the build instructions for the `varilink/services/sshd` image, requiring a rebuild, or altered any Docker Compose services that use it, creating orphans, then you can see that this feature would come in useful.

You could of course use the `--detach` option here to run all the containers in the background, however I do **not** recommend this. To be able to observe the effect of the `ansible-playbook` commands within the running containers is key to the purpose of this repository.

### Run Services Playbook

Now that we have raised the required (as defined by the scope of services) hosts as containers, we can proceed to deploy the services to them by running the following command:

```bash
docker-compose run --rm playbook services [SERVICES...] [OPTIONS...]
```

Since we must run the above command in a different shell to the one that we used to raise the hosts in (unless you raised the hosts with the `--detach` option, contrary to my recommendation above), we must again take heed of the instructions under [Selecting the Test Environment](#selecting-the-test-environment) above. If we had set `MYENV` within the shell in which we brought the services up, then we must do so again to use the same environment in the shell that run the playbook command in, otherwise it will run using the wrong environment specification.

By contrast, if you edited the value of the `MYENV` variable in the `.env` file instead, then this will take effect in any and all shells that you open.

The `[SERVICES...]` argument(s) work exactly as they did in the previous step. Here you **must** use the `[SERVICES...]` argument to either limit the `playbook` command to the same list of services you used in the `raise-hosts` command or a subset thereof. You can't run the `playbook` command for services that you didn't include when you ran the `raise-hosts` command because not all the containers that are targets of the `playbook` command will be running.

In this way it's possible to run `raise-hosts` for several services and then run `playbook` multiple times to deploy those services one-by-one or in other subsets to the running containers. Of course, you could omit a list of services for both the `raise-hosts` and `playbook` commands in which case you're running all the containers and deploying all the services at once.

`[OPTIONS...]` is an optional (again, can be omitted) list of any of the options that the `ansible-playbook` command accepts, with the exception of the `--inventory`, `--limit` or `--tags` options as these are set by the wrapper provided by our `playbook` command. For example, you could enter the following to include the `--step` option of the `ansible-playbook` command, while also limiting its action to the roles and hosts required by the *backup* and *calendar* services:

```bash
docker-compose run --rm playbook services backup calendar --step
```

### Run Project Playbooks

Once the `playbook services` command has completed you can move on to run the project playbooks. There are playbooks provided in this repository for two projects, one for a simulation of a *customer* domain and one for a simulation of our *home* domain. You run these playbooks using the following commands:

*customer*<br>
```bash
docker-compose run --rm playbook customer [SERVICES...] [OPTIONS...]
```

*home*<br>
```bash
docker-compose run --rm playbook customer [SERVICES...] [OPTIONS...]
```

Note that these playbooks are only applicable if your current scope includes the *mail* or *web* services or, for the *home* domain only, the *calendar* service. If you don't have these services in your scope, then these playbooks will do nothing. If you include other services that are in your current scope when running these playbooks then nothing will happen in respect of those services.

The [SERVICES...] and [OPTIONS...] arguments above work in exactly the same way as they do for the [Run Services Playbook](#run-services-playbook) step.

## Testing the Services

