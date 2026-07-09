package com.bootcamp.bootcamp.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDate;
import java.time.LocalDateTime;

// AI가 생성한 여행 일정 결과를 DB에 저장하기 위한 Entity
@Entity

// 실제 DB 테이블 이름을 travel_plan으로 지정
@Table(name = "travel_plan")

// getter 자동 생성
@Getter

// setter 자동 생성
@Setter

// JPA에서 필요한 기본 생성자 자동 생성
@NoArgsConstructor
public class Travelplan {

    // 여행 일정 데이터의 고유 번호
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // 예산 데이터와 연결하기 위한 예산 ID
    private Long budgetId;

    // 로그인한 사용자의 ID
    private Long userId;

    // 로그인하지 않고 스킵한 게스트 사용자의 ID
    private String guestId;

    // 여행 일정 제목
    // 예: 부산 2박 3일 힐링 여행
    @Column(nullable = false)
    private String planTitle;

    // 여행 지역
    @Column(nullable = false)
    private String destination;

    // 여행 시작 날짜
    @Column(nullable = false)
    private LocalDate startDate;

    // 여행 종료 날짜
    @Column(nullable = false)
    private LocalDate endDate;

    // 총 여행 예산
    private Long totalBudget;

    // 여행 인원 수
    private Integer peopleCount;

    // 여행 스타일
    // 예: 힐링, 맛집, 관광, 액티비티
    private String styleName;

    // AI가 생성한 여행 일정 내용
    // 긴 일정 텍스트를 저장하기 위해 columnDefinition = "TEXT" 사용
    @Column(columnDefinition = "TEXT", nullable = false)
    private String planContent;

    // 데이터가 처음 생성된 시간
    private LocalDateTime createdAt;

    // 데이터가 마지막으로 수정된 시간
    private LocalDateTime updatedAt;

    // 여행 일정 객체를 직접 생성할 때 사용하는 생성자
    public Travelplan(Long budgetId, Long userId, String guestId, String planTitle, String destination,
                      LocalDate startDate, LocalDate endDate, Long totalBudget, Integer peopleCount,
                      String styleName, String planContent) {
        this.budgetId = budgetId;
        this.userId = userId;
        this.guestId = guestId;
        this.planTitle = planTitle;
        this.destination = destination;
        this.startDate = startDate;
        this.endDate = endDate;
        this.totalBudget = totalBudget;
        this.peopleCount = peopleCount;
        this.styleName = styleName;
        this.planContent = planContent;
    }

    // 여행 일정 정보를 수정할 때 사용하는 메서드
    public void updateTravelplan(String planTitle, String destination, LocalDate startDate, LocalDate endDate,
                                 Long totalBudget, Integer peopleCount, String styleName, String planContent) {
        this.planTitle = planTitle;
        this.destination = destination;
        this.startDate = startDate;
        this.endDate = endDate;
        this.totalBudget = totalBudget;
        this.peopleCount = peopleCount;
        this.styleName = styleName;
        this.planContent = planContent;
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