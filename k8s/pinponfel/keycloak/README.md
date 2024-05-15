## Grafana OAUTH with Keycloak

In this tutorial I am going to show how you can connect a Grafana container that is hidden behind proxy with Keycloak. We want to log into Grafana with a Keycloak user and experience a seamless SSO-flow. Therefore we are going to configure an OAuth client for Grafana.

For this tutorial I assume that our two services are reachable from a public domain.

~~~
Keycloak: login.example.com
Grafana: monitor.example.com
~~~

Replace these domains with your case.

**Setup Keycloak**

First we are going to create a new Keycloak client. I assume Keycloak is already running and a realm has been configured.

Login into Keycloak and select *Configure > Clients > Create*. Create a new client with these configurations:

~~~
Client ID: monitor.example.com
Client Protocol: openid-connect
Root URL: https://monitor.example.com
~~~

Further make these configurations:

Access Type: `confidentials` // The OAuth client must use a client id and secret.
Root URL: `${authBaseUrl}`
Valid Redirect URIs: `https://monitor.example.com/login/generic_oauth`
Base URL: `/login/generic_oauth`
Clear `Admin URL` and `Web Origins`.

Click save and open the *Credentials* tab. Copy the*Secret* into a separate note, we will need it in the second and third part of this tutorial. Open the tab *Roles* and click *Add Role*. Create a new role with name `admin`. This role defines the access level for Grafana. Assign the client role to your Keycloak user. Header over to Scope tab and set *Full Scope Allowed* to `OFF`. We do not want to share any other details about the realm in the client token.

Finally, we are going to configure a client mapper for the roles property. We must ensure that Grafana can extract the access role from the JWT token. Open the Mappers tab and click on Create. Create an entry with these options:

Name: `Roles`
Mapper Type: `User Client Role`
Client ID: `monitor.example.com`
Token Claim Name: `roles`
Claim JSON type: `string`

In the next step we are going to verify that Grafana can retrieve a valid access token.

**Verify JWT token**

Open your shell, enter the command below ([test_jwt_token.sh](./test_jwt_token.sh)) and populate the <>-fields. Copy the client secret from the note.

~~~
KEYCLOAK_USERNAME=<Keycloak username>
KEYCLOAK_PASSWORD=<Keycloak password>
KEYCLOAK_REALM=<Keycloak realm name>
KEYCLOAK_CLIENT_SECRET=<Keycloak client secret>

curl -s \
-d "client_id=monitor.example.com" \
-d "client_secret=$KEYCLOAK_CLIENT_SECRET" \
-d "username=$KEYCLOAK_USERNAME" \
-d "password=$KEYCLOAK_PASSWORD" \
-d "grant_type=password" \
"https://login.example.com/auth/realms/$KEYCLOAK_REALM/protocol/openid-connect/token" | jq -r '.access_token'
~~~

Then copy the encoded output, open https://jwt.io#debugger-io and paste it into the left box. On the rights side you should find the decoded JSON output with this property:

~~~
"roles": [
    "admin"
],
~~~

This means the client role has been added to the JWT token and mapped correctly.

Grafana’s generic OAuth can be configured to look for this property using a JMESPath. Open this site, paste the decoded output of the JWT token and enter this filter:

~~~
contains(roles[*], 'admin') && 'Admin' || contains(roles[*], 'editor') && 'Editor' || 'Viewer'
~~~

The results box should say `Admin`.

**Grafana**

We assume that the Grafana container is running and needs to be configured for OAuth access. My first choice of configuring any container is using environment variables. Luckily all Grafana settings can be set using environment variables.

Make the following configurations for the Grafana container:

~~~
GF_SERVER_DOMAIN: "monitor.example.com"
GF_SERVER_ROOT_URL: "https://monitor.exmpale.com"
GF_AUTH_GENERIC_OAUTH_ENABLED: "true"
GF_AUTH_GENERIC_OAUTH_NAME: "Login Keycloak"
GF_AUTH_GENERIC_OAUTH_ALLOW_SIGN_UP: "true"
GF_AUTH_GENERIC_OAUTH_CLIENT_ID: "monitor.example.com"
GF_AUTH_GENERIC_OAUTH_CLIENT_SECRET: "$KEYCLOAK_CLIENT_SECRET"
GF_AUTH_GENERIC_OAUTH_SCOPES: profile
GF_AUTH_GENERIC_OAUTH_AUTH_URL: "https://login.example.com/auth/realms/example.com/protocol/openid-connect/auth"
GF_AUTH_GENERIC_OAUTH_TOKEN_URL: "https://login.example.com/auth/realms/example.com/protocol/openid-connect/token"
GF_AUTH_GENERIC_OAUTH_API_URL: "https://login.example.com/auth/realms/example.com/protocol/openid-connect/userinfo"
GF_AUTH_GENERIC_OAUTH_ROLE_ATTRIBUTE_PATH: "contains(roles[*], 'admin') && 'Admin' || contains(roles[*], 'editor') && 'Editor' || 'Viewer'"
~~~

**Test**

Once everything is deployed logout of Grafana and click on the Login Keycloak button below the login form. You will be forwarded to Keycloak. Keycloak will check the redirect url and client key of the request. If everything looks good to go, you should see the Keycloak login form. Login using the Keycloak user and password and you should be redirected back to Grafana on a successful login. Grafana will create a user if it does not already exist.

**Generate realm json**

```sh
/opt/jboss/keycloak/bin/standalone.sh \
-Djboss.socket.binding.port-offset=100 \
-Dkeycloak.migration.action=export \
-Dkeycloak.migration.provider=singleFile \
-Dkeycloak.migration.realmName=myRealm \
-Dkeycloak.migration.usersExportStrategy=REALM_FILE \
-Dkeycloak.migration.file=/tmp/myRealm.json
```

## References

[Export and Import](https://www.keycloak.org/docs/latest/server_admin/index.html#_export_import)
