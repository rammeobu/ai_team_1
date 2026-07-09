package com.bootcamp.bootcamp.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDate;
import java.time.LocalDateTime;

// 여행 장소와 날짜 정보를 DB에 저장하기 위한 Entity
@Entity

// 실제 DB 테이블 이름을 travel_info로 지정
@Table(name = "travel_info")

// getter 자동 생성
@Getter

// setter 자동 생성
@Setter

// JPA에서 필요한 기본 생성자 자동 생성
@NoArgsConstructor
public class Travelinfo {

    // 여행 장소/날짜 데이터의 고유 번호
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // 예산 데이터와 연결하기 위한 예산 ID
    private Long budgetId;

    // 로그인한 사용자의 ID
    private Long userId;

    // 로그인하지 않고 스킵한 게스트 사용자의 ID
    private String guestId;

    // 사용자가 선택한 여행 지역
    @Column(nullable = false)
    private String destination;

    // 여행 시작 날짜
    @Column(nullable = false)
    private LocalDate startDate;

    // 여행 종료 날짜
    @Column(nullable = false)
    private LocalDate endDate;

    // 데이터가 처음 생성된 시간
    private LocalDateTime createdAt;

    // 데이터가 마지막으로 수정된 시간
    private LocalDateTime updatedAt;

    // 여행 장소/날짜 객체를 직접 생성할 때 사용하는 생성자
    public Travelinfo(Long budgetId, Long userId, String guestId, String destination, LocalDate startDate, LocalDate endDate) {
        this.budgetId = budgetId;
        this.userId = userId;
        this.guestId = guestId;
        this.destination = destination;
        this.startDate = startDate;
        this.endDate = endDate;
    }

    // 여행 장소/날짜 정보를 수정할 때 사용하는 메서드
    public void updateTravelinfo(String destination, LocalDate startDate, LocalDate endDate) {
        this.destination = destination;
        this.startDate = startDate;
        this.endDate = endDate;
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