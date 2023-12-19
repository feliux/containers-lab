# FreeIPA server & Keycloak

Launch a FreeIPA server integrated with Keycloak.

## Usage

> First you should read the entire documentation provided on reference section, specially the freeipa-container repository from Github. Then you have to set the properly `IPA_SERVER_INSTALL_OPT` for your custom installation.

Deploy services with `$ docker-compose up -d`. Here are the logs from freeipa-server container after the installation

~~~
Next steps:
        1. You must make sure these network ports are open:
                TCP Ports:
                  * 80, 443: HTTP/HTTPS
                  * 389, 636: LDAP/LDAPS
                  * 88, 464: kerberos
                UDP Ports:
                  * 88, 464: kerberos
                  * 123: ntp

        2. You can now obtain a kerberos ticket using the command: 'kinit admin'
           This ticket will allow you to use the IPA tools (e.g., ipa user-add)
           and the web user interface.
        3. Kerberos requires time synchronization between clients
           and servers for correct operation. You should consider enabling chronyd.
~~~

Next go into the freeipa-server container and run

```sh
$ docker exec -it freeipa-server bash
$ echo $PASSWORD | kinit admin
$ klist
```

We published port 443 from the server to 127.0.0.1:443. To enable this functionality just add in a new terminal window the following line to the `/etc/hosts` file (change `ipa.example.test` by your correct domain)

~~~
127.0.0.1  localhost ipa.example.test
~~~

At this moment FreeIPA is available on `localhost:80`

**Useful commands**

Generate keytab

```sh
$ ipa-getkeytab -r -s ipa.example.test -p admin@EXAMPLE.TEST -k test.keytab
```

Kerberos commands

```sh
$ klist -k /tmp/test.keytab
$ kinit -k -t /tmp/test.keytab admin@EXAMPLE.TEST
```

## References

> FreeIPA

[FreeIPA documentation](https://www.freeipa.org/page/Documentation)

[FreeIPA Docker documentation](https://www.freeipa.org/page/Docker)

[FreeIPA container Github](https://github.com/freeipa/freeipa-container)

[FreeIPA container DockerHub](https://hub.docker.com/r/freeipa/freeipa-server)

[FreeIPA deployment recommendations](https://www.freeipa.org/page/Deployment_Recommendations)

[ipa-getkeytab man page](https://linux.die.net/man/1/ipa-getkeytab)

> Keycloak

[Keycloak documentation](https://www.keycloak.org/docs/latest/server_admin/index.html)

[Keycloak Kerberos documentation](https://www.keycloak.org/docs/latest/server_admin/index.html#_kerberos)

[Keycloak containers Github](https://github.com/keycloak/keycloak-containers)

> ipa-server-install commands

```sh
$ ipa-server-install --help
Usage: ipa-server-install [options]

Options:
  --version             show program's version number and exit
  -h, --help            show this help message and exit
  -U, --unattended      unattended (un)installation never prompts the user
  --uninstall           uninstall an existing installation. The uninstall can
                        be run with --unattended option

  Basic options:
    -p DM_PASSWORD, --ds-password=DM_PASSWORD
                        Directory Manager password
    -a ADMIN_PASSWORD, --admin-password=ADMIN_PASSWORD
                        admin user kerberos password
    --ip-address=IP_ADDRESS
                        Master Server IP Address. This option can be used
                        multiple times
    -n DOMAIN_NAME, --domain=DOMAIN_NAME
                        primary DNS domain of the IPA deployment (not
                        necessarily related to the current hostname)
    -r REALM_NAME, --realm=REALM_NAME
                        Kerberos realm name of the IPA deployment (typically
                        an upper-cased name of the primary DNS domain)
    --hostname=HOST_NAME
                        fully qualified name of this host
    --ca-cert-file=FILE
                        File containing CA certificates for the service
                        certificate files
    --pki-config-override=PKI_CONFIG_OVERRIDE
                        Path to ini file with config overrides.
    --no-host-dns       Do not use DNS for hostname lookup during installation

  Server options:
    --setup-adtrust     configure AD trust capability
    --setup-kra         configure a dogtag KRA
    --setup-dns         configure bind with our zone
    --idstart=IDSTART   The starting value for the IDs range (default random)
    --idmax=IDMAX       The max value for the IDs range (default:
                        idstart+199999)
    --no-hbac-allow     Don't install allow_all HBAC rule
    --no-pkinit         disables pkinit setup steps
    --no-ui-redirect    Do not automatically redirect to the Web UI
    --dirsrv-config-file=FILE
                        The path to LDIF file that will be used to modify
                        configuration of dse.ldif during installation of the
                        directory server instance

  SSL certificate options:
    --dirsrv-cert-file=FILE
                        File containing the Directory Server SSL certificate
                        and private key
    --http-cert-file=FILE
                        File containing the Apache Server SSL certificate and
                        private key
    --pkinit-cert-file=FILE
                        File containing the Kerberos KDC SSL certificate and
                        private key
    --dirsrv-pin=PIN    The password to unlock the Directory Server private
                        key
    --http-pin=PIN      The password to unlock the Apache Server private key
    --pkinit-pin=PIN    The password to unlock the Kerberos KDC private key
    --dirsrv-cert-name=NAME
                        Name of the Directory Server SSL certificate to
                        install
    --http-cert-name=NAME
                        Name of the Apache Server SSL certificate to install
    --pkinit-cert-name=NAME
                        Name of the Kerberos KDC SSL certificate to install

  Client options:
    --mkhomedir         create home directories for users on their first login
    --ntp-server=NTP_SERVER
                        ntp server to use. This option can be used multiple
                        times
    --ntp-pool=NTP_POOL
                        ntp server pool to use
    -N, --no-ntp        do not configure ntp
    --ssh-trust-dns     configure OpenSSH client to trust DNS SSHFP records
    --no-ssh            do not configure OpenSSH client
    --no-sshd           do not configure OpenSSH server
    --no-dns-sshfp      do not automatically create DNS SSHFP records

  Certificate system options:
    --external-ca       Generate a CSR for the IPA CA certificate to be signed
                        by an external CA
    --external-ca-type={generic,ms-cs}
                        Type of the external CA
    --external-ca-profile=EXTERNAL_CA_PROFILE
                        Specify the certificate profile/template to use at the
                        external CA
    --external-cert-file=FILE
                        File containing the IPA CA certificate and the
                        external CA certificate chain
    --subject-base=SUBJECT_BASE
                        The certificate subject base (default O=<realm-name>).
                        RDNs are in LDAP order (most specific RDN first).
    --ca-subject=CA_SUBJECT
                        The CA certificate subject DN (default CN=Certificate
                        Authority,O=<realm-name>). RDNs are in LDAP order
                        (most specific RDN first).
    --ca-signing-algorithm={SHA1withRSA,SHA256withRSA,SHA512withRSA}
                        Signing algorithm of the IPA CA certificate

  DNS options:
    --allow-zone-overlap
                        Create DNS zone even if it already exists
    --reverse-zone=REVERSE_ZONE
                        The reverse DNS zone to use. This option can be used
                        multiple times
    --no-reverse        Do not create new reverse DNS zone
    --auto-reverse      Create necessary reverse zones
    --zonemgr=ZONEMGR   DNS zone manager e-mail address. Defaults to
                        hostmaster@DOMAIN
    --forwarder=FORWARDERS
                        Add a DNS forwarder. This option can be used multiple
                        times
    --no-forwarders     Do not add any DNS forwarders, use root servers
                        instead
    --auto-forwarders   Use DNS forwarders configured in /etc/resolv.conf
    --forward-policy={only,first}
                        DNS forwarding policy for global forwarders
    --no-dnssec-validation
                        Disable DNSSEC validation

  AD trust options:
    --enable-compat     Enable support for trusted domains for old clients
    --netbios-name=NETBIOS_NAME
                        NetBIOS name of the IPA domain
    --rid-base=RID_BASE
                        Start value for mapping UIDs and GIDs to RIDs
    --secondary-rid-base=SECONDARY_RID_BASE
                        Start value of the secondary range for mapping UIDs
                        and GIDs to RIDs

  Uninstall options:
    --ignore-topology-disconnect
                        do not check whether server uninstall disconnects the
                        topology (domain level 1+)
    --ignore-last-of-role
                        do not check whether server uninstall removes last
                        CA/DNS server or DNSSec master (domain level 1+)

  Logging and output options:
    -v, --verbose       print debugging information
    -d, --debug         alias for --verbose (deprecated)
    -q, --quiet         output only errors
    --log-file=FILE     log to the given file
```
