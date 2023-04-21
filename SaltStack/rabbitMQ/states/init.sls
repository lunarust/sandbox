### Installation of RabbitMQ Server ###
erlang:
  pkg.installed:
    - name: erlang
    - unless: which erlang
    - skip_verify: True

rabbitmq-server:
  pkg.installed:
    - name: rabbitmq-server
    - unless: which rabbitmq-server
    - skip_verify: True
  service:
    - state: running
    - enable: False
    - restart: False

### RabbitMQ files ###
rabbitmq:
  file.recurse:
    - name: /etc/rabbitmq
    - source: salt://rabbitmq/files
    - user: root
    - group: rabbitmq
    - file_mode: '644'
    - template: jinja
    - create: True

cookie:
  file.managed:
    - name: /var/lib/rabbitmq/.erlang.cookie
    - source: salt://rabbitmq/cookie/erlang.cookie
    - replace: True
    - user: rabbitmq
    - group: rabbitmq
    - mode: 400
    - template: jinja
    - create: True

rabbitmq_self_sign_ca:
  cmd.run:
    - unless:
      - fun: file.file_exists
        path: /etc/rabbitmq/server/server_certificate.pem
    - names:
      - /opt/scripts/rabbitmq_prepare_cert.sh
      - systemctl restart rabbitmq-server

### RabbitMQ add monitoring user
rabbitmq_zabbix_user:
  cmd.run:
    - unless: rabbitmqctl list_users | grep zbx_monitor
    - names:
      - rabbitmqctl add_user zbx_monitor zabbix
      - rabbitmqctl set_permissions  -p / zbx_monitor "" "" ".*"
      - rabbitmqctl set_user_tags zbx_monitor monitoring
