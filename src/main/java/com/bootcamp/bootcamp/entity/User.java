package com.bootcamp.bootcamp.entity;

import com.bootcamp.bootcamp.dto.Provider;
import jakarta.persistence.*;
import jakarta.validation.constraints.Email;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@AllArgsConstructor
@NoArgsConstructor
@Table(name = "users")
@Getter @Setter
//카카오톡 api 받아올수 있는 : 닉네임, 프로필사진, 이메일
@Builder
public class User {
    @Id  @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;                    //내부 PK

    @Enumerated(EnumType.STRING)
    private Provider provider;    //KAKAO, GOOGLE ...
    private String providerId;    //카카오 주는 고유 id(회원번호)

    @Email
    private String email;//동의항목이면 받음(없을 수 있음)

    private String nickname;
    private String profileImageUrl;
    @Column(nullable = true)
    private String password;

    @Enumerated(EnumType.STRING)
    private Role role;    //USER, ADMIN

    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    @PrePersist
    public void prePersist() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    public void preUpdate() {
        this.updatedAt = LocalDateTime.now();
    }

}