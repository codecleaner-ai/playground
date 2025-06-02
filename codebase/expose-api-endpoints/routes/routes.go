package routes

import (
	"log"
	"net/http"
	"os"
	"strings"

	"cloud.google.com/go/logging"
	"github.com/my-app/my-service/codebase/utils"

	"github.com/gorilla/mux"
)

// `requireReadApiKey` is a middleware that protects endpoints with an API key.
// It reads the expected API key from the environment variables
//   - "AUTHORIZED_R_API_KEY": the API key for read-only access
//   - "AUTHORIZED_RW_API_KEY": the API key for read-write access
//
// and compares it with the incoming request's API key.
// The incoming request must have the header "X-API-Key" set to the expected value.
func requireReadApiKey(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Read the API key from the request header and trim any whitespace.
		apiKey := strings.TrimSpace(r.Header.Get("X-API-Key"))
		// Fetch the expected API key from the environment and trim any whitespace.
		expectedReadKey := strings.TrimSpace(os.Getenv("AUTHORIZED_R_API_KEY"))
		expectedReadWriteKey := strings.TrimSpace(os.Getenv("AUTHORIZED_RW_API_KEY"))

		// Check if the expected API keys are not set in the environment.
		if expectedReadKey == "" || expectedReadWriteKey == "" {
			// Prepare the error message
			errMsg := "The API keys to grant access are not set in the environment"

			// Log the error message
			utils.LogMessage(logging.Warning, errMsg)
			http.Error(w, "Internal Server Error", http.StatusInternalServerError)
			return
		}
		// Compare the provided API key with the expected API key.
		if apiKey != expectedReadKey && apiKey != expectedReadWriteKey {
			// prepare the error message
			errMsg := "Unauthorized access: the provided API Key is incorrect"
			// Log the error message
			utils.LogMessage(
				logging.Warning,
				errMsg,
			)

			// Return an unauthorized error to the client.
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}
		// If the API key matches, proceed with the request.
		next.ServeHTTP(w, r)
	})
}

// Log function for debugging
// Only if the DEBUG_MODE environment variable is set to true
func logRequest(next http.Handler) http.Handler {
	// If the DEBUG_MODE environment variable is not set, skip logging debug messages.
	if os.Getenv("DEBUG_MODE") != "true" {
		return next
	}

	// Return a new handler function that logs the request and then calls the next handler.
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Log the incoming request
		log.Printf(
			"Incoming request: %s %s",
			r.Method,
			r.URL.Path,
		)
		// Call the next handler in the chain.
		next.ServeHTTP(w, r)
	})
}

// Handler for the routes
func SetupRoutes(
	router *mux.Router,
	developmentMode bool,
) {
	// Enable StrictSlash to automatically redirect trailing slash variants.
	router.StrictSlash(true)

	// `/status` endpoint
	// Log the setup of the route
	utils.LogDebug(
		logging.Info,
		"Setting up GET route: /status",
		developmentMode,
	)
	// The handler for the `/status` endpoint
	router.HandleFunc(
		"/status",
		StatusHandler,
	).Methods("GET")

	// `/version` endpoint
	// Require API key to access this endpoint
	// Log the setup of the route
	utils.LogDebug(
		logging.Info,
		"Setting up GET route: /version",
		developmentMode,
	)
	// The handler for the `/version` endpoint
	router.Handle(
		"/version",
		logRequest(
			requireReadApiKey(
				http.HandlerFunc(VersionHandler),
			),
		),
	).Methods("GET")

	// `/connection-check` endpoint (protected with API key)
	// Require API key to access this endpoint
	// Log the setup of the route
	utils.LogDebug(
		logging.Info,
		"Setting up GET route: /connection-check",
		developmentMode,
	)
}
