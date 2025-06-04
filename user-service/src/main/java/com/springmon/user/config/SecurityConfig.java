package com.springmon.user.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.Arrays;

/**
 * Configurazione Spring Security per User Service
 * Implementa autenticazione JWT stateless e protezione CSRF
 */
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public JwtAuthenticationFilter jwtAuthenticationFilter() {
        return new JwtAuthenticationFilter();
    }

    @Bean
    public JwtAuthenticationEntryPoint authenticationEntryPoint() {
        return new JwtAuthenticationEntryPoint();
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            // Disabilita CSRF per API REST stateless
            .csrf(csrf -> csrf.disable())
            
            // Configurazione CORS
            .cors(cors -> cors.configurationSource(corsConfigurationSource()))
            
            // Entry point per errori di autenticazione
            .exceptionHandling(ex -> ex.authenticationEntryPoint(authenticationEntryPoint()))
            
            // Configurazione autorizzazioni
            .authorizeHttpRequests(authz -> authz
                // Endpoint di salute pubblici
                .requestMatchers("/actuator/health").permitAll()
                .requestMatchers("/api/health").permitAll()
                
                // Tutti gli altri endpoint richiedono autenticazione JWT
                .anyRequest().authenticated()
            )
            
            // Sessioni stateless (JWT based)
            .sessionManagement(session -> session
                .sessionCreationPolicy(SessionCreationPolicy.STATELESS)
            )
            
            // Disabilita form login (non necessario per microservizi)
            .formLogin(form -> form.disable())
            
            // Disabilita HTTP Basic (usiamo JWT)
            .httpBasic(basic -> basic.disable())
            
            // Aggiungi il filtro JWT prima dell'autenticazione standard
            .addFilterBefore(jwtAuthenticationFilter(), UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        
        // Origini permesse (in produzione specificare domini esatti)
        configuration.setAllowedOriginPatterns(Arrays.asList("*"));
        
        // Metodi HTTP permessi
        configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE", "OPTIONS"));
        
        // Headers permessi
        configuration.setAllowedHeaders(Arrays.asList("*"));
        
        // Permetti credenziali
        configuration.setAllowCredentials(true);
        
        // Configura per tutti i path
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        
        return source;
    }
}
