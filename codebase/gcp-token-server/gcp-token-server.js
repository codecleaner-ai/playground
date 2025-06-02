const http = require("http");
const { execSync } = require("child_process");

const server = http.createServer((req, res) => {
  try {
    const token = execSync("gcloud auth print-identity-token")
      .toString()
      .trim();
    res.writeHead(200, { "Content-Type": "text/plain" });
    res.end(token);
  } catch (error) {
    console.error(error);
    res.writeHead(500, { "Content-Type": "text/plain" });
    res.end("Error retrieving token");
  }
});

const port = 3030; // Choose a port
server.listen(port, () => {
  console.log(`Token server listening on port ${port}`);
});
