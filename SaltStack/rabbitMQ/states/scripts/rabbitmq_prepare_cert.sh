#!/bin/bash
#===============================================================================
#         FILE: rabbitmq_prepare_cert.sh
#       AUTHOR: Celine H.
# ORGANIZATION: ---
#      VERSION: 0.0.1
#      CREATED: 20-01-2021
#         TODO:
#===============================================================================

echo "Preparing Authority"
cd /etc/rabbitmq/testca
mkdir certs private
chmod 700 private
echo 01 > serial
touch index.txt

openssl req -x509 -config openssl.cnf -newkey rsa:2048 -days 365 \
    -out ca_certificate.pem -outform PEM -subj /CN=MyTestCA/ -nodes
openssl x509 -in ca_certificate.pem -out ca_certificate.cer -outform DER

cd ..
echo "Preparing Server certificate"
mkdir server
cd server
openssl genrsa -out private_key.pem 2048
openssl req -new -key private_key.pem -out req.pem -outform PEM \
    -subj /CN=$(hostname)/O=server/ -nodes
cd ../testca
openssl ca -config openssl.cnf -in ../server/req.pem -out \
    ../server/server_certificate.pem -notext -batch -extensions server_ca_extensions
cd ../server
openssl pkcs12 -export -out server_certificate.p12 -in server_certificate.pem -inkey private_key.pem \
    -passout pass:MySecretPassword

cd ..
echo "Preparing Client"
mkdir client
cd client
openssl genrsa -out private_key.pem 2048
openssl req -new -key private_key.pem -out req.pem -outform PEM \
    -subj /CN=$(hostname)/O=client/ -nodes
cd ../testca
openssl ca -config openssl.cnf -in ../client/req.pem -out \
    ../client/client_certificate.pem -notext -batch -extensions client_ca_extensions
cd ../client
openssl pkcs12 -export -out client_certificate.p12 -in client_certificate.pem -inkey private_key.pem \
    -passout pass:MySecretPassword

echo "########## Note ##############"
echo "Certifate handshake can be tested with the following command:"
echo "openssl s_client -connect localhost:5671 -cert /etc/rabbitmq/client/client_certificate.pem -key /etc/rabbitmq/client/private_key.pem -CAfile /etc/rabbitmq/testca/ca_certificate.pem"
echo "------- OR ------"
echo "Another check cand be done with a sever listening and a client, you will need 2 separate sessions:"
echo "First open the server ready to listen and accept connection"
echo "openssl s_server -accept 8443   -cert /etc/rabbitmq/server/server_certificate.pem -key /etc/rabbitmq/server/private_key.pem -CAfile  /etc/rabbitmq/testca/ca_certificate.pem"
echo "Launch a client"
echo "openssl s_client -connect localhost:8443 -cert /etc/rabbitmq/client_certificate.pem -key /etc/rabbitmq/client/private_key.pem -CAfile -CAfile /etc/rabbitmq/testca/ca_certificate.pem -verify 8 -verify_hostname staging1-app01.mgmt.local"
echo "########## Note ##############"
echo "https://www.rabbitmq.com/ssl.html#tls-connectivity-options"
