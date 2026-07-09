package com.bootcamp.bootcamp.service;

import com.bootcamp.bootcamp.dto.OAuth2UserInfo;
import com.bootcamp.bootcamp.entity.Role;
import com.bootcamp.bootcamp.entity.User;
import com.bootcamp.bootcamp.repository.Userrepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;


@Service
@RequiredArgsConstructor
@Transactional
public class userservice {
    private final Userrepository userrepository;

    public User signUpLogin(OAuth2UserInfo userInfo){
        return userrepository
                .findByProviderAndProviderId(userInfo.getProvider(), userInfo.getProviderId())
                .orElseGet(()->createUser(userInfo));
    }
    private User createUser(OAuth2UserInfo userInfo){
        User user = User.builder()
                .provider(userInfo.getProvider())
                .providerId(userInfo.getProviderId())
                .email(userInfo.getEmail())
                .nickname(userInfo.getNickname())
                .role(Role.USER)                        // ← 추가
                .createdAt(LocalDateTime.now())         // 이왕이면 생성시간도
                .build();
        return userrepository.save(user);
    }
        public User updateuser (User user) {
        return userrepository.save(user);
    }
    public User getuser(Long id ){
        return userrepository.findById(id)
                .orElseThrow(()->new IllegalArgumentException("유저 없음"));
    }
    public void deleteuser (User user) {
        userrepository.delete(user);
    }


}
