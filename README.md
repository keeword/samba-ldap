# keeword/samba-ldap

Run samba with ldap authentication backend.

# Environment Variables

- `LDAP_BASE_DN`: ldap base domain, eg: dc=example,dc=org
- `LDAP_URI`: ldap uri, eg: ldap://ldap.example.org
- `LDAP_ADMIN_ACCOUNT`: comman name of ldap administrator, eg: admin
- `LDAP_ADMIN_PASSWORD`: password of ldap administrator

# Samba configuration

This is a example to config samba.

```
[global]
    server string = Samba Server (%v)
    workgroup = WORKGROUP
    server role = standalone server
    log file  = /var/log/samba/smb.log
    max log size = 10000
    log level = 2 auth:5

    passdb backend     =  ldapsam:ldap://ldap.example.org
    ldap passwd sync   =  yes
    ldap admin dn      =  cn=admin,dc=example,dc=org
    ldap suffix        =  dc=example,dc=org
    ldap user suffix   =  ou=People
    ldap group suffix  =  ou=Group
    ldap delete dn     =  no
    ldap ssl           =  off

[mnt]
    comment = data
    path = /mnt
    browseable = yes
    writeable = yes
    guest ok = yes
    create mask = 0770
    directory mask = 0770
    map acl inherit = Yes
    inherit permissions = yes
```

# Run

```
docker run --name samba-ldap --rm \
	   -e LDAP_BASE_DN="dc=example,dc=org" \
	   -e LDAP_URI="ldap://ldap.example.org" \
	   -e LDAP_ADMIN_ACCOUNT="admin" \
	   -e LDAP_ADMIN_PASSWORD="**********" \
	   -p 445:445 \
	   -v $(pwd)/smb.conf:/etc/samba/smb.conf:ro \
	   -v /mnt:/mnt \
	   keeword/samba-ldap
```
