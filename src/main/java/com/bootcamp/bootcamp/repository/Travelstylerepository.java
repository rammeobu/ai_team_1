package com.bootcamp.bootcamp.repository;

import com.bootcamp.bootcamp.entity.Travelstyle;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface Travelstylerepository extends JpaRepository<Travelstyle, Long> {

    List<Travelstyle> findByBudgetId(Long budgetId);

    List<Travelstyle> findByUserId(Long userId);

    List<Travelstyle> findByGuestId(String guestId);

    List<Travelstyle> findByStyleName(String styleName);
}