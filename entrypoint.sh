#!/usr/bin/env bash

NSS_LDAP_SECRET="/etc/libnss-ldap.secret"
SAMBA_SECRET="/var/lib/samba/private/secrets.tdb"

if [[ ! -e $NSS_LDAP_SECRET ]]; then
    if [[ -z "${LDAP_BASE_DN}" ]]; then
        echo "ERROR: Environment variable LDAP_BASE_DN not set"
        exit 10
    fi
    if [[ -z "${LDAP_URI}" ]]; then
        echo "ERROR: Environment variable LDAP_URI not set"
        exit 11
    fi 
    if [[ -z "${LDAP_ADMIN_ACCOUNT}" ]]; then
        echo "ERROR: Environment variable LDAP_ADMIN_ACCOUNT not set"
        exit 12
    fi
    if [[ -z "${LDAP_ADMIN_PASSWORD}" ]]; then
        echo "ERROR: Environment variable LDAP_ADMIN_ACCOUNT not set"
        exit 13
    fi

    # overwrite /etc/libpam_ldap.conf
    {
        echo "base ${LDAP_BASE_DN}"
        echo "uri ${LDAP_URI}"
        echo "rootbinddn cn=${LDAP_ADMIN_ACCOUNT},${LDAP_BASE_DN}"
        echo "ldap_version 3"
        echo "pam_password crypt"
    } >/etc/libpam_ldap.conf

    # overwrite /etc/libnss-ldap.conf
    {
        echo "base ${LDAP_BASE_DN}"
        echo "uri ${LDAP_URI}"
        echo "rootbinddn cn=${LDAP_ADMIN_ACCOUNT},${LDAP_BASE_DN}"
        echo "ldap_version 3"
    } >/etc/libnss-ldap.conf

    # change nsswitch.conf
    sed -i 's/^passwd.*$/passwd: files ldap/' /etc/nsswitch.conf
    sed -i 's/^group.*$/group: files ldap/' /etc/nsswitch.conf

    # remove use_authtok in /etc/pam.d/common-password
    sed -i 's/use_authtok//' /etc/pam.d/common-password

    # store password of ldap admin
    echo ${LDAP_ADMIN_PASSWORD} >/etc/libnss-ldap.secret
fi

if [[ -z "${LDAP_ADMIN_PASSWORD}" ]]; then
    echo "ERROR: Environment variable LDAP_ADMIN_PASSWORD not set"
    exit 14
else
    smbpasswd -w $LDAP_ADMIN_PASSWORD
fi
if [[ ! -e $SAMBA_SECRET ]] ; then
    echo "ERROR: $SAMBA_SECRET does not exists"
    exit 15
fi

if [[ $# -ge 1 && -x $(which $1 2>&-) ]]; then
    exec "$@"
elif [[ $# -ge 1 ]]; then
    echo "ERROR: command not found: $1"
    exit 16
elif ps -ef | egrep -v grep | grep -q smbd; then
    echo "Service already running, please restart container to apply changes"
else
    [[ ${NMBD:-""} ]] && ionice -c 3 nmbd -D
    exec ionice -c 3 smbd --no-process-group -FS </dev/null
fi
