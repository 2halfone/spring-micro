package com.springmon.user.config;

import org.springframework.http.MediaType;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.AuthenticationEntryPoint;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Entry point per gestire errori di autenticazione nel User Service
 */
public class JwtAuthenticationEntryPoint implements AuthenticationEntryPoint {

    @Override
    public void commence(HttpServletRequest request,
                         HttpServletResponse response,
                         AuthenticationException authException) throws IOException, ServletException {
        
        response.setContentType(MediaType.APPLICATION_JSON_VALUE);
        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);

        String body = String.format(
            "{\"error\":\"Unauthorized\",\"message\":\"%s\",\"path\":\"%s\",\"status\":401}",
            "Authentication required to access this resource",
            request.getRequestURI()
        );

        response.getWriter().write(body);
    }
}
