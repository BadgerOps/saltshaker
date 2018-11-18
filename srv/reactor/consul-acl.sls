# TODO: for COnsul 1.4 replace this with a orchestrate reactor that runs
# two states: one to create the agent policy and one to update the acl token

create-consul-acl-policy-and-token:
    runner.state.orchestrate:
        - args:
            - mods: orchestrate.consul-node-setup
            - pillar:
                tag: {{tag}}
                data: {{data|json}}
