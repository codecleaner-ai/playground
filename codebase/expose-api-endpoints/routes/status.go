package routes

import (
	"net/http"
)

// API Status
// It will simply return a string with the message "API is up and running"
func StatusHandler(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("API is up and running"))
}
