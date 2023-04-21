zabbix-agent:
  pkg.installed:
    - name: zabbix-agent
    - skip_verify: True
    - allow_updates: True
  service:
    - running
    - enable: True
    - restart: True
    - watch:
      - file: zabbix_conf
      - pkg: zabbix-agent

zabbix_conf:
  file.managed:
    - name: /etc/zabbix/zabbix_agentd.conf
    - source: salt://zabbix/files/zabbix_agentd.conf
    - template: jinja
    - require:
      - pkg: zabbix-agent

zabbix_conf_docker_user_parameter:
  file.managed:
    - name: /etc/zabbix/zabbix_agentd.d/userparameter_docker.conf
    - source: salt://zabbix/files/userparameter_docker.conf
    - user: root
    - group: root
    - mode: '644'
    - create: True

zabbix_conf_directory_checks:
  file.managed:
    - name: /etc/zabbix/zabbix_agentd.d/folder_checks.conf
    - source: salt://zabbix/files/folder_checks.conf
    - user: root
    - group: root
    - mode: '644'
    - create: True

zabbix_conf_docker_stats:
  file.managed:
    - name: /usr/local/bin/docker_stats.sh
    - source: salt://zabbix/files/docker_stats.sh
    - user: root
    - group: root
    - mode: '755'
    - create: True

zabbix_conf_docker_discovery:
  file.managed:
    - name: /usr/local/bin/docker_discovery.sh
    - source: salt://zabbix/files/docker_discovery.sh
    - user: root
    - group: root
    - mode: '755'
    - create: True

zabbix_conf_docker_inspects:
  file.managed:
    - name: /usr/local/bin/docker_inspect.sh
    - source: salt://zabbix/files/docker_inspect.sh
    - user: root
    - group: root
    - mode: '755'
    - create: True

zabbix_conf_rabbitmq_user_parameter:
  file.managed:
    - name: /etc/zabbix/zabbix_agentd.d/zabbix-rabbitmq.conf
    - source: salt://zabbix/files/zabbix-rabbitmq.conf
    - user: root
    - group: root
    - mode: '644'
    - create: True

### Misc Commands ###
misc_commands:
  cmd.run:
    - names:
      - semanage permissive -a zabbix_agent_t

misc_commands_zabbix:
  cmd.run:
    - onlyif: rpm -q docker
    - names:
      - usermod -aG docker zabbix
      - systemctl restart zabbix-agent

#
#zabbix_agentd -t docker.stats
#semanage permissive -a zabbix_agent_t
#zabbix_agentd -t docker.list.discovery



# Grafana plugin
# grafana-cli plugins install alexanderzobnin-zabbix-app
# install unzip
# unzip plugin into /var/lib/grafana/plugin
