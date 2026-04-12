package com.example.mcpserver.services;

import com.example.mcpserver.tools.MCPTool;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class MCPService {

    private final List<MCPTool> tools;

    public MCPService(List<MCPTool> tools) {
        this.tools = tools;
    }

    public List<Map<String, Object>> listTools() {
        return tools.stream()
                .map(tool -> Map.of(
                        "name", tool.getName(),
                        "description", tool.getDescription(),
                        "inputSchema", tool.getInputSchema()
                ))
                .collect(Collectors.toList());
    }

    public Object callTool(String toolName, Map<String, Object> arguments) {
        MCPTool tool = tools.stream()
                .filter(t -> t.getName().equals(toolName))
                .findFirst()
                .orElseThrow(() -> new IllegalArgumentException(
                        "Narzędzie nie znalezione: " + toolName));

        return tool.execute(arguments);
    }

    public Map<String, Object> getServerInfo() {
        return Map.of(
                "name", "Spring Boot MCP Server",
                "version", "1.0.0",
                "protocolVersion", "2024-11-05"
        );
    }
}
