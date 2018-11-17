# TODO: for COnsul 1.4 replace this with a orchestrate reactor that runs
# two states: one to create the agent policy and one to update the acl token

consul_acl_create:
    runner.salt.cmd:
        - args:
            - fun: http.query
            - url: http://169.254.1.1:8500/v1/acl/token/{{salt['dynamicsecrets'].get_store().get_or_create(
                  {
                      "type": "consul-acl-token",
                  },
                  'consul-acl-token',
                  host=data['id'])}}
            - method: PUT
            - header_dict:
                X-Consul-Token: {{salt['dynamicsecrets'].get_store().load('consul-acl-master-token', host="*")}}
            - data: >-
                {
                    "Description": "{{data['id']}}",
                    "Policies": ["{{"
                        key_prefix \"\" {
                            policy = \"deny\"
                        }

                        key_prefix \"oauth2-clients\" {
                            policy = \"write\"
                        }

                        key_prefix \"concourse/workers/sshpub\" {
                            policy = \"write\"
                        }

                        node \"\" {
                            policy = \"read\"
                        }

                        node \""|replace('\n', '\\n')|replace('"', '\\"')}}{{data['id']}}{{"\" {
                            policy = \"write\"
                        }

                        service \"\" {
                            policy = \"write\"
                        }

                        agent \""|replace('\n', '\\n')|replace('"', '\\"')}}{{data['id']}}{{"\" {
                            policy = \"read\"
                        }

                        event_prefix \"\" {
                            policy = \"read\"
                        }

                        query_prefix \"\" {
                            policy = \"read\"
                        }
                    "|replace('\n', '\\n')|replace('"', '\\"')}}"
                }
