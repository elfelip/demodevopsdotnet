#!/bin/bash
KEYCLOAK_URL=http://keycloak.lacave
KEYCLOAK_REALM=bookstore
KEYCLOAK_USER=gontran
KEYCLOAK_PASSWORD=toto1234
CLIENT_ID=bookstoreui
CLIENT_SECRET=a9736089-fdc4-41ad-a09e-3f464c9b141d
BOOKAPI_URL=http://bookstoreapi.lacave/api

echo Obtenir la liste des livres sans authentification

curl --silent $BOOKAPI_URL/books | jq

ACCESS_TOKEN=$(curl --silent --insecure --data-urlencode "grant_type=password" \
	--data-urlencode "username=$KEYCLOAK_USER" \
	--data-urlencode "password=$KEYCLOAK_PASSWORD" \
	--data-urlencode "client_id=$CLIENT_ID" \
	--data-urlencode "client_secret=$CLIENT_SECRET" \
	--data-urlencode "scope=openid" \
	"$KEYCLOAK_URL/auth/realms/$KEYCLOAK_REALM/protocol/openid-connect/token" | jq -r .access_token)
echo $ACCESS_TOKEN
BOOKID=$(curl --silent -H "Authorization: bearer $ACCESS_TOKEN" $BOOKAPI_URL/books | jq -r .[0].id)
echo obtenir le livre BOOKID: $BOOKID en tant que $KEYCLOAK_USER

curl --silent -H "Authorization: bearer $ACCESS_TOKEN" $BOOKAPI_URL/books/$BOOKID | jq

KEYCLOAK_USER=ginette
KEYCLOAK_PASSWORD=toto1234

ACCESS_TOKEN=$(curl --silent --insecure --data-urlencode "grant_type=password" \
	--data-urlencode "username=$KEYCLOAK_USER" \
	--data-urlencode "password=$KEYCLOAK_PASSWORD" \
	--data-urlencode "client_id=$CLIENT_ID" \
	--data-urlencode "client_secret=$CLIENT_SECRET" \
	--data-urlencode "scope=openid" \
	"$KEYCLOAK_URL/auth/realms/$KEYCLOAK_REALM/protocol/openid-connect/token" | jq -r .access_token)
echo $ACCESS_TOKEN

echo Créer le livre de la jungle en tant que $KEYCLOAK_USER

BOOKID=$(curl --silent -X POST -H "Authorization: bearer $ACCESS_TOKEN" -H "Content-type: application/json" --data-binary "@testBook1.json" $BOOKAPI_URL/books | jq -r .id)

curl --silent -H "Authorization: bearer $ACCESS_TOKEN" $BOOKAPI_URL/books/$BOOKID | jq

echo Nouvelle liste des livres
curl --silent $BOOKAPI_URL/books | jq

KEYCLOAK_USER=julio
KEYCLOAK_PASSWORD=toto1234

ACCESS_TOKEN=$(curl --silent --insecure --data-urlencode "grant_type=password" \
	--data-urlencode "username=$KEYCLOAK_USER" \
	--data-urlencode "password=$KEYCLOAK_PASSWORD" \
	--data-urlencode "client_id=$CLIENT_ID" \
	--data-urlencode "client_secret=$CLIENT_SECRET" \
	--data-urlencode "scope=openid" \
	"$KEYCLOAK_URL/auth/realms/$KEYCLOAK_REALM/protocol/openid-connect/token" | jq -r .access_token)
echo $ACCESS_TOKEN

echo Supprimer le livre de la jungle en tant que $KEYCLOAK_USER

curl --silent -X DELETE -H "Authorization: bearer $ACCESS_TOKEN" $BOOKAPI_URL/books/$BOOKID

curl --silent GET -H "Authorization: bearer $ACCESS_TOKEN" $BOOKAPI_URL/books/$BOOKID | jq

echo Nouvelle liste des livres
curl --silent $BOOKAPI_URL/books | jq