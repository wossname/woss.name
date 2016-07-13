---
published_on: 2006-11-13
title: Setting up a local name server on Mac OS X
redirect_from: "/2006/11/13/setting-up-local-name-server-on-mac-os-x/"
category: Ops
tags:
  - dns
  - subdomains
  - ruby
  - rails
  - bind
  - bonjour
  - mac os x
---
I've been using
[`account_location`](http://dev.rubyonrails.org/svn/rails/plugins/account_location/)
for a couple of applications recently. It's a really nice way to give
individual 'clients' of an application their own domain and when we come to
scaling up, it's a really easy way of splitting customers across several
hosts. So, yeah, very nice. And it's dead easy to deploy in the first instance
-- a couple of DNS records along the lines of:

    @ IN A 1.2.3.4
    * IN A 1.2.3.4

There you go, every host in that domain points to 1.2.3.4.

However, it's a pest for setting up in your development environment. OK, so
you can edit `/etc/hosts` and add an entry for every single account you happen
to create. This hinders development for me -- each domain *has* to be unique,
so whenever I want to create a new account, I have to do so in Rails, *and* in
`/etc/hosts`. It's also irritating when I'm having to maintain an `/etc/hosts`
file on multiple machines. Unfortunately, the hosts file doesn't support
wildcard records, so we *have* to put every single entry in.

I'm sure there's a better solution on Mac OS X -- maybe there's something smart I could do with the NetInfo database, or maybe I could play with [Bonjour](http://www.apple.com/macosx/features/bonjour/) in some way -- but the easiest thing for me was to set up a name server on my local machine.  It's really dead simple.  Handily enough, [BIND](http://www.isc.org/index.pl?/sw/bind/) is already installed in the base system, just not configured and switched on.  So we just have to do a little configuration.  First of all, create the `rndc` configuration to control the name server:

    mathie@bowmore:mathie$ sudo -s
    bowmore:/Users/mathie root# rndc-confgen > /etc/rndc.conf
    bowmore:/Users/mathie root# head -n5 /etc/rndc.conf |tail -n4 > /etc/rndc.key

This creates a key in `/etc/rndc.conf` which allows the `rndc` client to talk to the name server and control it.  We then need to tweak the server configuration a little.  In the controls section, change the port from `54` to `953` (I don't know why it's different by default, since it doesn't seem to work!).  Next up we need to create a stanza in `/etc/named.conf` for the Rails application zone.  Add something along the lines of:

    zone "rails" IN {
            type master;
            file "rails.zone";
            allow-update { none; };
    };

around the other zone stanzas.  Save that and move on.  Next thing is to create `/var/named/rails.zone`.  I started by copying the default `localhost.zone`, winding up with something along the lines of:

    $TTL    86400
    $ORIGIN rails.
    @                       1D IN SOA       @ root (
                                            42              ; serial (d. adams)
                                            3H              ; refresh
                                            15M             ; retry
                                            1W              ; expiry
                                            1D )            ; minimum

                            1D IN NS        @
                            1D IN A         127.0.0.1

    *.app1 IN A 127.0.0.1
    *.app2 IN A 127.0.0.1

Save that and quit.  Finally, we need to convince BIND to start up at boot.  Since I'm on Tiger, we have the benefit of `launchd` to handle such mundane tasks.  Simply run:

    mathie@bowmore:mathie$ sudo launchctl load -w /System/Library/LaunchDaemons/org.isc.named.plist

BIND will start now, and will automatically start from now on at launch.  if you're on anything older, I gather it's a case of adding:

    DNSSERVER=-YES-

to `/etc/hostconfig`.  You can then restart your computer for it to take effect (it would be a good idea to verify it works) or cheat and run:

    sudo /usr/sbin/named

to start it for now.

Finally, you need to tell your computer to *use* the newly setup name server.  In System Preferences, go to the Network pane.  For every one of the connections you use, in every one of the locations you have set up, go to the TCP/IP settings and add `127.0.0.1` as the first DNS server.

Now every time you do a lookup for `foo.app1.rails`, `bar.app2.rails` or, well, anything at either domain, it will resolve to 127.0.0.1.  So you can happily browse to <http://rubaidh.app1.rails:3000/> and `account_subdomain` will be set to 'rubaidh'.  Neat, huh?
