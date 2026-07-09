package com.bootcamp.bootcamp.service;

import com.bootcamp.bootcamp.entity.Budget;
import com.bootcamp.bootcamp.repository.Budgetrepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service

@RequiredArgsConstructor

@Transactional(readOnly = true)
public class Budgetservice {

    // 예산 데이터를 DB에 저장, 조회, 삭제하기 위해 사용하는 Repository
    private final Budgetrepository budgetRepository;

    // 예산 정보를 새로 저장하는 메서드
    @Transactional
    public Budget createBudget(Budget budgetData) {

        // userId도 없고 guestId도 없으면 게스트아이디를 만들어줌
        if (budgetData.getUserId() == null && budgetData.getGuestId() == null) {
            budgetData.setGuestId("guest-" + UUID.randomUUID());
        }

        return budgetRepository.save(budgetData);
    }

    // DB에 저장된 모든 예산 데이터를 조회하는 메서드
    public List<Budget> getAllBudgets() {
        return budgetRepository.findAll();
    }

    // id를 기준으로 예산 데이터 하나를 조회하는 메서드
    public Budget getBudget(Long id) {

        // id로 조회하고 없으면 예외 발생
        return budgetRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("해당 예산 정보가 없습니다."));
    }

    // 로그인한 사용자의 userId를 기준으로 예산 목록을 조회하는 메서드
    public List<Budget> getBudgetsByUserId(Long userId) {
        return budgetRepository.findByUserId(userId);
    }

    //guestId를 기준으로 예산 목록을 조회하는 메서드
    public List<Budget> getBudgetsByGuestId(String guestId) {
        return budgetRepository.findByGuestId(guestId);
    }

    // 기존 예산 금액을 수정하는 메서드
    @Transactional
    public Budget updateBudget(Long id, Budget requestBudget) {

        // id로 조회하고 없으면 예외 발생
        Budget budgetData = budgetRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("해당 예산 정보가 없습니다."));

        budgetData.updateBudget(requestBudget.getTotalBudget());
        return budgetData;
    }

    // 예산 데이터를 삭제하는 메서드
    @Transactional
    public void deleteBudget(Long id) {

        // id로 조회하고 없으면 예외 발생
        Budget budgetData = budgetRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("해당 예산 정보가 없습니다."));

        budgetRepository.delete(budgetData);
    }
}