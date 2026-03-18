#!/bin/bash
set -e

CONFIGS_DIR="$(dirname "$0")/configs"
cd "$CONFIGS_DIR"

openssl genrsa -out ca.key 4096
openssl req -new -x509 -days 3650 -key ca.key -out ca.crt -subj \
  "/C=US/ST=California/L=San Francisco/O=HashiCorp/OU=Test Certificate Authority/CN=Prototype Test Certificate Authority"

openssl genrsa -out server.key 4096

openssl req -new -key server.key -out server.csr \
  -subj "/C=US/ST=California/L=San Francisco/O=HashiCorp/OU=Test Certificate Authority/CN=hashicorp.test" \
  -addext "subjectAltName=DNS:vault-tls,DNS:localhost,IP:127.0.0.1"

openssl x509 -req -days 3650 -in server.csr -CA ca.crt -CAkey ca.key \
  -CAcreateserial -out server.crt \
  -extfile <(echo "subjectAltName=DNS:vault-tls,DNS:localhost,IP:127.0.0.1")

openssl genrsa -out client.key 4096

openssl req -new -key client.key -out client.csr \
  -subj "/C=US/ST=California/L=San Francisco/O=HashiCorp/OU=Test Certificate Authority/CN=client"

openssl x509 -req -days 3650 -in client.csr -CA ca.crt -CAkey ca.key \
  -CAcreateserial -out client.crt

rm -f server.csr client.csr ca.srl

echo ""
echo "Certificados gerados com sucesso!"
echo ""
echo "Atualize os secrets do GitHub com os valores abaixo:"
echo ""
echo "VAULTCA:"
base64 -w 0 ca.crt
echo ""
echo "VAULT_CLIENT_CERT:"
base64 -w 0 client.crt
echo ""
echo "VAULT_CLIENT_KEY:"
base64 -w 0 client.key

#rode localmente
#chmod +x integrationTests/e2e-tls/generate-certs.sh./integrationTests/e2e-tls/generate-certs.sh