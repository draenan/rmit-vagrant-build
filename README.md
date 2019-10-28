# Building Vagrant boxes with Packer

This repo provides the necessary framework to build VirtualBox-based VMs for
use with Vagrant. The built boxes will be placed in the `boxes` subdirectory
and can then be uploaded to the
[Satellite](http://satellite.its.rmit.edu.au/boxes/) server.

Vagrant and Packer are both available to be installed via
[Homebrew](http://brew.sh):

```
brew cask install vagrant
brew install packer
```

VirtualBox is also available from Homebrew:

```
brew cask install virtualbox
```

Alternatively it can be downloaded from the VirtualBox
[website](http://www.virtualbox.org/wiki/Download_Old_Builds) if you prefer
a version with less bugs.

Run `make` from the parent directory to get a list of targets which by default
include:

* `list` - List all available targets (Default)
* `clean` - Alias for `clean-boxes`
* `clean-boxes` - Removes boxes from the `boxes` directory
* `clean-cache` - Removes `packer_cache` directories
* `clean-all` - Executes `clean-boxes` and `clean-cache`
* `upload` - Uses `scp` to upload boxes in the `boxes` subdirectory to
  [Satellite](http://satellite.its.rmit.edu.au/boxes/)

Build targets should be fairly obvious in that they `cd` to the relevant
subdirectory and execute a `packer build` command, moving the completed box to
the `boxes` subdirectory on completion.

The original build targets (`build-rhel6` and `build-rhel7`) will build RHEL
6 and RHEL 7 boxes respectively that are almost exactly the same as those built
by our standard Kickstart.  These boxes will register with Satellite for
updates, and deregister prior to packaging.  They include a default
`Vagrantfile` that will assign a random hostname of the form
`vagrant-XXXX.its.rmit.edu.au` to the box (where `XXXX` is a 4-digit
Hexadecimal number) when started for the first time via `vagrant up`. As the
box will reregister with Satellite the first time it is brought up it is
recommended that the hostname be configured in the local `Vagrantfile` if the
default format is not suitable.

Currently if a box is destroyed via `vagrant destroy` without first running
`vagrant ssh -- sudo ./satellite-deregister` you will need to manually
unsubscribe the box from Satellite. Deleting the system from Satellite is also
a manual process; see below.

### Note for users of the vagrant-vbguest plugin

The `vagrant-vbguest` plugin fires early in the process of bringing a box up;
after the machine comes up, but before hostname/networking is configured and
provisioning is done.  As a result, if the Virtual Box Guest Additions are out
of date the plugin will attempt to rebuild them, which will potentially cause
issues if packages need to be installed or updated as the box is yet to be
registered with Satellite.  As a result the `auto-update` functionality of
`vbguest` is disabled if the plugin is detected.

If you want to re-enable it, add `config.vbguest.auto_update = true` to your
`Vagrantfile`.

## Now building on Satellite 6

All hosts, including the RHEL 8 host, are now subscribing to and building off
the [Satellite 6](https://satellite6.its.rmit.edu.au/) server.  The build
targets now require environment variables to be set in order to provide the
Organisation and Activation Key when registering the host with Satellite.  For
example, if building a RHEL 7 host:

```
$ export VAGRANT_RHEL7_ORG="<orgid>"
$ export VAGRANT_RHEL7_KEY="<activationkey>"
$ make build-rhel7
```

The best way to deal with this is probably to put those environment variables
into a file and then `source` it.

Please note that using `subscription-manager unregister` to unsubscribe the
host from Satellite doesn't currently delete it, so the `satellite-deregister`
script doesn't work the same as it did for Satellite 5 builds.  Until I can
figure out the API for host deletions, a host can be deleted either from the
web interface or via logging in and executing the command:

```
# hammer host delete name=<hostname>
```

To get a list of all hosts built by the configuration in this repo, run the
command:

```
# hammer host list --thin=true --search=vagrantbuild
```

