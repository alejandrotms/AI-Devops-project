const express = require("express");

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware for parsing JSON request bodies
app.use(express.json());

// Basic request logging middleware
app.use((req, res, next) => {
  const start = Date.now();

  res.on("finish", () => {
    const duration = Date.now() - start;

    console.log(
      `${new Date().toISOString()} ${req.method} ${req.originalUrl} ${res.statusCode} - ${duration}ms`
    );
  });

  next();
});

// Health check endpoint
app.get("/health", (req, res) => {
  res.json({
    status: "ok",
    uptime: process.uptime(),
    timestamp: new Date().toISOString(),
  });
});

// Mock users endpoint
app.get("/users", (req, res) => {
  const users = [
    {
      id: 1,
      name: "Alice Johnson",
      email: "alice@example.com",
    },
    {
      id: 2,
      name: "Bob Smith",
      email: "bob@example.com",
    },
    {
      id: 3,
      name: "Charlie Brown",
      email: "charlie@example.com",
    },
  ];

  res.json(users);
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    error: "Route not found",
  });
});

// Start the server
app.listen(PORT, () => {
  console.log(`API server running at http://localhost:${PORT}`);
});
