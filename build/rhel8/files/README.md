# Subscribing to Red Hat Customer Portal

This Vagrant box is a interim RHEL 8 build pending build of our new Satellite
6 server.  As a result this host needs to be manually registered and subscribed
to the "Red Hat Managed Infrastructure for CAUDIT" channel subscription in the
Red Hat Customer Portal.

To allow for auto-attach, the System Purpose SLA needs to be set.  To do so,
run the command `syspurpose set-sla Premium`.  This can be verified with
`syspurpose show`.  No other values should be set.  Once this is done register
and subscribe the system with the command `subscription-manager register
--auto-attach`.  Use the RMIT username and password that you use to log in to
the Red Hat Customer Portal.

If for some reason you don't want to set the SLA (or you want to set other
items like "role" or "purpose") you will need to manually subscribe to the
relevant subscription.  Register the system with `subscription-manager
register` as above (don't use `--auto-attach`) and then subscribe to the CAUDIT
subscription with `subscription-manager subscribe
--pool=8a85f99c671cb39701674dedc9bd6747`.

There are two primary Pool IDs associated with the "Red Hat Managed
Infrastructure for CAUDIT" subscription (Master and Derived):

* `8a85f99c671cb39701674dedc9586741`: Master, Physical System Type
* `8a85f99c671cb39701674dedc9bd6747`: Derived, Virtual System Type

As far as I can tell, all hosts are considered Physical, unless they are VMs
running under a host (using KVM, for example), in which case they are Virtual.

The current subscription can be verified via `subscription-manager list
--consumed`.

You should release any consumed entitlements when you are done with this host.
`subscription-mananger unregister` will fully remove the system from the Red
Hat Customer Portal. `susbcription-manager unsubscribe --all` will unsubscribe,
but keep the system registered. `unregister` is probably what you want.

To summarise:

Registering with the Customer Portal and automatically attaching to
a subscription:

```
# syspurpse set-sla Premium
# subscription-manager register --auto-attach
```

Registering with the Customer Portal without automatically attaching to
a Subscription:

```
# subscription-manager register
# subscription-manager subscribe --pool=8a85f99c671cb39701674dedc9bd6747
```

Registering with the Customer Portal without automatically attaching to
a Subscription:

```
# subscription-manager register
# subscription-manager subscribe --pool=8a85f99c671cb39701674dedc9bd6747
```

You should probably consider running `syspurpose set-sla Premium` regardless of
which method you use, to prevent a "System Purpose Status Mismatch" indication
in the system's profile page at the Customer Portal.

To unregister a system:

```
# subscription-manager unregister
```

