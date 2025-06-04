package com.springmon.gateway.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.Arrays;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            // Disabilita CSRF per API REST
            .csrf(csrf -> csrf.disable())
            
            // Configurazione CORS
            .cors(cors -> cors.configurationSource(corsConfigurationSource()))
            
            // Configurazione autorizzazioni
            .authorizeHttpRequests(authz -> authz
                // Endpoint pubblici
                .requestMatchers("/api/auth/**").permitAll()
                .requestMatchers("/api/health").permitAll()
                .requestMatchers("/api/info").permitAll()
                .requestMatchers("/actuator/health").permitAll()
                
                // Tutti gli altri endpoint richiedono autenticazione
                .anyRequest().authenticated()
            )
            
            // Sessioni stateless (JWT)
            .sessionManagement(session -> session
                .sessionCreationPolicy(SessionCreationPolicy.STATELESS)
            )
            
            // Disabilita form login
            .formLogin(form -> form.disable())
            
            // Disabilita HTTP Basic
            .httpBasic(basic -> basic.disable());

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
