package com.bootcamp.bootcamp.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

// 항공권, 호텔, 서류, 추가 아이콘별 상세 정보를 저장하는 Entity
@Entity
@Table(name = "required_item_detail")
@Getter
@Setter
@NoArgsConstructor
public class Requireditemdetail {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // Requireditem의 id
    // 같은 여행의 항공권, 호텔, 서류, 추가 항목은 같은 requireditemId를 가짐
    private Long requireditemId;

    // 여행 일정 ID
    private Long travelplanId;

    // 예산 ID
    private Long budgetId;

    // 로그인 사용자 ID
    private Long userId;

    // 게스트 사용자 ID
    private String guestId;

    // 아이콘 종류
    // 예: FLIGHT, HOTEL, DOCUMENT, EXTRA
    @Column(nullable = false)
    private String itemType;

    // 아이콘 버전
    // 예: 같은 HOTEL이라도 1번 추천, 2번 추천처럼 구분할 때 사용
    private Integer itemVersion;

    // 화면에 보여줄 이름
    // 예: 항공권, 호텔, 서류, 추가
    @Column(nullable = false)
    private String itemName;

    // 준비 상태
    // 예: NOT_STARTED, SEARCHED, SELECTED, COMPLETED
    private String itemStatus;

    // 외부 API 제공자
    // 예: Agoda, Google, Flight API, Document API
    private String externalProvider;

    // 외부 API에서 받은 결과 ID
    private String externalItemId;

    // 외부 API 결과 요약
    @Column(columnDefinition = "TEXT")
    private String itemSummary;

    // 외부 API 상세 페이지 또는 예약 페이지 URL
    private String externalUrl;

    // 사용자가 선택했는지 여부
    private Boolean selected;

    // 데이터 생성 시간
    private LocalDateTime createdAt;

    // 데이터 수정 시간
    private LocalDateTime updatedAt;

    public Requireditemdetail(Long requireditemId, Long travelplanId, Long budgetId,
                              Long userId, String guestId,
                              String itemType, Integer itemVersion, String itemName,
                              String itemStatus, String externalProvider,
                              String externalItemId, String itemSummary,
                              String externalUrl, Boolean selected) {
        this.requireditemId = requireditemId;
        this.travelplanId = travelplanId;
        this.budgetId = budgetId;
        this.userId = userId;
        this.guestId = guestId;
        this.itemType = itemType;
        this.itemVersion = itemVersion;
        this.itemName = itemName;
        this.itemStatus = itemStatus;
        this.externalProvider = externalProvider;
        this.externalItemId = externalItemId;
        this.itemSummary = itemSummary;
        this.externalUrl = externalUrl;
        this.selected = selected;
    }

    public void updateRequireditemdetail(String itemType, Integer itemVersion, String itemName,
                                         String itemStatus, String externalProvider,
                                         String externalItemId, String itemSummary,
                                         String externalUrl, Boolean selected) {
        this.itemType = itemType;
        this.itemVersion = itemVersion;
        this.itemName = itemName;
        this.itemStatus = itemStatus;
        this.externalProvider = externalProvider;
        this.externalItemId = externalItemId;
        this.itemSummary = itemSummary;
        this.externalUrl = externalUrl;
        this.selected = selected;
    }

    @PrePersist
    public void onCreate() {
        if (this.itemVersion == null) {
            this.itemVersion = 1;
        }

        if (this.itemStatus == null) {
            this.itemStatus = "NOT_STARTED";
        }

        if (this.selected == null) {
            this.selected = false;
        }

        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    public void onUpdate() {
        this.updatedAt = LocalDateTime.now();
    }
}