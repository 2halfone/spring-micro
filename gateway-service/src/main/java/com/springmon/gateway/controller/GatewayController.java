package com.springmon.gateway.controller;

import com.springmon.gateway.service.AuthProxyService;
import com.springmon.gateway.service.JwtValidationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpServletRequest;
import java.util.Map;

@RestController
@RequestMapping("/api")
public class GatewayController {

    @Autowired
    private AuthProxyService authProxyService;
    
    @Autowired
    private JwtValidationService jwtValidationService;

    /**
     * ENDPOINT PUBBLICO - Login (proxy verso auth-service)
     */
    @PostMapping("/auth/login")
    public ResponseEntity<?> login(@RequestBody Map<String, String> credentials) {
        try {
            return authProxyService.login(credentials);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Authentication service unavailable"));
        }
    }

    /**
     * ENDPOINT PUBBLICO - Registrazione (proxy verso auth-service)
     */
    @PostMapping("/auth/register")
    public ResponseEntity<?> register(@RequestBody Map<String, String> userData) {
        try {
            return authProxyService.register(userData);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Registration service unavailable"));
        }
    }

    /**
     * ENDPOINT PUBBLICO - Refresh token (proxy verso auth-service)
     */
    @PostMapping("/auth/refresh")
    public ResponseEntity<?> refreshToken(@RequestBody Map<String, String> refreshRequest) {
        try {
            return authProxyService.refreshToken(refreshRequest);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Token refresh service unavailable"));
        }
    }

    /**
     * ENDPOINT PROTETTO - Informazioni utente
     */
    @GetMapping("/user/profile")
    public ResponseEntity<?> getUserProfile(HttpServletRequest request) {
        String token = extractTokenFromRequest(request);
        if (token == null || !jwtValidationService.validateToken(token)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("error", "Invalid or missing token"));
        }
        
        try {
            return authProxyService.getUserProfile(token);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Profile service unavailable"));
        }
    }

    /**
     * ENDPOINT PROTETTO - SpringMon Application Data
     */
    @GetMapping("/springmon/data")
    public ResponseEntity<?> getSpringMonData(HttpServletRequest request) {
        String token = extractTokenFromRequest(request);
        if (token == null || !jwtValidationService.validateToken(token)) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("error", "Access denied"));
        }

        // Simulazione dati SpringMon (in futuro da servizio dedicato)
        return ResponseEntity.ok(Map.of(
            "message", "SpringMon Microservices Architecture",
            "version", "1.0.0-SNAPSHOT",
            "status", "Secure Gateway Active",
            "timestamp", System.currentTimeMillis()
        ));
    }

    /**
     * ENDPOINT PUBBLICO - Health check
     */
    @GetMapping("/health")
    public ResponseEntity<?> healthCheck() {
        return ResponseEntity.ok(Map.of(
            "status", "UP",
            "service", "SpringMon Gateway",
            "timestamp", System.currentTimeMillis()
        ));
    }

    /**
     * ENDPOINT PUBBLICO - Info applicazione
     */
    @GetMapping("/info")
    public ResponseEntity<?> getInfo() {
        return ResponseEntity.ok(Map.of(
            "application", "SpringMon Microservices",
            "gateway", "Secure API Gateway",
            "version", "1.0.0-SNAPSHOT",
            "description", "Single external entry point for SpringMon services"
        ));
    }

    /**
     * Estrazione token JWT dall'header Authorization
     */
    private String extractTokenFromRequest(HttpServletRequest request) {
        String bearerToken = request.getHeader("Authorization");
        if (bearerToken != null && bearerToken.startsWith("Bearer ")) {
            return bearerToken.substring(7);
        }
        return null;
    }
}
