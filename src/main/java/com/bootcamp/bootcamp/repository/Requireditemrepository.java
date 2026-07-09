package com.bootcamp.bootcamp.repository;

import com.bootcamp.bootcamp.entity.Requireditem;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface Requireditemrepository extends JpaRepository<Requireditem, Long> {

    List<Requireditem> findByTravelplanId(Long travelplanId);

    List<Requireditem> findByBudgetId(Long budgetId);

    List<Requireditem> findByUserId(Long userId);

    List<Requireditem> findByGuestId(String guestId);

    List<Requireditem> findByItemType(String itemType);

    List<Requireditem> findByItemStatus(String itemStatus);
}