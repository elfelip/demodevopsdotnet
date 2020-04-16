#!/bin/bash
KEYCLOAK_URL=http://keycloak.lacave
KEYCLOAK_REALM=master
KEYCLOAK_USER=admin
KEYCLOAK_PASSWORD=admin
CLIENT_ID=bookstoreapi
CLIENT_SECRET=715f81a1-b2fa-4c04-be6a-3f35738e2e1a

curl --insecure --data-urlencode "grant_type=password" \
	--data-urlencode "username=$KEYCLOAK_USER" \
	--data-urlencode "password=$KEYCLOAK_PASSWORD" \
	--data-urlencode "client_id=$CLIENT_ID" \
	--data-urlencode "client_secret=$CLIENT_SECRET" \
	--data-urlencode "scope=openid info offline_access"  \
	"$KEYCLOAK_URL/auth/realms/$KEYCLOAK_REALM/protocol/openid-connect/token"
