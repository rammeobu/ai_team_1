package com.bootcamp.bootcamp.service;

import com.bootcamp.bootcamp.entity.Requireditem;
import com.bootcamp.bootcamp.entity.Requireditemdetail;
import com.bootcamp.bootcamp.repository.Requireditemdetailrepository;
import com.bootcamp.bootcamp.repository.Requireditemrepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

// 여행 필수 항목 묶음과 아이콘별 상세 정보를 처리하는 Service
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class Requireditemservice {

    private final Requireditemrepository requireditemRepository;
    private final Requireditemdetailrepository requireditemdetailRepository;

    // 필수 항목 묶음 저장
    @Transactional
    public Requireditem createRequireditem(Requireditem requireditemData) {
        return requireditemRepository.save(requireditemData);
    }

    // 전체 필수 항목 묶음 조회
    public List<Requireditem> getAllRequireditem() {
        return requireditemRepository.findAll();
    }

    // 필수 항목 묶음 단일 조회
    public Requireditem getRequireditem(Long id) {
        return requireditemRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("해당 여행 필수 항목 묶음 정보가 없습니다."));
    }

    // travelplanId 기준 필수 항목 묶음 조회
    public List<Requireditem> getRequireditemByTravelplanId(Long travelplanId) {
        return requireditemRepository.findByTravelplanId(travelplanId);
    }

    // userId 기준 필수 항목 묶음 조회
    public List<Requireditem> getRequireditemByUserId(Long userId) {
        return requireditemRepository.findByUserId(userId);
    }

    // guestId 기준 필수 항목 묶음 조회
    public List<Requireditem> getRequireditemByGuestId(String guestId) {
        return requireditemRepository.findByGuestId(guestId);
    }

    // 아이콘 요청 저장 또는 수정
    // 같은 userId + travelplanId면 Requireditem을 하나로 묶음
    // 같은 requireditemId + itemType + itemVersion이면 새로 만들지 않고 기존 detail 수정
    @Transactional
    public Requireditemdetail saveIconRequireditem(Requireditemdetail requestDetail) {

        Requireditem requireditemData;

        if (requestDetail.getUserId() != null) {
            requireditemData = requireditemRepository
                    .findByUserIdAndTravelplanId(requestDetail.getUserId(), requestDetail.getTravelplanId())
                    .orElseGet(() -> requireditemRepository.save(
                            new Requireditem(
                                    requestDetail.getTravelplanId(),
                                    requestDetail.getBudgetId(),
                                    requestDetail.getUserId(),
                                    null
                            )
                    ));
        } else {
            requireditemData = requireditemRepository
                    .findByGuestIdAndTravelplanId(requestDetail.getGuestId(), requestDetail.getTravelplanId())
                    .orElseGet(() -> requireditemRepository.save(
                            new Requireditem(
                                    requestDetail.getTravelplanId(),
                                    requestDetail.getBudgetId(),
                                    null,
                                    requestDetail.getGuestId()
                            )
                    ));
        }

        Integer version = requestDetail.getItemVersion();

        if (version == null) {
            version = 1;
        }

        Requireditemdetail detailData = requireditemdetailRepository
                .findByRequireditemIdAndItemTypeAndItemVersion(
                        requireditemData.getId(),
                        requestDetail.getItemType(),
                        version
                )
                .orElseGet(Requireditemdetail::new);

        detailData.setRequireditemId(requireditemData.getId());
        detailData.setTravelplanId(requireditemData.getTravelplanId());
        detailData.setBudgetId(requireditemData.getBudgetId());
        detailData.setUserId(requireditemData.getUserId());
        detailData.setGuestId(requireditemData.getGuestId());
        detailData.setItemType(requestDetail.getItemType());
        detailData.setItemVersion(version);
        detailData.setItemName(requestDetail.getItemName());
        detailData.setItemStatus(requestDetail.getItemStatus());
        detailData.setExternalProvider(requestDetail.getExternalProvider());
        detailData.setExternalItemId(requestDetail.getExternalItemId());
        detailData.setItemSummary(requestDetail.getItemSummary());
        detailData.setExternalUrl(requestDetail.getExternalUrl());
        detailData.setSelected(requestDetail.getSelected());

        return requireditemdetailRepository.save(detailData);
    }

    // requireditemId 기준 아이콘 상세 목록 조회
    public List<Requireditemdetail> getDetailsByRequireditemId(Long requireditemId) {
        return requireditemdetailRepository.findByRequireditemId(requireditemId);
    }

    // travelplanId 기준 아이콘 상세 목록 조회
    public List<Requireditemdetail> getDetailsByTravelplanId(Long travelplanId) {
        return requireditemdetailRepository.findByTravelplanId(travelplanId);
    }

    // itemType 기준 아이콘 상세 목록 조회
    public List<Requireditemdetail> getDetailsByItemType(String itemType) {
        return requireditemdetailRepository.findByItemType(itemType);
    }

    // itemStatus 기준 아이콘 상세 목록 조회
    public List<Requireditemdetail> getDetailsByItemStatus(String itemStatus) {
        return requireditemdetailRepository.findByItemStatus(itemStatus);
    }

    // 아이콘 상세 정보 단일 조회
    public Requireditemdetail getRequireditemdetail(Long id) {
        return requireditemdetailRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("해당 여행 필수 항목 상세 정보가 없습니다."));
    }

    // 아이콘 상세 정보 수정
    @Transactional
    public Requireditemdetail updateRequireditemdetail(Long id, Requireditemdetail requestDetail) {
        Requireditemdetail detailData = requireditemdetailRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("해당 여행 필수 항목 상세 정보가 없습니다."));

        detailData.updateRequireditemdetail(
                requestDetail.getItemType(),
                requestDetail.getItemVersion(),
                requestDetail.getItemName(),
                requestDetail.getItemStatus(),
                requestDetail.getExternalProvider(),
                requestDetail.getExternalItemId(),
                requestDetail.getItemSummary(),
                requestDetail.getExternalUrl(),
                requestDetail.getSelected()
        );

        return detailData;
    }

    // 필수 항목 묶음 삭제
    @Transactional
    public void deleteRequireditem(Long id) {
        Requireditem requireditemData = requireditemRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("해당 여행 필수 항목 묶음 정보가 없습니다."));

        List<Requireditemdetail> detailList = requireditemdetailRepository.findByRequireditemId(id);

        requireditemdetailRepository.deleteAll(detailList);
        requireditemRepository.delete(requireditemData);
    }

    // 아이콘 상세 정보 삭제
    @Transactional
    public void deleteRequireditemdetail(Long id) {
        Requireditemdetail detailData = requireditemdetailRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("해당 여행 필수 항목 상세 정보가 없습니다."));

        requireditemdetailRepository.delete(detailData);
    }
}