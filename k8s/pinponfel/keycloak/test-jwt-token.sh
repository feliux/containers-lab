
KEYCLOAK_USERNAME=
KEYCLOAK_PASSWORD=
KEYCLOAK_REALM=
KEYCLOAK_CLIENT_ID=
KEYCLOAK_CLIENT_SECRET=

curl -s \
-d "client_id=$KEYCLOAK_CLIENT_ID" \
-d "client_secret=$KEYCLOAK_CLIENT_SECRET" \
-d "username=$KEYCLOAK_USERNAME" \
-d "password=$KEYCLOAK_PASSWORD" \
-d "grant_type=password" \
"https://keycloak.domain.com/auth/realms/$KEYCLOAK_REALM/protocol/openid-connect/token" | jq -r '.access_token'
