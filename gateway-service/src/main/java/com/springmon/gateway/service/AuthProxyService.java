package com.springmon.gateway.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.client.RestClientException;

import java.util.Map;

@Service
public class AuthProxyService {

    @Value("${auth.service.url:http://auth-service:8081}")
    private String authServiceUrl;

    private final RestTemplate restTemplate;

    public AuthProxyService() {
        this.restTemplate = new RestTemplate();
    }

    /**
     * Proxy per login verso auth-service
     */
    public ResponseEntity<?> login(Map<String, String> credentials) {
        try {
            String url = authServiceUrl + "/api/auth/login";
            HttpEntity<Map<String, String>> request = new HttpEntity<>(credentials);
            
            return restTemplate.exchange(
                url, 
                HttpMethod.POST, 
                request, 
                Object.class
            );
        } catch (RestClientException e) {
            throw new RuntimeException("Auth service communication failed", e);
        }
    }

    /**
     * Proxy per registrazione verso auth-service
     */
    public ResponseEntity<?> register(Map<String, String> userData) {
        try {
            String url = authServiceUrl + "/api/auth/register";
            HttpEntity<Map<String, String>> request = new HttpEntity<>(userData);
            
            return restTemplate.exchange(
                url, 
                HttpMethod.POST, 
                request, 
                Object.class
            );
        } catch (RestClientException e) {
            throw new RuntimeException("Auth service communication failed", e);
        }
    }

    /**
     * Proxy per refresh token verso auth-service
     */
    public ResponseEntity<?> refreshToken(Map<String, String> refreshRequest) {
        try {
            String url = authServiceUrl + "/api/auth/refresh";
            HttpEntity<Map<String, String>> request = new HttpEntity<>(refreshRequest);
            
            return restTemplate.exchange(
                url, 
                HttpMethod.POST, 
                request, 
                Object.class
            );
        } catch (RestClientException e) {
            throw new RuntimeException("Auth service communication failed", e);
        }
    }

    /**
     * Proxy per profilo utente verso auth-service
     */
    public ResponseEntity<?> getUserProfile(String token) {
        try {
            String url = authServiceUrl + "/api/user/profile";
            
            HttpHeaders headers = new HttpHeaders();
            headers.setBearerAuth(token);
            HttpEntity<Void> request = new HttpEntity<>(headers);
            
            return restTemplate.exchange(
                url, 
                HttpMethod.GET, 
                request, 
                Object.class
            );
        } catch (RestClientException e) {
            throw new RuntimeException("Auth service communication failed", e);
        }
    }

    /**
     * Validazione token verso auth-service
     */
    public boolean validateTokenWithAuthService(String token) {
        try {
            String url = authServiceUrl + "/api/auth/validate";
            
            HttpHeaders headers = new HttpHeaders();
            headers.setBearerAuth(token);
            HttpEntity<Void> request = new HttpEntity<>(headers);
            
            ResponseEntity<?> response = restTemplate.exchange(
                url, 
                HttpMethod.POST, 
                request, 
                Object.class
            );
            
            return response.getStatusCode().is2xxSuccessful();
        } catch (RestClientException e) {
            return false;
        }
    }
}
