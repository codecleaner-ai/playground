# The Token Sever:

Because 

- The code is running on [GCP Cloud Run](../../infrastructure/gcp/cloud-run/README.md).
- The [Cloud Run service is NOT public](../../functionalities/security/authorized-access-to-cloud-run.md).

We need to make sure that Postman has a valid GCP token to access the service.

This is done using the [pre-request scripts](./pre-request-scripts.md).

Because of postman limitations, the best way to get a token is to use the `gcloud` command line tool.

BUT because of Postman limitations we CANNOT use the `gcloud` command line tool directly.

To work around this limitation, we have done the following:

- [Create file `get_gcloud_token.sh` in the "Home" folder of your development machine](./create-get-gcloud-token-utility.md).
- Create a super simple [get token server](./token-server.js) that will return the token.

## What This Does:

Exposes an endpoint that will return the GCP token of the user that is currently logged in to GCP.

To log to GCP, the user must run

```bash
gcloud auth login
```

## How To Use It:

- Run the server:

```bash
node gcp-token-server.js
```

- Get the token:

```bash
curl -X GET http://localhost:3030
```