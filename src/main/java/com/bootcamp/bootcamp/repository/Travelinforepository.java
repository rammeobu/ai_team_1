package com.bootcamp.bootcamp.repository;

import com.bootcamp.bootcamp.entity.Travelinfo;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface Travelinforepository extends JpaRepository<Travelinfo, Long> {

    List<Travelinfo> findByUserId(Long userId);

    List<Travelinfo> findByGuestId(String guestId);

    List<Travelinfo> findByDestination(String destination);

    List<Travelinfo> findByBudgetId(Long budgetId);

}