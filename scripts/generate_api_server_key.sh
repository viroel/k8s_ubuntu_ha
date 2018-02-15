#!/bin/bash -x

cat <<EOF | sudo tee ${CA_DIR}/server-openssl.cnf
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[v3_req]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
IP.1 = 127.0.0.1
IP.2 = ${LB_IP}
EOF

sudo openssl genrsa -out ${CA_DIR}/server.key 2048

sudo openssl req -new -key ${CA_DIR}/server.key -subj "/CN=${LB_IP}-apiserver" -out ${CA_DIR}/server.csr -config ${CA_DIR}/server-openssl.cnf

sudo openssl x509 -req -in ${CA_DIR}/server.csr -CA ${CA_DIR}/ca.crt -CAkey ${CA_DIR}/ca.key -CAcreateserial -out ${CA_DIR}/server.crt -days 10000 -extensions v3_req -extfile ${CA_DIR}/server-openssl.cnf

sudo openssl x509 -noout -text -in ${CA_DIR}/server.crt