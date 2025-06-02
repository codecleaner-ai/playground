package main

import (
	"log"
	"net/http"
	"os"
	"strings"

	"cloud.google.com/go/logging"

	// Internal packages (use the full path to the module)
	// The module name is
	// `github.com/my-app/my-service/codebase/`
	// API routes
	"github.com/my-app/my-service/codebase/routes"
	// Use the utils package for logging.
	"github.com/my-app/my-service/codebase/utils"

	// Manage API Routes
	"github.com/gorilla/mux"

	// Load environment variables from .env file
	"github.com/joho/godotenv"
)

// Global variable to track if we are in development mode.
var developmentMode bool = false

// The main function
func main() {
	// Load environment variables from the .env file
	err := godotenv.Load()
	if err != nil {
		// Prepare the error message
		errMsg := "Error loading .env file: " + err.Error()

		// Log the error message
		log.Println(errMsg)
	}

	// Set development mode flag based on the environment variable DEVELOPMENT_MODE
	// Expecting the variable to be "true" when in development mode.
	if strings.ToLower(os.Getenv("DEVELOPMENT_MODE")) == "true" {
		developmentMode = true
	}

	// Initialize the router
	router := mux.NewRouter()
	routes.SetupRoutes(router, developmentMode)

	// Get the port from the environment variables
	port := os.Getenv("PORT")
	// Default to 8080 if not set
	if port == "" {
		port = "8080"
	}

	// Log that the server is starting on the specified port.
	startMsg := "Server listening on port " + port

	// Log the message
	utils.LogMessage(logging.Info, startMsg)

	// Start the server
	err = http.ListenAndServe(":"+port, router)

	// Check if there was an error starting the server
	if err != nil {
		// Prepare the error message
		errMsg := "Failed to start server: " + err.Error()

		// Log the error message
		utils.LogMessage(logging.Error, errMsg)

		// Exit with an error code
		log.Fatal(err)
	}
}
