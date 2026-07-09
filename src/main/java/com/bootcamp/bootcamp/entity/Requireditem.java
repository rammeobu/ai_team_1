package com.bootcamp.bootcamp.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

// 여행 필수 항목 정보를 DB에 저장하기 위한 Entity
// 항공권, 호텔, 서류, 추가 항목의 준비 상태를 저장함
@Entity
@Table(name = "required_item")
@Getter
@Setter
@NoArgsConstructor
public class Requireditem {

    // 필수 항목 데이터의 고유 번호
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // 여행 일정과 연결하기 위한 여행 일정 ID
    private Long travelplanId;

    // 예산 데이터와 연결하기 위한 예산 ID
    private Long budgetId;

    // 로그인한 사용자의 ID
    private Long userId;

    // 로그인하지 않고 스킵한 게스트 사용자의 ID
    private String guestId;

    // 필수 항목 종류
    // 예: FLIGHT, HOTEL, DOCUMENT, EXTRA
    @Column(nullable = false)
    private String itemType;

    // 화면에 보여줄 항목 이름
    // 예: 항공권, 호텔, 서류, 추가
    @Column(nullable = false)
    private String itemName;

    // 항목 준비 상태
    // 예: NOT_STARTED, SEARCHED, SELECTED, COMPLETED
    private String itemStatus;

    // 외부 API 제공자
    // 예: Google, Agoda, Skyscanner, 공공데이터포털
    private String externalProvider;

    // 외부 API에서 받은 결과 ID
    // 예: 호텔 ID, 항공권 ID, 서류 정보 ID
    private String externalItemId;

    // 외부 API 결과 요약
    // 예: 대한항공 인천-도쿄 왕복 ₩300,000
    @Column(columnDefinition = "TEXT")
    private String itemSummary;

    // 외부 API 상세 페이지 또는 예약 페이지 URL
    private String externalUrl;

    // 사용자가 이 항목을 선택했는지 여부
    private Boolean selected;

    // 데이터가 처음 생성된 시간
    private LocalDateTime createdAt;

    // 데이터가 마지막으로 수정된 시간
    private LocalDateTime updatedAt;

    // 필수 항목 객체를 직접 생성할 때 사용하는 생성자
    public Requireditem(Long travelplanId, Long budgetId, Long userId, String guestId,
                        String itemType, String itemName, String itemStatus,
                        String externalProvider, String externalItemId,
                        String itemSummary, String externalUrl, Boolean selected) {
        this.travelplanId = travelplanId;
        this.budgetId = budgetId;
        this.userId = userId;
        this.guestId = guestId;
        this.itemType = itemType;
        this.itemName = itemName;
        this.itemStatus = itemStatus;
        this.externalProvider = externalProvider;
        this.externalItemId = externalItemId;
        this.itemSummary = itemSummary;
        this.externalUrl = externalUrl;
        this.selected = selected;
    }

    // 필수 항목 정보를 수정할 때 사용하는 메서드
    public void updateRequireditem(String itemType, String itemName, String itemStatus,
                                   String externalProvider, String externalItemId,
                                   String itemSummary, String externalUrl, Boolean selected) {
        this.itemType = itemType;
        this.itemName = itemName;
        this.itemStatus = itemStatus;
        this.externalProvider = externalProvider;
        this.externalItemId = externalItemId;
        this.itemSummary = itemSummary;
        this.externalUrl = externalUrl;
        this.selected = selected;
    }

    // DB에 처음 저장되기 직전에 실행
    @PrePersist
    public void onCreate() {
        if (this.selected == null) {
            this.selected = false;
        }

        if (this.itemStatus == null) {
            this.itemStatus = "NOT_STARTED";
        }

        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    // DB에서 수정되기 직전에 실행
    @PreUpdate
    public void onUpdate() {
        this.updatedAt = LocalDateTime.now();
    }
}