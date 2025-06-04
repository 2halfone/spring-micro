package com.springmon.auth.service;

import com.springmon.auth.dto.AuthResponse;
import com.springmon.auth.dto.LoginRequest;
import com.springmon.auth.dto.RegisterRequest;
import com.springmon.auth.entity.RefreshToken;
import com.springmon.auth.entity.Role;
import com.springmon.auth.entity.User;
import com.springmon.auth.repository.RefreshTokenRepository;
import com.springmon.auth.repository.RoleRepository;
import com.springmon.auth.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Optional;
import java.util.Set;

@Service
@Transactional
public class AuthService {

    @Autowired
    private AuthenticationManager authenticationManager;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private RoleRepository roleRepository;

    @Autowired
    private RefreshTokenRepository refreshTokenRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JwtTokenProvider tokenProvider;

    public AuthResponse authenticateUser(LoginRequest loginRequest) {
        Authentication authentication = authenticationManager.authenticate(
            new UsernamePasswordAuthenticationToken(
                loginRequest.getUsername(),
                loginRequest.getPassword()
            )
        );

        SecurityContextHolder.getContext().setAuthentication(authentication);

        String jwt = tokenProvider.generateToken(authentication);
        String refreshToken = tokenProvider.generateRefreshToken(authentication.getName());

        // Save refresh token
        saveRefreshToken(authentication.getName(), refreshToken);

        // Update last login
        updateLastLogin(authentication.getName());

        User user = userRepository.findByUsername(authentication.getName())
                .orElseThrow(() -> new RuntimeException("User not found"));

        return new AuthResponse(
            jwt,
            refreshToken,
            tokenProvider.getJwtExpirationInMs(),
            user.getUsername(),
            user.getEmail()
        );
    }

    public AuthResponse registerUser(RegisterRequest registerRequest) {
        // Check if username exists
        if (userRepository.existsByUsername(registerRequest.getUsername())) {
            throw new RuntimeException("Username is already taken!");
        }

        // Check if email exists
        if (userRepository.existsByEmail(registerRequest.getEmail())) {
            throw new RuntimeException("Email is already in use!");
        }

        // Create new user
        User user = new User(
            registerRequest.getUsername(),
            registerRequest.getEmail(),
            passwordEncoder.encode(registerRequest.getPassword())
        );

        // Set default role
        Role userRole = roleRepository.findByName("ROLE_USER")
                .orElseGet(() -> {
                    Role role = new Role("ROLE_USER", "Default user role");
                    return roleRepository.save(role);
                });

        Set<Role> roles = new HashSet<>();
        roles.add(userRole);
        user.setRoles(roles);

        User savedUser = userRepository.save(user);

        // Generate tokens
        String jwt = tokenProvider.generateTokenFromUsername(savedUser.getUsername());
        String refreshToken = tokenProvider.generateRefreshToken(savedUser.getUsername());

        // Save refresh token
        saveRefreshToken(savedUser.getUsername(), refreshToken);

        return new AuthResponse(
            jwt,
            refreshToken,
            tokenProvider.getJwtExpirationInMs(),
            savedUser.getUsername(),
            savedUser.getEmail()
        );
    }

    public AuthResponse refreshToken(String refreshTokenValue) {
        RefreshToken refreshToken = refreshTokenRepository.findByToken(refreshTokenValue)
                .orElseThrow(() -> new RuntimeException("Refresh token not found"));

        if (refreshToken.getExpiryDate().isBefore(LocalDateTime.now())) {
            refreshTokenRepository.delete(refreshToken);
            throw new RuntimeException("Refresh token has expired");
        }

        User user = refreshToken.getUser();
        String newAccessToken = tokenProvider.generateTokenFromUsername(user.getUsername());
        String newRefreshToken = tokenProvider.generateRefreshToken(user.getUsername());

        // Update refresh token
        refreshToken.setToken(newRefreshToken);
        refreshToken.setExpiryDate(LocalDateTime.now().plusSeconds(tokenProvider.getRefreshTokenExpirationInMs() / 1000));
        refreshTokenRepository.save(refreshToken);

        return new AuthResponse(
            newAccessToken,
            newRefreshToken,
            tokenProvider.getJwtExpirationInMs(),
            user.getUsername(),
            user.getEmail()
        );
    }

    public void logout(String username) {
        refreshTokenRepository.deleteByUser_Username(username);
    }

    private void saveRefreshToken(String username, String token) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found"));

        // Delete existing refresh tokens for this user
        refreshTokenRepository.deleteByUser(user);

        // Create new refresh token
        RefreshToken refreshToken = new RefreshToken();
        refreshToken.setToken(token);
        refreshToken.setUser(user);
        refreshToken.setExpiryDate(LocalDateTime.now().plusSeconds(tokenProvider.getRefreshTokenExpirationInMs() / 1000));

        refreshTokenRepository.save(refreshToken);
    }

    private void updateLastLogin(String username) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        user.setLastLogin(LocalDateTime.now());
        userRepository.save(user);
    }

    public boolean validateToken(String token) {
        return tokenProvider.validateToken(token);
    }

    public String getUsernameFromToken(String token) {
        return tokenProvider.getUsernameFromToken(token);
    }
}
