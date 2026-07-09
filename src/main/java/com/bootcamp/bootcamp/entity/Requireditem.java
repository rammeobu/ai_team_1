package com.bootcamp.bootcamp.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Entity
@Table(name = "required_item")
@Getter
@Setter
@NoArgsConstructor
public class Requireditem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // 여행 일정 ID
    private Long travelplanId;

    // 예산 ID
    private Long budgetId;

    // 로그인 사용자 ID
    private Long userId;

    // 게스트 사용자 ID
    private String guestId;

    // 데이터 생성 시간
    private LocalDateTime createdAt;

    // 데이터 수정 시간
    private LocalDateTime updatedAt;

    public Requireditem(Long travelplanId, Long budgetId, Long userId, String guestId) {
        this.travelplanId = travelplanId;
        this.budgetId = budgetId;
        this.userId = userId;
        this.guestId = guestId;
    }

    public void updateRequireditem(Long travelplanId, Long budgetId, Long userId, String guestId) {
        this.travelplanId = travelplanId;
        this.budgetId = budgetId;
        this.userId = userId;
        this.guestId = guestId;
    }

    @PrePersist
    public void onCreate() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    public void onUpdate() {
        this.updatedAt = LocalDateTime.now();
    }
}