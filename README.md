# Building Vagrant boxes with Packer

This repo provides the necessary framework to build VirtualBox-based VMs for
use with Vagrant. The built boxes will be placed in the `boxes` subdirectory
and can then be uploaded to the old
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
* `build-all` - Build all boxes (see output of `make list` for the `build`
  targets)
* `clean` - Alias for `clean-boxes`
* `clean-boxes` - Removes boxes from the `boxes` directory
* `clean-cache` - Removes `packer_cache` directories
* `clean-tempfiles` - Removes temporary files and directories
* `clean-all` - Executes all `clean-*` targets
* `upload` - Uses `scp` to upload boxes in the `boxes` subdirectory to the old
  [Satellite](http://satellite.its.rmit.edu.au/boxes/) server

Build targets should be fairly obvious in that they `cd` to the relevant
subdirectory and execute a `packer build` command, moving the completed box to
the `boxes` subdirectory on completion.  The boxes are registered with
[Satellite 6](https://satellite6.its.rmit.edu.au/) during the build, and
deregistered after; in order for this to work correctly some environment
variables need to be set prior to starting the build.  For example, if building
a RHEL 7 host:

```
$ export VAGRANT_RHEL7_ORG="<orgid>"
$ export VAGRANT_RHEL7_KEY="<activationkey>"
$ make build-rhel7
```

The best way to deal with this is probably to put those environment variables
into a file and then `source` it.

The build targets will build RHEL boxes that are almost exactly the same as
those built by our standard build process. They include a default `Vagrantfile`
that will assign a random hostname of the form `vagrant-XXXX.its.rmit.edu.au`
to the box (where `XXXX` is a 4-digit Hexadecimal number) when started for the
first time via `vagrant up`. As the box will reregister with Satellite the
first time it is brought up it is recommended that the hostname be configured
in the local `Vagrantfile` if the default format is not suitable.

Currently if a box is destroyed via `vagrant destroy` without first running
`vagrant ssh -- sudo ./satellite-deregister` you will need to manually
unregister the box from Satellite. Also, while `subscription-manager
unregister` will unregister a host it will not delete it from Satellite fully.
To do this either delete the host from the Console or run the following CLI
command on the Satellite server:

```
# hammer host delete name=<hostname>
```

This is required prior to resubscribing.  Failure to do so will result in an
error message saying you should unregister or remove the host before
registering.

To get a list of all hosts built by the configuration in this repo, run the
command:

```
# hammer host list --thin=true --search=vagrantbuild
```

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

