#!/bin/bash
KEYCLOAK_URL=http://keycloak.lacave
KEYCLOAK_REALM=bookstore
KEYCLOAK_USER=julio
KEYCLOAK_PASSWORD=toto1234
CLIENT_ID=bookstoreui
CLIENT_SECRET=a9736089-fdc4-41ad-a09e-3f464c9b141d
BOOKAPI_URL=http://bookstoreapi.lacave/api
ACCESS_TOKEN=$(curl --silent --insecure --data-urlencode "grant_type=password" \
	--data-urlencode "username=$KEYCLOAK_USER" \
	--data-urlencode "password=$KEYCLOAK_PASSWORD" \
	--data-urlencode "client_id=$CLIENT_ID" \
	--data-urlencode "client_secret=$CLIENT_SECRET" \
	--data-urlencode "scope=openid" \
	"$KEYCLOAK_URL/auth/realms/$KEYCLOAK_REALM/protocol/openid-connect/token" | jq -r .access_token)
echo $ACCESS_TOKEN
curl --silent $BOOKAPI_URL/books | jq
BOOKID=$(curl --silent -H "Authorization: bearer $ACCESS_TOKEN" $BOOKAPI_URL/books | jq -r .[0].id)
echo BOOKID: $BOOKID

curl -v -H "Authorization: bearer $ACCESS_TOKEN" $BOOKAPI_URL/books/$BOOKID | jq