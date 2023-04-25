## Troubleshooting ##


### Peer Not authenticated ###
Error: javax.net.ssl.SSLPeerUnverifiedException: peer not authenticated

1. Check SaltMaster cert:
```bash
# get the cert used by salt and extract the expiration date
# openssl x509 -enddate -noout -in $(grep ssl_crt /etc/salt/master.d/salt-api.conf | cut -d':' -f2) | cut -d= -f 2
[/etc/salt/master.d/certs]:openssl x509 -enddate -noout -in $(grep ssl_crt /etc/salt/master.d/salt-api.conf | cut -d':' -f2) | cut -d= -f 2
May 20 23:59:59 2023 GMT
```

If the certificate has expired, refresh salt & run:
```bash
salt "saltserver*" state.highstate \ saltenv=saltmaster_ssl -l debug
```
This will refresh the file, restart salt-master with: 
```bash
systemctl restart salt-master
```

2. Check if Rundeck has the certificate in java trustore and rundeck trustore:

```bash
# check in rundeck truststore
keytool -list -keystore /etc/rundeck/ssl/truststore | grep mydomain #password is the same
mydomaincom, 30-Apr-2020, trustedCertEntry,
 
# check in java cacert
keytool -list -keystore /etc/pki/ca-trust/extracted/java/cacerts | grep mydomain 
Enter keystore password:  ****
mydomaincom, 28-Apr-2022, trustedCertEntry,
 
# if you need to clean up extra cert, previous tests or previous certs:
keytool -delete -noprompt -alias mydomainold  -keystore /etc/pki/ca-trust/extracted/java/cacerts -storepass ****
```

3. Add the new certificate to the keystores:
```bash
# Rundeck
keytool -import -v -trustcacerts -alias mydomainnew -file /etc/nginx/ssl/wildcard_mydomain.pem -keystore etc/rundeck/ssl/truststore
# Java
keytool -importcert -trustcacerts -file /etc/salt/master.d/certs/wildcard_mydomain.pem -alias mydomainnew -keystore /etc/pki/ca-trust/extracted/java/cacerts
```

4. Reboot