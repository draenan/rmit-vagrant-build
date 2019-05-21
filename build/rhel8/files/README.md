# Subscribing to Red Hat Customer Portal

This Vagrant box is an interim RHEL 8 build pending build of our new Satellite
6 server.  As a result this host is registered with the Red Hat Customer Portal
and subscribed to the "Red Hat Managed Infrastructure for CAUDIT" subscription
during the initial provisioning stage.

You should release any consumed entitlements when you are done with this host
prior to destroying it, otherwise you will need to log in to the Customer
Portal in order to manually remove it.  This can be done via the
`satellite-deregister` script in `/home/vagrant`.  The name of the script is
for consistency with the RHEL 6/7 builds, and for future use with our upcoming
Satellite 6 server.

