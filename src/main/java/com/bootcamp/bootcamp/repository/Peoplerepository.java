package com.bootcamp.bootcamp.repository;

import com.bootcamp.bootcamp.entity.People;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface Peoplerepository extends JpaRepository<People, Long> {

    List<People> findByBudgetId(Long budgetId);

    List<People> findByUserId(Long userId);

    List<People> findByGuestId(String guestId);
}