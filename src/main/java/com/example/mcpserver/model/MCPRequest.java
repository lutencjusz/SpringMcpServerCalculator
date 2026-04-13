package com.example.mcpserver.model;

import lombok.Data;

@Data
public class MCPRequest {
    private String jsonrpc = "2.0";
    private String method;
    private Object params;
    private String id;
}
