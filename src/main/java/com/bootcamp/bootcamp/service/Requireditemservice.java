package com.bootcamp.bootcamp.service;

import com.bootcamp.bootcamp.entity.Requireditem;
import com.bootcamp.bootcamp.repository.Requireditemrepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

// 여행 필수 항목 관련 기능을 처리하는 Service
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class Requireditemservice {

    // 여행 필수 항목 데이터를 DB에 저장, 조회, 삭제하기 위한 Repository
    private final Requireditemrepository requireditemRepository;

    // 여행 필수 항목을 새로 저장하는 메서드
    @Transactional
    public Requireditem createRequireditem(Requireditem requireditemData) {
        return requireditemRepository.save(requireditemData);
    }

    // 모든 여행 필수 항목을 조회하는 메서드
    public List<Requireditem> getAllRequireditem() {
        return requireditemRepository.findAll();
    }

    // id를 기준으로 여행 필수 항목 하나를 조회하는 메서드
    public Requireditem getRequireditem(Long id) {
        return requireditemRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("해당 여행 필수 항목 정보가 없습니다."));
    }

    // travelplanId를 기준으로 여행 필수 항목을 조회하는 메서드
    public List<Requireditem> getRequireditemByTravelplanId(Long travelplanId) {
        return requireditemRepository.findByTravelplanId(travelplanId);
    }

    // budgetId를 기준으로 여행 필수 항목을 조회하는 메서드
    public List<Requireditem> getRequireditemByBudgetId(Long budgetId) {
        return requireditemRepository.findByBudgetId(budgetId);
    }

    // userId를 기준으로 여행 필수 항목을 조회하는 메서드
    public List<Requireditem> getRequireditemByUserId(Long userId) {
        return requireditemRepository.findByUserId(userId);
    }

    // guestId를 기준으로 여행 필수 항목을 조회하는 메서드
    public List<Requireditem> getRequireditemByGuestId(String guestId) {
        return requireditemRepository.findByGuestId(guestId);
    }

    // itemType을 기준으로 여행 필수 항목을 조회하는 메서드
    public List<Requireditem> getRequireditemByItemType(String itemType) {
        return requireditemRepository.findByItemType(itemType);
    }

    // itemStatus를 기준으로 여행 필수 항목을 조회하는 메서드
    public List<Requireditem> getRequireditemByItemStatus(String itemStatus) {
        return requireditemRepository.findByItemStatus(itemStatus);
    }

    // 기존 여행 필수 항목을 수정하는 메서드
    @Transactional
    public Requireditem updateRequireditem(Long id, Requireditem requestRequireditem) {
        Requireditem requireditemData = requireditemRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("해당 여행 필수 항목 정보가 없습니다."));

        requireditemData.updateRequireditem(
                requestRequireditem.getItemType(),
                requestRequireditem.getItemName(),
                requestRequireditem.getItemStatus(),
                requestRequireditem.getExternalProvider(),
                requestRequireditem.getExternalItemId(),
                requestRequireditem.getItemSummary(),
                requestRequireditem.getExternalUrl(),
                requestRequireditem.getSelected()
        );

        return requireditemData;
    }

    // 여행 필수 항목을 삭제하는 메서드
    @Transactional
    public void deleteRequireditem(Long id) {
        Requireditem requireditemData = requireditemRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("해당 여행 필수 항목 정보가 없습니다."));

        requireditemRepository.delete(requireditemData);
    }
}