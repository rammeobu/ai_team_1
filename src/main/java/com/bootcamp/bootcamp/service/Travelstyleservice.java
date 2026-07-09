package com.bootcamp.bootcamp.service;

import com.bootcamp.bootcamp.entity.Travelstyle;
import com.bootcamp.bootcamp.repository.Travelstylerepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

// 여행 스타일 관련 기능을 처리하는 Service
@Service

// final 필드를 생성자로 자동 주입
@RequiredArgsConstructor

// 기본적으로 조회용 트랜잭션 설정
@Transactional(readOnly = true)
public class Travelstyleservice {

    // 여행 스타일 데이터를 DB에 저장, 조회, 삭제하기 위한 Repository
    private final Travelstylerepository travelstyleRepository;

    // 여행 스타일 정보를 새로 저장하는 메서드
    @Transactional
    public Travelstyle createTravelstyle(Travelstyle travelstyleData) {
        return travelstyleRepository.save(travelstyleData);
    }

    // 모든 여행 스타일 정보를 조회하는 메서드
    public List<Travelstyle> getAllTravelstyle() {
        return travelstyleRepository.findAll();
    }

    // id를 기준으로 여행 스타일 정보 하나를 조회하는 메서드
    public Travelstyle getTravelstyle(Long id) {
        return travelstyleRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("해당 여행 스타일 정보가 없습니다."));
    }

    // budgetId를 기준으로 여행 스타일 정보를 조회하는 메서드
    public List<Travelstyle> getTravelstyleByBudgetId(Long budgetId) {
        return travelstyleRepository.findByBudgetId(budgetId);
    }

    // userId를 기준으로 여행 스타일 정보를 조회하는 메서드
    public List<Travelstyle> getTravelstyleByUserId(Long userId) {
        return travelstyleRepository.findByUserId(userId);
    }

    // guestId를 기준으로 여행 스타일 정보를 조회하는 메서드
    public List<Travelstyle> getTravelstyleByGuestId(String guestId) {
        return travelstyleRepository.findByGuestId(guestId);
    }

    // styleName을 기준으로 여행 스타일 정보를 조회하는 메서드
    public List<Travelstyle> getTravelstyleByStyleName(String styleName) {
        return travelstyleRepository.findByStyleName(styleName);
    }

    // 기존 여행 스타일 정보를 수정하는 메서드
    @Transactional
    public Travelstyle updateTravelstyle(Long id, Travelstyle requestTravelstyle) {
        Travelstyle travelstyleData = travelstyleRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("해당 여행 스타일 정보가 없습니다."));

        travelstyleData.updateTravelstyle(
                requestTravelstyle.getStyleName(),
                requestTravelstyle.getStyleDetail()
        );

        return travelstyleData;
    }

    // 여행 스타일 정보를 삭제하는 메서드
    @Transactional
    public void deleteTravelstyle(Long id) {
        Travelstyle travelstyleData = travelstyleRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("해당 여행 스타일 정보가 없습니다."));

        travelstyleRepository.delete(travelstyleData);
    }
}