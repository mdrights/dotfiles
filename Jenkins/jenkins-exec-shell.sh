#!/bin/bash
#exec-shell-jenkins.sh

#echo ">> Set Vault Secret (DEV)"
#curl -k --location --request POST 'https://vault.pru.intranet.asia/v1/kv2/data/sgrass/nprd/uat/osdvum/az1/sgrass-dev-az1-devpruexpert/azure' \
#--header 'X-Vault-Token: s.oG6rZV0bNxZIZA2MofFFgtQe' \
#--header 'Content-Type: application/json' \
#--data '{
#  "data": {
#    "service-bus-pri-conn": "Endpoint=sb://sbn-sgrass-dev-az1-kfdy9w.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=JZZygeCEhzzFThuSZaVn+Xw6J+9PmxcBDgx7sLo2i7g=",
#    "service-bus-sec-conn": "Endpoint=sb://sbn-sgrass-dev-az1-kfdy9w.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=Q/RU1oNj45zPIWQGofZ4ZlHUMM8tELYlOcx8odBOoco="
#  }
#}'


#echo ">> Set Vault Secret (SIT)"
#curl -k --location --request POST 'https://vault.pru.intranet.asia/v1/kv2/data/sgrass/nprd/uat/osdvum/az1/sgrass-dev-az1-pruexpert/azure' \
#--header 'X-Vault-Token: s.oG6rZV0bNxZIZA2MofFFgtQe' \
#--header 'Content-Type: application/json' \
#--data '{
#  "data": {
#    "service-bus-pri-conn": "Endpoint=sb://sbn-sgrass-dev-az1-kfdy9w.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=JZZygeCEhzzFThuSZaVn+Xw6J+9PmxcBDgx7sLo2i7g=",
#    "service-bus-sec-conn": "Endpoint=sb://sbn-sgrass-dev-az1-kfdy9w.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=Q/RU1oNj45zPIWQGofZ4ZlHUMM8tELYlOcx8odBOoco="
#  }
#}'


curl -sS -O -usrvhkrhotmsdev:eyJ2ZXIiOiIyIiwidHlwIjoiSldUIiwiYWxnIjoiUlMyNTYiLCJraWQiOiJOZnFSY2tNOUJTLWJZck9FWmwyLV9FeDB5eTB6TGFpa2ZtOW5yTjE1NkQ0In0.eyJzdWIiOiJqZnJ0QDAxY3F3eW4wN2pnM3hhMThiaHluOG4xNmhiXC91c2Vyc1wvc3J2aGtyaG90bXNkZXYiLCJzY3AiOiJtZW1iZXItb2YtZ3JvdXBzOiogYXBpOioiLCJhdWQiOiJqZnJ0QDAxY3F3eW4wN2pnM3hhMThiaHluOG4xNmhiIiwiaXNzIjoiamZydEAwMWNxd3luMDdqZzN4YTE4Ymh5bjhuMTZoYlwvdXNlcnNcL2thbWFyLnJ1c2hkaS5oaXNoYW1AcHJ1ZGVudGlhbC5jb20ubXkiLCJpYXQiOjE1NzY3NDU2MjQsImp0aSI6ImVlMzE2ZDZiLTRmMzEtNDIwYi05YmYwLWFlYThlYjJkOTc3NCJ9.J_qBNoRP03GQq_xQidWANCv6ypMWHeHifabWO7u-JFauqwG3dW-Ya0F8dsbQCpPn0F1twJ95vDjMblGMZS4BrPeh4R94MPX7WCVcvn0tKcNvX4AjAHWSzy5J671DBY95SLCTS8Fgh91h0JFdpJSWoPTWrpfU1c7gpf8Wsr33sa6Wqrnq8GWk2gR7oIZ4tsSX_KpxdDE6GDipzKyvdzRXDgtL0V7NOtnt0lEAdewb8bPcEuiwfQyNiXc2WmF0v-h_TGPnau3kkkwumYrurkdxYqXO1IFHYPdxKTigP25mU5ezvCzlsX2cjVsgJ4DJsYZt_t6sN6zrCErJFOebyR-jOw \
      https://artifactory.pruconnect.net/artifactory/generic-pca-tms-local/jq-linux64

chmod +x ./jq-linux64

  echo "==== Login to Vault with user LDAP credential ===="
  export USERNAME=368099
  export PASSWORD=''
  export APPROLE_NAME="apr-rtai-appref-kvreader-jaguyu"
  export VAULT_ADDR="https://vault.pru.intranet.asia"
  export KV_PATH="sgrass/prod/prd/jaguyu"
  export KV_ENDPOINT="sbn-sgrass-prd-az1-jaguyu"

  #curl -k -sS -X POST -d '{"password": "'"${PASSWORD}"'"}' ${VAULT_ADDR}/v1/auth/PRUASIA/login/${USERNAME} 
  VAULT_TOKEN=$(curl -k -sS -X POST -d '{"password": "'"${PASSWORD}"'"}' ${VAULT_ADDR}/v1/auth/PRUASIA/login/${USERNAME}  | ./jq-linux64 .auth.client_token )
  VAULT_TOKEN=$(echo $VAULT_TOKEN |tr -d '"')

  echo "==== Read AppRole role-id and secret-id with user token ===="
  ROLE_ID=$(curl -sS -k -H "X-Vault-Token: $VAULT_TOKEN" ${VAULT_ADDR}/v1/auth/approle/role/${APPROLE_NAME}/role-id | ./jq-linux64 .data.role_id)
  SECRET_ID=$(curl -sS -k -H "X-Vault-Token: $VAULT_TOKEN" -X PUT -d 'null' ${VAULT_ADDR}/v1/auth/approle/role/${APPROLE_NAME}/secret-id | ./jq-linux64 .data.secret_id)

  ROLE_ID=$(echo $ROLE_ID |tr -d '"')
  SECRET_ID=$(echo $SECRET_ID |tr -d '"')
  
  
  echo "==== Login to vault with approle role-id and secret-id ===="
  VAULT_TOKEN=$(curl -sS -k -X POST -d '{"role_id": "'"$ROLE_ID"'", "secret_id": "'"$SECRET_ID"'"}' ${VAULT_ADDR}/v1/auth/approle/login | ./jq-linux64 .auth.client_token )
  VAULT_TOKEN=$(echo $VAULT_TOKEN |tr -d '"')
  
  echo "==== List KV path ===="
  curl -sS -k -H "X-Vault-Token: $VAULT_TOKEN" https://vault.pru.intranet.asia/v1/kv2/metadata/${KV_PATH}?list=true | ./jq-linux64 .data.keys
  
  
  echo "==== Fetch the Secrets ===="
  curl -sS -k --header  "X-Vault-Token: ${VAULT_TOKEN}" --location ${VAULT_ADDR}/v1/kv2/data/${KV_PATH}/${KV_ENDPOINT} | ./jq-linux64
