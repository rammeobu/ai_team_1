package com.bootcamp.bootcamp.controller;

import com.bootcamp.bootcamp.entity.Requireditem;
import com.bootcamp.bootcamp.service.Requireditemservice;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

// 여행 필수 항목 관련 API 요청을 처리하는 Controller
@RestController
@RequestMapping("/api/required-items")
@RequiredArgsConstructor
public class Requireditemcontroller {

    // 여행 필수 항목 관련 실제 기능을 처리하는 Service
    private final Requireditemservice requireditemService;

    // 여행 필수 항목을 새로 저장하는 API
    @Operation(summary = "여행 필수 항목 저장", description = "항공권, 호텔, 서류, 추가 항목의 준비 상태와 외부 API 선택 정보를 저장합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "여행 필수 항목 저장 성공"),
            @ApiResponse(responseCode = "400", description = "잘못된 요청 데이터입니다.")
    })
    @PostMapping
    public Requireditem createRequireditem(@RequestBody Requireditem requireditemData) {
        return requireditemService.createRequireditem(requireditemData);
    }

    // 모든 여행 필수 항목을 조회하는 API
    @Operation(summary = "전체 여행 필수 항목 조회", description = "DB에 저장된 모든 여행 필수 항목을 조회합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "전체 여행 필수 항목 조회 성공")
    })
    @GetMapping
    public List<Requireditem> getAllRequireditem() {
        return requireditemService.getAllRequireditem();
    }

    // id를 기준으로 여행 필수 항목 하나를 조회하는 API
    @Operation(summary = "특정 여행 필수 항목 조회", description = "필수 항목 ID를 기준으로 특정 여행 필수 항목을 조회합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "특정 여행 필수 항목 조회 성공"),
            @ApiResponse(responseCode = "404", description = "해당 ID의 여행 필수 항목 정보가 없습니다.")
    })
    @GetMapping("/{id}")
    public Requireditem getRequireditem(@PathVariable Long id) {
        return requireditemService.getRequireditem(id);
    }

    // travelplanId를 기준으로 여행 필수 항목을 조회하는 API
    @Operation(summary = "여행 일정별 필수 항목 조회", description = "travelplanId를 기준으로 여행 필수 항목을 조회합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "여행 일정별 필수 항목 조회 성공")
    })
    @GetMapping("/travel-plan/{travelplanId}")
    public List<Requireditem> getRequireditemByTravelplanId(@PathVariable Long travelplanId) {
        return requireditemService.getRequireditemByTravelplanId(travelplanId);
    }

    // budgetId를 기준으로 여행 필수 항목을 조회하는 API
    @Operation(summary = "예산별 필수 항목 조회", description = "budgetId를 기준으로 여행 필수 항목을 조회합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "예산별 필수 항목 조회 성공")
    })
    @GetMapping("/budget/{budgetId}")
    public List<Requireditem> getRequireditemByBudgetId(@PathVariable Long budgetId) {
        return requireditemService.getRequireditemByBudgetId(budgetId);
    }

    // userId를 기준으로 여행 필수 항목을 조회하는 API
    @Operation(summary = "로그인 사용자 필수 항목 조회", description = "로그인한 사용자의 userId를 기준으로 여행 필수 항목을 조회합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "로그인 사용자 필수 항목 조회 성공")
    })
    @GetMapping("/users/{userId}")
    public List<Requireditem> getRequireditemByUserId(@PathVariable Long userId) {
        return requireditemService.getRequireditemByUserId(userId);
    }

    // guestId를 기준으로 여행 필수 항목을 조회하는 API
    @Operation(summary = "게스트 사용자 필수 항목 조회", description = "게스트 사용자의 guestId를 기준으로 여행 필수 항목을 조회합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "게스트 사용자 필수 항목 조회 성공")
    })
    @GetMapping("/guests/{guestId}")
    public List<Requireditem> getRequireditemByGuestId(@PathVariable String guestId) {
        return requireditemService.getRequireditemByGuestId(guestId);
    }

    // itemType을 기준으로 여행 필수 항목을 조회하는 API
    @Operation(summary = "항목 종류별 필수 항목 조회", description = "FLIGHT, HOTEL, DOCUMENT, EXTRA 기준으로 필수 항목을 조회합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "항목 종류별 필수 항목 조회 성공")
    })
    @GetMapping("/type/{itemType}")
    public List<Requireditem> getRequireditemByItemType(@PathVariable String itemType) {
        return requireditemService.getRequireditemByItemType(itemType);
    }

    // itemStatus를 기준으로 여행 필수 항목을 조회하는 API
    @Operation(summary = "항목 상태별 필수 항목 조회", description = "NOT_STARTED, SEARCHED, SELECTED, COMPLETED 기준으로 필수 항목을 조회합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "항목 상태별 필수 항목 조회 성공")
    })
    @GetMapping("/status/{itemStatus}")
    public List<Requireditem> getRequireditemByItemStatus(@PathVariable String itemStatus) {
        return requireditemService.getRequireditemByItemStatus(itemStatus);
    }

    // id를 기준으로 기존 여행 필수 항목을 수정하는 API
    @Operation(summary = "여행 필수 항목 수정", description = "필수 항목 ID를 기준으로 항목 상태와 외부 API 선택 정보를 수정합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "여행 필수 항목 수정 성공"),
            @ApiResponse(responseCode = "400", description = "잘못된 요청 데이터입니다."),
            @ApiResponse(responseCode = "404", description = "해당 ID의 여행 필수 항목 정보가 없습니다.")
    })
    @PutMapping("/{id}")
    public Requireditem updateRequireditem(@PathVariable Long id, @RequestBody Requireditem requireditemData) {
        return requireditemService.updateRequireditem(id, requireditemData);
    }

    // id를 기준으로 여행 필수 항목을 삭제하는 API
    @Operation(summary = "여행 필수 항목 삭제", description = "필수 항목 ID를 기준으로 여행 필수 항목을 삭제합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "204", description = "여행 필수 항목 삭제 성공"),
            @ApiResponse(responseCode = "404", description = "해당 ID의 여행 필수 항목 정보가 없습니다.")
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteRequireditem(@PathVariable Long id) {
        requireditemService.deleteRequireditem(id);
        return ResponseEntity.noContent().build();
    }
}