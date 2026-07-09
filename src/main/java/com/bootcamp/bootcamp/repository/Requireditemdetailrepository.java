package com.bootcamp.bootcamp.repository;

import com.bootcamp.bootcamp.entity.Requireditemdetail;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface Requireditemdetailrepository extends JpaRepository<Requireditemdetail, Long> {

    List<Requireditemdetail> findByRequireditemId(Long requireditemId);

    List<Requireditemdetail> findByTravelplanId(Long travelplanId);

    List<Requireditemdetail> findByUserId(Long userId);

    List<Requireditemdetail> findByGuestId(String guestId);

    List<Requireditemdetail> findByItemType(String itemType);

    List<Requireditemdetail> findByItemStatus(String itemStatus);

    Optional<Requireditemdetail> findByRequireditemIdAndItemTypeAndItemVersion(
            Long requireditemId,
            String itemType,
            Integer itemVersion
    );
}