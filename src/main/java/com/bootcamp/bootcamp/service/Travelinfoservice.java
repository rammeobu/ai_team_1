package com.bootcamp.bootcamp.service;

import com.bootcamp.bootcamp.entity.Travelinfo;
import com.bootcamp.bootcamp.repository.Travelinforepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

// 여행 장소/날짜 관련 기능을 처리하는 Service
@Service

// final 필드를 생성자로 자동 주입
@RequiredArgsConstructor

// 기본적으로 조회용 트랜잭션 설정
@Transactional(readOnly = true)
public class Travelinfoservice {

    // 여행 장소/날짜 데이터를 DB에 저장, 조회, 삭제하기 위한 Repository
    private final Travelinforepository travelinfoRepository;

    // 여행 장소/날짜 정보를 새로 저장하는 메서드
    @Transactional
    public Travelinfo createTravelinfo(Travelinfo travelinfoData) {
        return travelinfoRepository.save(travelinfoData);
    }

    // 모든 여행 장소/날짜 정보를 조회하는 메서드
    public List<Travelinfo> getAllTravelinfo() {
        return travelinfoRepository.findAll();
    }

    // id를 기준으로 여행 장소/날짜 정보 하나를 조회하는 메서드
    public Travelinfo getTravelinfo(Long id) {
        return travelinfoRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("해당 여행 정보가 없습니다."));
    }

    // userId를 기준으로 여행 장소/날짜 정보를 조회하는 메서드
    public List<Travelinfo> getTravelinfoByUserId(Long userId) {
        return travelinfoRepository.findByUserId(userId);
    }

    // guestId를 기준으로 여행 장소/날짜 정보를 조회하는 메서드
    public List<Travelinfo> getTravelinfoByGuestId(String guestId) {
        return travelinfoRepository.findByGuestId(guestId);
    }

    // destination을 기준으로 여행 장소/날짜 정보를 조회하는 메서드
    public List<Travelinfo> getTravelinfoByDestination(String destination) {
        return travelinfoRepository.findByDestination(destination);
    }

    // 예산을 기준으로 여행 장소/날짜 정보를 조회하는 메서드
    public List<Travelinfo> getTravelinfoByBudgetId(Long budgetId) {
        return travelinfoRepository.findByBudgetId(budgetId);
    }

    // 기존 여행 장소/날짜 정보를 수정하는 메서드
    @Transactional
    public Travelinfo updateTravelinfo(Long id, Travelinfo requestTravelinfo) {
        Travelinfo travelinfoData = travelinfoRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("해당 여행 정보가 없습니다."));

        travelinfoData.updateTravelinfo(
                requestTravelinfo.getDestination(),
                requestTravelinfo.getStartDate(),
                requestTravelinfo.getEndDate()
        );

        return travelinfoData;
    }

    // 여행 장소/날짜 정보를 삭제하는 메서드
    @Transactional
    public void deleteTravelinfo(Long id) {
        Travelinfo travelinfoData = travelinfoRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("해당 여행 정보가 없습니다."));

        travelinfoRepository.delete(travelinfoData);
    }
}