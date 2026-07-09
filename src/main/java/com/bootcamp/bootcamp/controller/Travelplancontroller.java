package com.bootcamp.bootcamp.controller;

import com.bootcamp.bootcamp.entity.Travelplan;
import com.bootcamp.bootcamp.service.Travelplanservice;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

// 여행 일정 관련 API 요청을 처리하는 Controller
@RestController

// 이 Controller의 기본 주소
@RequestMapping("/api/travel-plan")

// final 필드를 생성자로 자동 주입
@RequiredArgsConstructor
public class Travelplancontroller {

    // 여행 일정 관련 실제 기능을 처리하는 Service
    private final Travelplanservice travelplanService;

    // 여행 일정 정보를 새로 저장하는 API
    @Operation(summary = "여행 일정 저장", description = "AI가 생성한 여행 일정 결과를 저장합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "여행 일정 저장 성공"),
            @ApiResponse(responseCode = "400", description = "잘못된 요청 데이터입니다.")
    })
    @PostMapping
    public Travelplan createTravelplan(@RequestBody Travelplan travelplanData) {
        return travelplanService.createTravelplan(travelplanData);
    }

    // 저장된 모든 여행 일정 정보를 조회하는 API
    @Operation(summary = "전체 여행 일정 목록 조회", description = "DB에 저장된 모든 여행 일정 정보를 조회합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "전체 여행 일정 목록 조회 성공")
    })
    @GetMapping
    public List<Travelplan> getAllTravelplan() {
        return travelplanService.getAllTravelplan();
    }

    // id를 기준으로 여행 일정 정보 하나를 조회하는 API
    @Operation(summary = "특정 여행 일정 조회", description = "여행 일정 ID를 기준으로 특정 여행 일정 정보를 조회합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "특정 여행 일정 조회 성공"),
            @ApiResponse(responseCode = "404", description = "해당 ID의 여행 일정 정보가 없습니다.")
    })
    @GetMapping("/{id}")
    public Travelplan getTravelplan(@PathVariable Long id) {
        return travelplanService.getTravelplan(id);
    }

    // budgetId를 기준으로 여행 일정 정보를 조회하는 API
    @Operation(summary = "예산별 여행 일정 조회", description = "budgetId를 기준으로 해당 예산에 연결된 여행 일정을 조회합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "예산별 여행 일정 조회 성공"),
            @ApiResponse(responseCode = "404", description = "해당 budgetId의 여행 일정 정보가 없습니다.")
    })
    @GetMapping("/budget/{budgetId}")
    public List<Travelplan> getTravelplanByBudgetId(@PathVariable Long budgetId) {
        return travelplanService.getTravelplanByBudgetId(budgetId);
    }

    // userId를 기준으로 여행 일정 정보를 조회하는 API
    @Operation(summary = "로그인 사용자 여행 일정 조회", description = "로그인한 사용자의 userId를 기준으로 여행 일정을 조회합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "로그인 사용자 여행 일정 조회 성공"),
            @ApiResponse(responseCode = "404", description = "해당 userId의 여행 일정 정보가 없습니다.")
    })
    @GetMapping("/users/{userId}")
    public List<Travelplan> getTravelplanByUserId(@PathVariable Long userId) {
        return travelplanService.getTravelplanByUserId(userId);
    }

    // guestId를 기준으로 여행 일정 정보를 조회하는 API
    @Operation(summary = "게스트 사용자 여행 일정 조회", description = "로그인하지 않고 스킵한 게스트 사용자의 guestId를 기준으로 여행 일정을 조회합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "게스트 사용자 여행 일정 조회 성공"),
            @ApiResponse(responseCode = "404", description = "해당 guestId의 여행 일정 정보가 없습니다.")
    })
    @GetMapping("/guests/{guestId}")
    public List<Travelplan> getTravelplanByGuestId(@PathVariable String guestId) {
        return travelplanService.getTravelplanByGuestId(guestId);
    }

    // destination을 기준으로 여행 일정 정보를 조회하는 API
    @Operation(summary = "여행 지역별 일정 조회", description = "여행 지역을 기준으로 여행 일정을 조회합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "여행 지역별 일정 조회 성공")
    })
    @GetMapping("/destination/{destination}")
    public List<Travelplan> getTravelplanByDestination(@PathVariable String destination) {
        return travelplanService.getTravelplanByDestination(destination);
    }

    // id를 기준으로 기존 여행 일정 정보를 수정하는 API
    @Operation(summary = "여행 일정 수정", description = "여행 일정 ID를 기준으로 기존 여행 일정 정보를 수정합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "여행 일정 수정 성공"),
            @ApiResponse(responseCode = "400", description = "잘못된 요청 데이터입니다."),
            @ApiResponse(responseCode = "404", description = "해당 ID의 여행 일정 정보가 없습니다.")
    })
    @PutMapping("/{id}")
    public Travelplan updateTravelplan(@PathVariable Long id, @RequestBody Travelplan travelplanData) {
        return travelplanService.updateTravelplan(id, travelplanData);
    }

    // id를 기준으로 여행 일정 정보를 삭제하는 API
    @Operation(summary = "여행 일정 삭제", description = "여행 일정 ID를 기준으로 저장된 여행 일정 정보를 삭제합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "204", description = "여행 일정 삭제 성공"),
            @ApiResponse(responseCode = "404", description = "해당 ID의 여행 일정 정보가 없습니다.")
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteTravelplan(@PathVariable Long id) {
        travelplanService.deleteTravelplan(id);
        return ResponseEntity.noContent().build();
    }
}