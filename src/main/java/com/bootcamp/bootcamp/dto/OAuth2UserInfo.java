package com.bootcamp.bootcamp.dto;


public interface OAuth2UserInfo {
    Provider getProvider();
    String getProviderId();
    String getEmail();
    String getNickname();
}