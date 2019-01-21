# Building Vagrant boxes with Packer

This repo provides the necessary framework to build VirtualBox-based VMs for use with Vagrant. The built boxes will be placed in the `boxes` subdirectory and can then be uploaded to the [Satellite](http://satellite.its.rmit.edu.au/boxes/) server.

Vagrant and Packer are both available to be installed via [Homebrew](http://brew.sh):

```
brew cask install vagrant
brew install packer
```

VirtualBox is also available from Homebrew:

```
brew cask install virtualbox
```

Alternatively it can be downloaded from the VirtualBox [website](http://www.virtualbox.org/wiki/Download_Old_Builds) if you prefer a version with less bugs.

Run `make` from the parent directory to get a list of targets which by default include:

* `list` - List all available targets (Default)
* `clean` - Alias for `clean-boxes`
* `clean-boxes` - Removes boxes from the `boxes` directory
* `clean-cache` - Removes `packer_cache` directories
* `clean-all` - Executes `clean-boxes` and `clean-cache`
* `upload` - Uses `scp` to upload boxes in the `boxes` subdirectory to [Satellite](http://satellite.its.rmit.edu.au/boxes/)

Build targets should be fairly obvious in that they `cd` to the relevant subdirectory and execute a `packer build` command, moving the completed box to the `boxes` subdirectory on completion.

The original build targets (`build-rhel6` and `build-rhel7`) will build RHEL 6 and RHEL 7 boxes respectively that are almost exactly the same as those built by our standard Kickstart.  These boxes will register with Satellite for updates, and deregister prior to packaging.  They include a default `Vagrantfile` that will assign a random hostname of the form `vagrant-XXXX.its.rmit.edu.au` to the box (where `XXXX` is a 4-digit Hexadecimal number) when started for the first time via `vagrant up`. As the box will reregister with Satellite the first time it is brought up it is recommended that the hostname be configured in the local `Vagrantfile` if the default format is not suitable.

Currently if a box is destroyed via `vagrant destroy` without first running `vagrant ssh -- sudo ./satellite-deregister` you will need to manually remove the box from Satellite.
