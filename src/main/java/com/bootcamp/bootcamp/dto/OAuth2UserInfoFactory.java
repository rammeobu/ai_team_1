package com.bootcamp.bootcamp.dto;

import java.util.Map;

public class OAuth2UserInfoFactory {
    public static OAuth2UserInfo of(String provider, Map<String, Object> attributes) {
        return switch (provider.toLowerCase()) {
            case "kakao"  -> new KakaoUserInfo(attributes);
            case "google" -> new GoogleUserInfo(attributes);
            default -> throw new IllegalArgumentException("지원 안 함");
        };
    }
}