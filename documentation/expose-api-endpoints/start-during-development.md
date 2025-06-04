# Start During Development:

While developing the app, to save some $ we are not running the application 24/7.

**ALL the commands MUST be run from the `codebase/expose-api-endpoints` directory!**

## Install Dependencies:

Run the following command to install the dependencies:

```bash
go mod tidy
```

## Start The Application:

Run the following command to start the application:

```bash
go run main.go
```

You should see an output like this:

```bash
2025/06/03 23:59:07 Setting up GET route: /status
2025/06/03 23:59:07 Setting up GET route: /version
2025/06/03 23:59:07 Server listening on port 4000
```

## Next Step:

### Local Testing:

THIS IS WIP.
