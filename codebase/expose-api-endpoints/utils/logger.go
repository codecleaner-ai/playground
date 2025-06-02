package utils

import (
	"log"
	"os"

	"cloud.google.com/go/logging"
)

// DevelopmentMode indicates whether the application is running in development mode.
var DevelopmentMode bool = false

// LogMessage writes the log message to the standard logger
func LogMessage(severity logging.Severity, msg string) {
	// Print the message to the standard logger.
	log.Println(msg)

	// If in development mode, skip logging to GCP Cloud Logger.
	if DevelopmentMode {
		return
	}
}

// LogDebug Message writes a debug message to the standard logger
// This loge messages ONLY if
//   - The environment parameter `DEBUG_MODE` is set to true.
func LogDebug(
	severity logging.Severity,
	msg string,
	developmentMode bool,
) {
	// If the DEBUG_MODE environment variable is not set, skip logging debug messages.
	if os.Getenv("DEBUG_MODE") != "true" {
		return
	}

	// Print the message to the standard logger.
	log.Println(msg)

	// If in development mode, skip logging to GCP Cloud Logger.
	if DevelopmentMode {
		return
	}
}
