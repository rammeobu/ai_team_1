package com.bootcamp.bootcamp.config;

import com.bootcamp.bootcamp.config.JwtProvider;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.security.web.authentication.SimpleUrlAuthenticationSuccessHandler;
import org.springframework.stereotype.Component;

import java.io.IOException;

@Component
@RequiredArgsConstructor
public class OAuth2SuccessHandler extends SimpleUrlAuthenticationSuccessHandler {

    private final JwtProvider jwtProvider;

    @Override
    public void onAuthenticationSuccess(HttpServletRequest request,
                                        HttpServletResponse response,
                                        Authentication authentication) throws IOException {

        System.out.println(">>>>> 성공핸들러 실행됨!!!");

        OAuth2User oAuth2User = (OAuth2User) authentication.getPrincipal();

        String role = authentication.getAuthorities().iterator().next()
                .getAuthority().replace("ROLE_", "");

        Long userId = ((Number) oAuth2User.getAttributes().get("userId")).longValue();

        String token = jwtProvider.createToken(userId, role);

        String redirectUrl = "withact://login?token=" + token;
        response.sendRedirect(redirectUrl);
    }


}