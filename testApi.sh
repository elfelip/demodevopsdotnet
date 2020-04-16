#!/bin/bash
KEYCLOAK_URL=http://keycloak.lacave
KEYCLOAK_REALM=master
KEYCLOAK_USER=felip
KEYCLOAK_PASSWORD=toto1234
CLIENT_ID=bookstoreui
CLIENT_SECRET=1ff9751f-513f-4d60-8bf8-73295cc12f4c
#CLIENT_ID=bookstoreapi
#CLIENT_SECRET=715f81a1-b2fa-4c04-be6a-3f35738e2e1a
BOOKAPI_URL=http://bookstoreapi.lacave/api
curl --silent $BOOKAPI_URL/books | jq
BOOKID=$(curl --silent $BOOKAPI_URL/books | jq -r .[0].id)
echo BOOKID: $BOOKID
#ACCESS_TOKEN=$(curl --silent -k -X POST -d "client_id=$CLIENT_ID" -d "client_secret=$CIENT_SECRET" -d "username=$KEYCLOAK_USER" -d "password=$KEYCLOAK_PASSWORD" -d "grant_type=password" $KEYCLOAK_URL/auth/realms/$KEYCLOAK_REALM/protocol/openid-connect/token | jq -r .access_token) 
#ACCESS_TOKEN=$(curl --silent -k -X POST -d "client_id=$CLIENT_ID" -d "username=$KEYCLOAK_USER" -d "password=$KEYCLOAK_PASSWORD" -d "grant_type=password" $KEYCLOAK_URL/auth/realms/$KEYCLOAK_REALM/protocol/openid-connect/token | jq -r .access_token) 
ACCESS_TOKEN=$(curl --insecure --data-urlencode "grant_type=password" \
	--data-urlencode "username=$KEYCLOAK_USER" \
	--data-urlencode "password=$KEYCLOAK_PASSWORD" \
	--data-urlencode "client_id=$CLIENT_ID" \
	--data-urlencode "client_secret=$CLIENT_SECRET" \
	--data-urlencode "scope=bookstoreapi" \
	"$KEYCLOAK_URL/auth/realms/$KEYCLOAK_REALM/protocol/openid-connect/token" | jq -r .access_token)
echo $ACCESS_TOKEN

curl -v -H "Authorization: bearer $ACCESS_TOKEN" $BOOKAPI_URL/books/$BOOKID