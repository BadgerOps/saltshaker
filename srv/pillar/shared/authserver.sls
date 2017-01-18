
authserver:
    backend: postgresql
    dbname: authserver
    dbuser: authserver  # unused if vault-manages-database is True


    stored-procedure-api-users:
        - opensmtpd-authserver
        - dovecot-authserver


dkimsigner:
    dbuser: dkimsigner  # a read-only user for the mailauth_domains table


# vim: syntax=yaml
