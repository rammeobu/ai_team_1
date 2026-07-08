package com.bootcamp.bootcamp.service;

import com.bootcamp.bootcamp.entity.Travelplan;
import com.bootcamp.bootcamp.repository.Travelplanrepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

// 여행 일정 관련 기능을 처리하는 Service
@Service

// final 필드를 생성자로 자동 주입
@RequiredArgsConstructor

// 기본적으로 조회용 트랜잭션 설정
@Transactional(readOnly = true)
public class Travelplanservice {

    // 여행 일정 데이터를 DB에 저장, 조회, 삭제하기 위한 Repository
    private final Travelplanrepository travelplanRepository;

    // 여행 일정 정보를 새로 저장하는 메서드
    @Transactional
    public Travelplan createTravelplan(Travelplan travelplanData) {
        return travelplanRepository.save(travelplanData);
    }

    // 모든 여행 일정 정보를 조회하는 메서드
    public List<Travelplan> getAllTravelplan() {
        return travelplanRepository.findAll();
    }

    // id를 기준으로 여행 일정 정보 하나를 조회하는 메서드
    public Travelplan getTravelplan(Long id) {
        return travelplanRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("해당 여행 일정 정보가 없습니다."));
    }

    // budgetId를 기준으로 여행 일정 정보를 조회하는 메서드
    public List<Travelplan> getTravelplanByBudgetId(Long budgetId) {
        return travelplanRepository.findByBudgetId(budgetId);
    }

    // userId를 기준으로 여행 일정 정보를 조회하는 메서드
    public List<Travelplan> getTravelplanByUserId(Long userId) {
        return travelplanRepository.findByUserId(userId);
    }

    // guestId를 기준으로 여행 일정 정보를 조회하는 메서드
    public List<Travelplan> getTravelplanByGuestId(String guestId) {
        return travelplanRepository.findByGuestId(guestId);
    }

    // destination을 기준으로 여행 일정 정보를 조회하는 메서드
    public List<Travelplan> getTravelplanByDestination(String destination) {
        return travelplanRepository.findByDestination(destination);
    }

    // 기존 여행 일정 정보를 수정하는 메서드
    @Transactional
    public Travelplan updateTravelplan(Long id, Travelplan requestTravelplan) {
        Travelplan travelplanData = travelplanRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("해당 여행 일정 정보가 없습니다."));

        travelplanData.updateTravelplan(
                requestTravelplan.getPlanTitle(),
                requestTravelplan.getDestination(),
                requestTravelplan.getStartDate(),
                requestTravelplan.getEndDate(),
                requestTravelplan.getTotalBudget(),
                requestTravelplan.getPeopleCount(),
                requestTravelplan.getStyleName(),
                requestTravelplan.getPlanContent()
        );

        return travelplanData;
    }

    // 여행 일정 정보를 삭제하는 메서드
    @Transactional
    public void deleteTravelplan(Long id) {
        Travelplan travelplanData = travelplanRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("해당 여행 일정 정보가 없습니다."));

        travelplanRepository.delete(travelplanData);
    }
}