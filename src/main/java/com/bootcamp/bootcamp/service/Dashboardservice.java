package com.bootcamp.bootcamp.service;

import com.bootcamp.bootcamp.entity.Dashboard;
import com.bootcamp.bootcamp.repository.Dashboardrepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor

@Transactional(readOnly = true)
public class Dashboardservice {

    private final Dashboardrepository dashboardRepository;

    @Transactional
    public Dashboard createDashboard(Dashboard dashboardData) {
        return dashboardRepository.save(dashboardData);
    }

    // 모든 대시보드 정보를 조회하는 메서드
    public List<Dashboard> getAllDashboard() {
        return dashboardRepository.findAll();
    }

    // id를 기준으로 대시보드 정보 하나를 조회하는 메서드
    public Dashboard getDashboard(Long id) {
        return dashboardRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("해당 대시보드 정보가 없습니다."));
    }

    // budgetId를 기준으로 대시보드 정보를 조회하는 메서드
    public List<Dashboard> getDashboardByBudgetId(Long budgetId) {
        return dashboardRepository.findByBudgetId(budgetId);
    }

    // travelplanId를 기준으로 대시보드 정보를 조회하는 메서드
    public List<Dashboard> getDashboardByTravelplanId(Long travelplanId) {
        return dashboardRepository.findByTravelplanId(travelplanId);
    }

    // userId를 기준으로 대시보드 정보를 조회하는 메서드
    public List<Dashboard> getDashboardByUserId(Long userId) {
        return dashboardRepository.findByUserId(userId);
    }

    // guestId를 기준으로 대시보드 정보를 조회하는 메서드
    public List<Dashboard> getDashboardByGuestId(String guestId) {
        return dashboardRepository.findByGuestId(guestId);
    }

    // destination을 기준으로 대시보드 정보를 조회하는 메서드
    public List<Dashboard> getDashboardByDestination(String destination) {
        return dashboardRepository.findByDestination(destination);
    }

    // 기존 대시보드 정보를 수정하는 메서드
    @Transactional
    public Dashboard updateDashboard(Long id, Dashboard requestDashboard) {
        Dashboard dashboardData = dashboardRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("해당 대시보드 정보가 없습니다."));

        dashboardData.updateDashboard(
                requestDashboard.getDashboardTitle(),
                requestDashboard.getDestination(),
                requestDashboard.getStartDate(),
                requestDashboard.getEndDate(),
                requestDashboard.getTotalBudget(),
                requestDashboard.getUsedBudget(),
                requestDashboard.getRemainingBudget(),
                requestDashboard.getPeopleCount(),
                requestDashboard.getStyleName(),
                requestDashboard.getPlanSummary()
        );

        return dashboardData;
    }

    // 대시보드 정보를 삭제하는 메서드
    @Transactional
    public void deleteDashboard(Long id) {
        Dashboard dashboardData = dashboardRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("해당 대시보드 정보가 없습니다."));

        dashboardRepository.delete(dashboardData);
    }
}