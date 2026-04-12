package com.example.mcpserver.controllers;

import com.example.mcpserver.model.MCPRequest;
import com.example.mcpserver.model.MCPResponse;
import com.example.mcpserver.services.MCPService;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/mcp")
public class MCPController {

    private final MCPService mcpService;

    public MCPController(MCPService mcpService) {
        this.mcpService = mcpService;
    }

    @PostMapping
    @SuppressWarnings("unchecked")
    public MCPResponse handleRequest(@RequestBody MCPRequest request) {
        Object result = switch (request.getMethod()) {
            case "initialize" -> mcpService.getServerInfo();
            case "tools/list" -> Map.of("tools", mcpService.listTools());
            case "tools/call" -> {
                Map<String, Object> params = (Map<String, Object>) request.getParams();
                String toolName = (String) params.get("name");
                Map<String, Object> arguments =
                        (Map<String, Object>) params.get("arguments");
                yield mcpService.callTool(toolName, arguments);
            }
            default -> throw new IllegalArgumentException(
                    "Nieznana metoda: " + request.getMethod());
        };

        return new MCPResponse(result, request.getId());
    }
}
