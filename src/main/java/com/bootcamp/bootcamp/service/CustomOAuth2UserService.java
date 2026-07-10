package com.bootcamp.bootcamp.service;

import com.bootcamp.bootcamp.dto.OAuth2UserInfo;
import com.bootcamp.bootcamp.dto.OAuth2UserInfoFactory;
import com.bootcamp.bootcamp.entity.User;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.oauth2.client.userinfo.DefaultOAuth2UserService;
import org.springframework.security.oauth2.client.userinfo.OAuth2UserRequest;
import org.springframework.security.oauth2.core.user.DefaultOAuth2User;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class CustomOAuth2UserService extends DefaultOAuth2UserService {

    private final userservice userservice;

    @Override
    public OAuth2User loadUser(OAuth2UserRequest userRequest) {

        OAuth2User oAuth2User = super.loadUser(userRequest);

        String provider = userRequest.getClientRegistration().getRegistrationId();

        // 웹 테스트용 registration(kakao-web 등)은 "-web" 접미사를 떼고 원래 provider로 처리
        String baseProvider = provider.replace("-web", "");

        OAuth2UserInfo userInfo =
                OAuth2UserInfoFactory.of(baseProvider, oAuth2User.getAttributes());

        User user = userservice.signUpLogin(userInfo);

        String roleName = (user.getRole() != null) ? user.getRole().name() : "USER";

        // attributes에 우리 DB의 userId 추가
        Map<String, Object> attributes = new HashMap<>(oAuth2User.getAttributes());
        attributes.put("userId", user.getId());

        String nameAttributeKey = userRequest.getClientRegistration()
                .getProviderDetails()
                .getUserInfoEndpoint()
                .getUserNameAttributeName();

        return new DefaultOAuth2User(
                Collections.singleton(new SimpleGrantedAuthority("ROLE_" + roleName)),
                attributes,
                nameAttributeKey
        );
    }
}