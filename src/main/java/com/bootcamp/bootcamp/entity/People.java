package com.bootcamp.bootcamp.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Entity
@Table(name = "travel_people")
@Getter @Setter

@NoArgsConstructor
public class People {

    // 인원 데이터의 고유 번호
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // 예산 데이터와 연결하기 위한 예산 ID
    private Long budgetId;

    // 로그인한 사용자의 ID
    private Long userId;

    // 로그인하지 않고 스킵한 게스트 사용자의 ID
    private String guestId;

    // 사용자가 선택한 총 여행 인원 수
    @Column(nullable = false)
    private Integer peopleCount;

    // 인원 데이터가 처음 생성된 시간
    private LocalDateTime createdAt;

    // 인원 데이터가 마지막으로 수정된 시간
    private LocalDateTime updatedAt;

    // 인원 객체를 직접 생성할 때 사용하는 생성자
    public People(Long budgetId, Long userId, String guestId, Integer peopleCount) {
        this.budgetId = budgetId;
        this.userId = userId;
        this.guestId = guestId;
        this.peopleCount = peopleCount;
    }

    // 인원 수를 수정할 때 사용하는 메서드
    public void updatePeopleCount(Integer peopleCount) {
        this.peopleCount = peopleCount;
    }

    // DB에 처음 저장되기 직전에 실행
    @PrePersist
    public void onCreate() {
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    // DB에서 수정되기 직전에 실행
    @PreUpdate
    public void onUpdate() {
        this.updatedAt = LocalDateTime.now();
    }
}