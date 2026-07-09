package com.bootcamp.bootcamp.repository;

import com.bootcamp.bootcamp.entity.Requireditem;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface Requireditemrepository extends JpaRepository<Requireditem, Long> {

    List<Requireditem> findByTravelplanId(Long travelplanId);

    List<Requireditem> findByBudgetId(Long budgetId);

    List<Requireditem> findByUserId(Long userId);

    List<Requireditem> findByGuestId(String guestId);

    Optional<Requireditem> findByUserIdAndTravelplanId(Long userId, Long travelplanId);

    Optional<Requireditem> findByGuestIdAndTravelplanId(String guestId, Long travelplanId);
}