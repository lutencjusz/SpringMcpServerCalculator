package com.example.mcpserver.tools;


import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Map;

@Component
public class CalculatorTool implements MCPTool {

    @Override
    public String getName() {
        return "calculator";
    }

    @Override
    public String getDescription() {
        return "Oblicza sumę podanych liczb";
    }

    @Override
    public Map<String, Object> getInputSchema() {
        return Map.of(
                "type", "object",
                "properties", Map.of(
                        "numbers", Map.of(
                                "type", "array",
                                "items", Map.of("type", "number"),
                                "description", "Lista liczb do zsumowania"
                        )
                ),
                "required", List.of("numbers")
        );
    }

    @Override
    @SuppressWarnings("unchecked")
    public Object execute(Map<String, Object> arguments) {
        List<Number> numbers = (List<Number>) arguments.get("numbers");
        double sum = numbers.stream()
                .mapToDouble(Number::doubleValue)
                .sum();
        return Map.of("result", sum);
    }
}
