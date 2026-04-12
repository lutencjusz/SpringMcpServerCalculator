package com.example.mcpserver.model;

import lombok.Data;

@Data
public class MCPResponse {
    private final String jsonrpc = "2.0";
    private Object result;
    private String id;

    public MCPResponse(Object result, String id) {
        this.result = result;
        this.id = id;
    }

    public String getJsonrpc() {
        return jsonrpc;
    }

    public Object getResult() {
        return result;
    }

    public void setResult(Object result) {
        this.result = result;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }
}