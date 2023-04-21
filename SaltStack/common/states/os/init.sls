# Install Spacewalk client and register node to Spacewalk
install_spacewalk_client:
  cmd.run:
    - unless: which rhnsd
    - names:
      - rpm -Uvh http://spacewalk01.plop.local/pub/rhn-org-trusted-ssl-cert-1.0-1.noarch.rpm

install_spacewal_tools:
  pkg.installed:
    - unless: which rhnsd
    - pkgs:
      - epel-release
      - rhn-client-tools
      - Dv
      - rhn-setup
      - rhnsd m2crypto
      - yum-rhn-plugin
      - rhncfg rhncfg-actions
      - rhncfg-client

install_spacewalk_registration:
  cmd.run:
    - unless: rhn-channel -l
    - names:
      - rhnreg_ks --serverUrl=http://spacewalk.plop.local/XMLRPC --sslCACert=/usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT --activationkey=1-xxxxxxxxxxxxx

install_spacewalk_restart_channel:
  cmd.run:
    - names:
      - systemctl enable rhnsd && systemctl start rhnsd
      - rhn-channel -a --channel=zabbix-client --user=devops --password=xxxxxxxxxx


# Spacewalk Nodes Registration ##
cmd_remove_default_repos:
  cmd.run:
    - unless: which spacewalk-service
    - names:
      - rm -rf /var/cache/yum/*
      - rm -rf /etc/yum.repos.d/*

# Install packages not shipped with CentOS7
install_base_packages:
  pkg.installed:
    - pkgs:
      - policycoreutils-python
      - sysstat
      - screen
      - net-tools
      - rsync
      - bind-utils
      - telnet
      - wget
      - vim-enhanced.x86_64
      - mlocate
      - htop
      - rhncfg-actions
      - rhnsd
    - skip_verify: True
    - allow_updates: True

install_extra_packages:
  pkg.installed:
    - pkgs:
      - nc
    - unless:
      - which nc

# Set timezone to UTC
UTC:
  timezone.system:
    - utc: True

# Push motd file
motd:
  file.managed:
    - name: /etc/motd
    - source: salt://os/files/motd

{% if grains['fqdn'] != 'sftp.plop.local' %}

#!!! MUST ADD EXCEPTION FOR SFTPNODE
# Push sshd_config
sshd_config:
  file.managed:
    - name: /etc/ssh/sshd_config
    - template: jinja
    - source: salt://os/files/sshd_config
    - user: root
    - group: root
    - mode: 644

{% endif %}

# change directory permissions for Zabbix for /etc/audit
/etc/audit:
  file.directory:
    - user: root
    - name: /etc/audit
    - group: root
    - mode:  755

# change directory permissions for Zabbix
/etc/audit/rules.d:
  file.directory:
    - user: root
    - name: /etc/audit/rules.d
    - group: root
    - mode:  755

# Push audit.rules file
audit_rules:
  file.managed:
    - name: /etc/audit/rules.d/audit.rules
    - source: salt://os/files/audit.rules
    - user: root
    - group: root
    - mode: 644
    - create: True

# Remove /etc/audit/audit.rules file
auditd_rules_existing_conf:
  cmd.run:
    - names:
      - rm -rf /etc/audit/audit.rules
      - dos2unix /etc/audit/rules.d/audit.rules

spacewalk_rhn_control:
  cmd.run:
    - names:
      - rhn-actions-control --enable-all


# Auditd Rules
auditd_restart:
  cmd.run:
    - names:
      - service auditd stop
      - service auditd start

# Make sure sshd is running
sshd:
  service:
    - running
    - enable: True
    - restart: True
    - watch:
      - file: sshd_config

ipv6_disable:
    sysctl.present:
      - name: net.ipv6.conf.all.disable_ipv6
      - value: 0

# FreeIPA config to create home dir on initial login
authconfig --enablemkhomedir --update:
  cmd.run:
    - unless: cat /etc/sysconfig/authconfig | grep USEMKHOMEDIR=yes

# Create cronjob to cleanup old kernels
/bin/package-cleanup --oldkernels --count=2 -y:
  cron.present:
    - user: root
    - minute: 0
    - hour: 10
    - dayweek: 2
    - identifier: cleanup_oldkernels

# Install ntp service
ntpd:
  pkg.installed:
    - name: ntp
  service:
    - running
    - enable: True
    - restart: True
    - watch:
      - file: /etc/ntp.conf
      - pkg: ntp


# Push ntp.conf
ntp.conf:
  file.managed:
    - name: /etc/ntp.conf
    - source: salt://os/files/ntp.conf
    - template: jinja
    - require:
      - pkg: ntp

# Enable ntp synchronization ##
cmd_enable_ntp:
  cmd.run:
    - names:
      - timedatectl set-ntp true
      - systemctl restart ntpd
      - systemctl enable ntpd
      - systemctl disable chronyd

# Enable date  in history
cmd_profile:
  cmd.run:
    - names:
      - echo 'export HISTTIMEFORMAT="%d/%m/%y %T "' >> /etc/skel/.bash_profile

cmd_gpgcheck:
  cmd.run:
    - names:
      - sed -i 's/gpgcheck=1/gpgcheck=0/' /etc/yum.conf

# Make sure firewalld is running
firewalld:
  pkg.installed:
    - name: firewalld
    - skip_verify: True
  service:
    - running
    - enable: True
    - restart: True
    - watch:
      - pkg: firewalld

# Firewall-cmd Default Ports
public:
  firewalld.present:
    - name: public
    - default: False
    - masquerade: False
    - ports:
      - 22/tcp
      - 161/udp
      - 10050/tcp

# Set selinux to enforcing
enforcing:
    selinux.mode

{% if grains['fqdn'] != 'postfix.plop.local' %}
postfix:
  service:
    - running
    - enable: False
    - restart: False
    - stop: True
{% endif %}

journalctl_persistent_directory:
  cmd.run:
    - names:
      - mkdir -p /var/log/journal

# Push journald.conf
/etc/systemd/journald.conf:
  file.managed:
    - source: salt://os/files/journald.conf
    - template: jinja
