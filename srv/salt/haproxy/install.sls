# install haproxy

haproxy:
    pkg:
        - installed
    service.dead:
        - name: haproxy
        - enable: False
        - prereq:
            - file: haproxy-multi
    file.absent:
        - name: /etc/init.d/haproxy
        - require:
            - service: haproxy


# set up a systemd config that supports multiple haproxy instances on one machine
haproxy-multi:
    file.managed:
        - name: /etc/systemd/system/haproxy@.service
        - source: salt://haproxy/haproxy@.service
        - user: root
        - group: root
        - mode: '0644'
        # note that there is NO dependency to pkg: haproxy here! This is because we declare haproxy to be
        # a prereq of haproxy-multi


haproxy-remove-packaged-config:
    file.absent:
        - name: /etc/haproxy/haproxy.cfg


haproxy-data-dir:
    file.directory:
        - name: /run/haproxy
        - makedirs: True
        - user: haproxy
        - group: haproxy
        - mode: '2755'
        - require:
            - pkg: haproxy


haproxy-data-dir-systemd:
    file.managed:
        - name: /usr/lib/tmpfiles.d/haproxy.conf
        - source: salt://haproxy/haproxy.tmpfiles.conf
        - user: root
        - group: root
        - mode: '0644'
        - require:
            - pkg: haproxy


haproxy-config-template:
    file.managed:
        - name: /etc/haproxy/haproxy.jinja.cfg
        - source: salt://haproxy/haproxy.jinja.cfg
        - require:
            - pkg: haproxy


# vim: syntax=yaml