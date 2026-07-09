package com.bootcamp.bootcamp.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "travel_dashboard")
@Getter @Setter

@NoArgsConstructor
public class Dashboard {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // 예산 데이터와 연결하기 위한 예산 ID
    private Long budgetId;

    // 여행 일정 데이터와 연결하기 위한 여행 일정 ID

    private Long travelplanId;

    // 로그인한 사용자의 ID
    private Long userId;

    // 로그인 스킵한 게스트 사용자의 ID
    private String guestId;

    // 대시보드 제목
    // 예: 부산 2박 3일 힐링 여행
    @Column(nullable = false)
    private String dashboardTitle;

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

    // 사용한 예산
    private Long usedBudget;

    // 남은 예산
    private Long remainingBudget;

    // 여행 인원 수
    private Integer peopleCount;

    // 여행 스타일
    private String styleName;

    // 홈 화면에 보여줄 간단한 일정 요약
    @Column(columnDefinition = "TEXT")
    private String planSummary;

    // 데이터가 처음 생성된 시간
    private LocalDateTime createdAt;

    // 데이터가 마지막으로 수정된 시간
    private LocalDateTime updatedAt;

    // 대시보드 객체를 직접 생성할 때 사용하는 생성자
    public Dashboard(Long budgetId, Long travelplanId, Long userId, String guestId,
                     String dashboardTitle, String destination, LocalDate startDate, LocalDate endDate,
                     Long totalBudget, Long usedBudget, Long remainingBudget,
                     Integer peopleCount, String styleName, String planSummary) {
        this.budgetId = budgetId;
        this.travelplanId = travelplanId;
        this.userId = userId;
        this.guestId = guestId;
        this.dashboardTitle = dashboardTitle;
        this.destination = destination;
        this.startDate = startDate;
        this.endDate = endDate;
        this.totalBudget = totalBudget;
        this.usedBudget = usedBudget;
        this.remainingBudget = remainingBudget;
        this.peopleCount = peopleCount;
        this.styleName = styleName;
        this.planSummary = planSummary;
    }

    // 대시보드 정보를 수정할 때 사용하는 메서드
    public void updateDashboard(String dashboardTitle, String destination, LocalDate startDate, LocalDate endDate,
                                Long totalBudget, Long usedBudget, Long remainingBudget,
                                Integer peopleCount, String styleName, String planSummary) {
        this.dashboardTitle = dashboardTitle;
        this.destination = destination;
        this.startDate = startDate;
        this.endDate = endDate;
        this.totalBudget = totalBudget;
        this.usedBudget = usedBudget;
        this.remainingBudget = remainingBudget;
        this.peopleCount = peopleCount;
        this.styleName = styleName;
        this.planSummary = planSummary;
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