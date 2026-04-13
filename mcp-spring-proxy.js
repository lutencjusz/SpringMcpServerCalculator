#!/usr/bin/env node
/**
 * MCP STDIO Proxy for Spring MCP Server
 * Converts STDIO (JSON-RPC) to HTTP requests to localhost:8080/mcp
 */

const http = require('http');
const readline = require('readline');

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
  terminal: false
});

function sendRequest(requestBody) {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'localhost',
      port: 8080,
      path: '/mcp',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(requestBody)
      }
    };

    const req = http.request(options, (res) => {
      let data = '';

      res.on('data', (chunk) => {
        data += chunk;
      });

      res.on('end', () => {
        try {
          const response = JSON.parse(data);
          resolve(response);
        } catch (e) {
          reject(new Error(`Invalid JSON response: ${data}`));
        }
      });
    });

    req.on('error', (e) => {
      reject(e);
    });

    req.write(requestBody);
    req.end();
  });
}

rl.on('line', async (line) => {
  try {
    const request = JSON.parse(line);
    const response = await sendRequest(JSON.stringify(request));
    console.log(JSON.stringify(response));
  } catch (error) {
    console.log(JSON.stringify({
      jsonrpc: '2.0',
      error: {
        code: -32700,
        message: error.message
      },
      id: null
    }));
  }
});

rl.on('close', () => {
  process.exit(0);
});

