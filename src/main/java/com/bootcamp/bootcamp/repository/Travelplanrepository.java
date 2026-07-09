package com.bootcamp.bootcamp.repository;

import com.bootcamp.bootcamp.entity.Travelplan;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface Travelplanrepository extends JpaRepository<Travelplan, Long> {

    List<Travelplan> findByBudgetId(Long budgetId);

    List<Travelplan> findByUserId(Long userId);

    List<Travelplan> findByGuestId(String guestId);

    List<Travelplan> findByDestination(String destination);
}