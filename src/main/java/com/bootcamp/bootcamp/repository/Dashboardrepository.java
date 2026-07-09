package com.bootcamp.bootcamp.repository;

import com.bootcamp.bootcamp.entity.Dashboard;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface Dashboardrepository extends JpaRepository<Dashboard, Long> {

    List<Dashboard> findByBudgetId(Long budgetId);

    List<Dashboard> findByTravelplanId(Long travelplanId);

    List<Dashboard> findByUserId(Long userId);

    List<Dashboard> findByGuestId(String guestId);

    List<Dashboard> findByDestination(String destination);
}