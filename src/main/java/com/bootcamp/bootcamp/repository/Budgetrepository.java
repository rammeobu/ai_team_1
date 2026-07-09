package com.bootcamp.bootcamp.repository;

import com.bootcamp.bootcamp.entity.Budget;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface Budgetrepository extends JpaRepository<Budget, Long> {

    List<Budget> findByUserId(Long userId);

    List<Budget> findByGuestId(String guestId);
}