package com.bootcamp.bootcamp.config;

import com.bootcamp.bootcamp.config.JwtProvider;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.oauth2.client.authentication.OAuth2AuthenticationToken;
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

        // 어떤 registration(kakao / kakao-web 등)으로 로그인했는지 확인
        String registrationId = "";
        if (authentication instanceof OAuth2AuthenticationToken oauthToken) {
            registrationId = oauthToken.getAuthorizedClientRegistrationId();
        }

        // 웹 테스트용(-web)은 커스텀 스킴을 못 받으므로 토큰을 JSON으로 바로 응답
        if (registrationId.endsWith("-web")) {
            response.setContentType("application/json;charset=UTF-8");
            response.getWriter().write("{\"token\":\"" + token + "\"}");
            return;
        }

        // 앱은 커스텀 스킴으로 리다이렉트
        String redirectUrl = "withact://login?token=" + token;
        response.sendRedirect(redirectUrl);
    }


}