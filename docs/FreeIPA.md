# FreeIPA


## Check Services status:
```bash
ipactl status
Directory Service: RUNNING
krb5kdc Service: RUNNING
kadmin Service: RUNNING
named Service: RUNNING
httpd Service: RUNNING
ipa-custodia Service: RUNNING
ntpd Service: RUNNING
pki-tomcatd Service: STOPPED
ipa-otpd Service: RUNNING
ipa-dnskeysyncd Service: RUNNING
ipa: INFO: The ipactl command was successful

# Restart Services
ipactl restart
```

## Create User
```bash
ipa user-add balthazar --first=balthazar --last=Grande --email=balthazar@plop.com
```
```bash
# Add user to existing group
ipa group-add-member sales --user=balthazar
  Group name: sales
  GID: 1123800036
  Member users: balthazar
-------------------------
Number of members added 1
-------------------------
```

## Create & review rules 

```bash
ipa sudorule-add dba_sudo_rule  --cmdcat="all"
ipa sudorule-add-user --groups=dba dba_sudo_rule
```



```bash
# get all existing sudo rules
ipa sudorule-find All
--------------------
2 Sudo Rules matched
--------------------
  Rule name: all-admins
  Enabled: TRUE
  Host category: all
  Command category: all

  Rule name: dba_sudo_rule
  Enabled: TRUE
  Command category: all
----------------------------
Number of entries returned 2
----------------------------

```

```bash
[root@ipa01 ~]#  ipa sudorule-show dba_sudo_rule 
  Rule name: dba_sudo_rule
  Enabled: TRUE
  Command category: all
  Users: joedba, bobdba
  User Groups: dba
  Hosts: dbadmin01.plop.local, reporting01.plop.local
```

## Search user
```bash
ldapsearch -b "dc=plop,dc=local" "(&(cn=*)(memberUid=celine))"
SASL/GSSAPI authentication started
SASL username: celine@plop.LOCAL
SASL SSF: 256
SASL data security layer installed.
# extended LDIF
#
# LDAPv3
# base <dc=plop,dc=local> with scope subtree
# filter: (&(cn=*)(memberUid=celine))
# requesting: ALL
#

# search result
search: 4
result: 0 Success

# numResponses: 1
```

## Sync issue
```bash
ipa-replica-manage re-initialize --from ipa02.local
Update in progress, 3 seconds elapsed
Update succeeded
```
count or check users/group/hosts
ipa host-find
ipa user-find
...





## Connection Configuration example:

### Jenkins:
```
Go to: Manage Jenkins > Configure Global Security
Security Realm: LDAP
Servers: ldap://10.0.1.1:389 ldap://10.0.11.1:389
root DN: dc=plop,dc=local
User search base: cn=users,cn=accounts
User search filter: uid={0}
Group search base: cn=groups,cn=accounts
Group membership > Search for LDAP groups containing user
Group membership filter: (| (member={0}) (uniqueMember={0}) (memberUid={1}))
Manager DN: uid=jenkins-ldap,cn=users,cn=accounts,dc=plop,dc=local
Display Name LDAP attribute: displayname
Email Address LDAP attribute: mail
```
### Graylog:

Navigate to System > Authentication

#### Server configuration:
```
Title: LDAP-FreeIPA
Description: Optional
Server Address: ipa01.plop.local
Port: 389
System User DN: uid=graylog_ldap,cn=users,cn=accounts,dc=plop,dc=local
```
#### User Synchronization:
```
Search Base DN: dc=plop,dc=local
Search Pattern: (&(objectClass=posixaccount)(uid={0}))
Name Attribute: uid
Full Name Attribute: cn
ID Attribute: uid
Default Roles: Reader
```

### Zabbix:
Navigate to Administration > Authentication > LDAP settings
```
LDAP host: 10.0.1.10
Port: 389
Base DN: cn=users,cn=accounts,dc=plop,dc=local
Search attribute: uid
Bind DN: uid=user_ldap,cn=users,cn=accounts,dc=plop,dc=local
Bind Password: PasswordForACCT
```
Note: You will still have to set up an account in Zabbix and add them to a group.

### Grafana: 
Create and edit 
[/etc/grafana/ldap.toml](./Grafana/ldap.toml)

### Rundeck: 
Create and edit 
[/etc/rundeck/jaas-ldap.conf](./Rundeck/jaas-ldap.conf)

### JasperServer
Create and edit
[/opt/jasperserver/apache-tomcat/webapps/jasperserver/WEB-INF/applicationContext-externalAuth-LDAP.xml](./JasperServer/applicationContext-externalAuth-LDAP.xml)

### Metabase

Admin Settings > Authentication > LDAP
```
LDAP HOST: ipa.plop.local
LDAP PORT: 389
LDAP SECURITY: None
USERNAME OR DN: uid=metabase_ldap,cn=users,cn=compat,dc=plop,dc=local
PASSWORD: xxxx

USER SEARCH BASE: cn=users,cn=accounts,dc=plop,dc=local
USER FILTER: (&(objectClass=inetuser)(|(uid={login})(mail={login})))
ENABLE Synchronize group memberships
```