package com.bootcamp.bootcamp.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Entity
@Table(name = "travel_budget")
@Getter
@Setter
@NoArgsConstructor
public class Budget {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    //로그인한 사용자
    private Long userId;

    //로그인하지 않은 사용자
    //ex) guest-랜덤문자열
    private String guestId;

    //사용자가 입력한 총 여행 예산
    @Column(nullable = false)
    private Long totalBudget;

    //예산 데이터가 처음 생성된 시간
    private LocalDateTime createdAt;

    //예산 데이터가 마지막으로 수정된 시간
    private LocalDateTime updatedAt;

    //예산 객체를 생성
    public Budget(Long userId, String guestId, Long totalBudget) {
        this.userId = userId;
        this.guestId = guestId;
        this.totalBudget = totalBudget;
    }

    //예산 금액 수정
    public void updateBudget(Long totalBudget) {
        this.totalBudget = totalBudget;
    }

    //entity가 db에 처음 저장되기 직전에 자동 실행
    //생성 시간과 수정 시간을 현재 시간으로 초기화
    @PrePersist
    public void onCreate() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    //entity가 db에서 수정되기 직전에 자동 실행되는 메서드
    //수정시간만 현재 시간으로 변경
    @PreUpdate
    public void onUpdate() {
        this.updatedAt = LocalDateTime.now();
    }
}