# common ssl path config
# all certificate secrets are in the saltshaker-secrets git submodule
ssl:
    certificate-location: /etc/ssl/local
    secret-key-location: /etc/ssl/private
    localca-links-location: /etc/ssl/certs
    localca-location: /usr/share/ca-certificates/local

    # the following defaults should be used by each service which doesn't
    # require or is configured with its own cert.
    default-cert: /etc/ssl/local/wildcard.crt
    default-cert-combined: /etc/ssl/local/wildcard-combined.crt
    default-cert-key: /etc/ssl/private/wildcard.key
    default-cert-full: /etc/ssl/private/wildcard-combined-key.crt

    # The root CA certificate of the CA issuing service certificates in this environment and where it's stored
    # on the nodes (i.e. where other software can find it).
    rootca-cert: /usr/share/ca-certificates/local/maurusnet-rootca.crt
    rootca-source: salt://crypto/maurusnet-rootca.crt
