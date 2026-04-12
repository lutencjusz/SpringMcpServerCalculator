package com.example.mcpserver.tools;

import java.util.Map;

public interface MCPTool {
    String getName();
    String getDescription();
    Map<String, Object> getInputSchema();
    Object execute(Map<String, Object> arguments);
}
