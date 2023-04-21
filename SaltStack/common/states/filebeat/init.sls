### Install filebeat on CentOS7 ###
filebeat:
  pkg.installed:
    - pkgs:
       - filebeat
    - skip_verify: True
    - unless: which filebeat
  service:
    - running
    - enable: True
    - restart: True

### Push filebeat.yml file ###
filebeat_yml:
  file.managed:
    - name: /etc/filebeat/filebeat.yml
    - source: salt://filebeat/files/filebeat.yml
    - user: root
    - group: root
    - mode: '644'
    - create: True



### custom modules for centos ###

filebeat_logs:
   file.recurse:
    - name: /etc/filebeat/modules.d
    - source: salt://filebeat/modules_d
    - user: root
    - group: root
    - template: jinja
    - create: True

### postfix logs ###
custom_filebeat_modules:
  file.recurse:
    - name: /usr/share/filebeat/module
    - source: salt://filebeat/modules
    - user: root
    - group: root
    - create: True


### Add filebeat modules ###
filebeat_modules:
  cmd.run:
    - names:
      - filebeat modules enable system auditd
      - sudo systemctl restart filebeat
      - sudo systemctl enable filebeat
