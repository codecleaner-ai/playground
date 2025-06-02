package routes

import (
	"log"
	"net/http"
	"os"
)

// API Version
// Will return JSON object
// { version: "version number" }
// The version number is defined in the .env file as API_VERSION
func VersionHandler(w http.ResponseWriter, r *http.Request) {
	// Fetch the version from the environment.
	// Default to 'unknown' if not set.
	versionNumber := os.Getenv("API_VERSION")
	if versionNumber == "" {
		versionNumber = "unknown"
		log.Println("API_VERSION is not set in the environment")
	}

	// Prepare the body of the response
	response := []byte("{\"version\": \"" + versionNumber + "\"}")

	// Prepare the response
	w.Header().Set("Content-Type", "application/json")

	// Write the response
	w.Write(response)
}
