package com.bootcamp.bootcamp.service;

import com.bootcamp.bootcamp.entity.People;
import com.bootcamp.bootcamp.repository.Peoplerepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor

// 조회용 트랜잭션 설정
@Transactional(readOnly = true)
public class Peopleservice {

    // 인원 데이터를 DB에 저장, 조회, 삭제하기 위한 Repository
    private final Peoplerepository peopleRepository;

    // 인원 정보를 새로 저장하는 메서드
    @Transactional
    public People createPeople(People peopleData) {
        return peopleRepository.save(peopleData);
    }

    // 모든 인원 정보를 조회하는 메서드
    public List<People> getAllPeople() {
        return peopleRepository.findAll();
    }

    // id를 기준으로 인원 정보 하나를 조회하는 메서드
    public People getPeople(Long id) {
        return peopleRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("해당 인원 정보가 없습니다."));
    }

    // budgetId를 기준으로 인원 정보를 조회하는 메서드
    public List<People> getPeopleByBudgetId(Long budgetId) {
        return peopleRepository.findByBudgetId(budgetId);
    }

    // 로그인한 사용자의 userId를 기준으로 인원 정보를 조회하는 메서드
    public List<People> getPeopleByUserId(Long userId) {
        return peopleRepository.findByUserId(userId);
    }

    // 로그인 스킵한 게스트 사용자의 guestId를 기준으로 인원 정보를 조회하는 메서드
    public List<People> getPeopleByGuestId(String guestId) {
        return peopleRepository.findByGuestId(guestId);
    }

    // 기존 인원 수를 수정하는 메서드
    @Transactional
    public People updatePeople(Long id, People requestPeople) {
        People peopleData = peopleRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("해당 인원 정보가 없습니다."));

        peopleData.updatePeopleCount(requestPeople.getPeopleCount());

        return peopleData;
    }

    // 인원 정보를 삭제하는 메서드
    @Transactional
    public void deletePeople(Long id) {
        People peopleData = peopleRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("해당 인원 정보가 없습니다."));

        peopleRepository.delete(peopleData);
    }
}