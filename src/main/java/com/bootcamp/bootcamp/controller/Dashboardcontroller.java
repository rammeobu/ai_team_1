package com.bootcamp.bootcamp.controller;

import com.bootcamp.bootcamp.entity.Dashboard;
import com.bootcamp.bootcamp.service.Dashboardservice;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

// 대시보드 관련 API 요청을 처리하는 Controller
@RestController

// 이 Controller의 기본 주소
@RequestMapping("/api/dashboard")

// final 필드를 생성자로 자동 주입
@RequiredArgsConstructor
public class Dashboardcontroller {

    // 대시보드 관련 실제 기능을 처리하는 Service
    private final Dashboardservice dashboardService;

    // 대시보드 정보를 새로 저장하는 API
    @Operation(summary = "대시보드 저장", description = "홈 화면에 보여줄 여행 요약 정보를 저장합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "대시보드 저장 성공"),
            @ApiResponse(responseCode = "400", description = "잘못된 요청 데이터입니다.")
    })
    @PostMapping
    public Dashboard createDashboard(@RequestBody Dashboard dashboardData) {
        return dashboardService.createDashboard(dashboardData);
    }

    // 저장된 모든 대시보드 정보를 조회하는 API
    @Operation(summary = "전체 대시보드 목록 조회", description = "DB에 저장된 모든 대시보드 정보를 조회합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "전체 대시보드 목록 조회 성공")
    })
    @GetMapping
    public List<Dashboard> getAllDashboard() {
        return dashboardService.getAllDashboard();
    }

    // id를 기준으로 대시보드 정보 하나를 조회하는 API
    @Operation(summary = "특정 대시보드 조회", description = "대시보드 ID를 기준으로 특정 대시보드 정보를 조회합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "특정 대시보드 조회 성공"),
            @ApiResponse(responseCode = "404", description = "해당 ID의 대시보드 정보가 없습니다.")
    })
    @GetMapping("/{id}")
    public Dashboard getDashboard(@PathVariable Long id) {
        return dashboardService.getDashboard(id);
    }

    // budgetId를 기준으로 대시보드 정보를 조회하는 API
    @Operation(summary = "예산별 대시보드 조회", description = "budgetId를 기준으로 해당 예산에 연결된 대시보드 정보를 조회합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "예산별 대시보드 조회 성공"),
            @ApiResponse(responseCode = "404", description = "해당 budgetId의 대시보드 정보가 없습니다.")
    })
    @GetMapping("/budget/{budgetId}")
    public List<Dashboard> getDashboardByBudgetId(@PathVariable Long budgetId) {
        return dashboardService.getDashboardByBudgetId(budgetId);
    }

    // travelplanId를 기준으로 대시보드 정보를 조회하는 API
    @Operation(summary = "여행 일정별 대시보드 조회", description = "travelplanId를 기준으로 해당 여행 일정에 연결된 대시보드 정보를 조회합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "여행 일정별 대시보드 조회 성공"),
            @ApiResponse(responseCode = "404", description = "해당 travelplanId의 대시보드 정보가 없습니다.")
    })
    @GetMapping("/travel-plan/{travelplanId}")
    public List<Dashboard> getDashboardByTravelplanId(@PathVariable Long travelplanId) {
        return dashboardService.getDashboardByTravelplanId(travelplanId);
    }

    // userId를 기준으로 대시보드 정보를 조회하는 API
    @Operation(summary = "로그인 사용자 대시보드 조회", description = "로그인한 사용자의 userId를 기준으로 대시보드 정보를 조회합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "로그인 사용자 대시보드 조회 성공"),
            @ApiResponse(responseCode = "404", description = "해당 userId의 대시보드 정보가 없습니다.")
    })
    @GetMapping("/users/{userId}")
    public List<Dashboard> getDashboardByUserId(@PathVariable Long userId) {
        return dashboardService.getDashboardByUserId(userId);
    }

    // guestId를 기준으로 대시보드 정보를 조회하는 API
    @Operation(summary = "게스트 사용자 대시보드 조회", description = "로그인하지 않고 스킵한 게스트 사용자의 guestId를 기준으로 대시보드 정보를 조회합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "게스트 사용자 대시보드 조회 성공"),
            @ApiResponse(responseCode = "404", description = "해당 guestId의 대시보드 정보가 없습니다.")
    })
    @GetMapping("/guests/{guestId}")
    public List<Dashboard> getDashboardByGuestId(@PathVariable String guestId) {
        return dashboardService.getDashboardByGuestId(guestId);
    }

    // destination을 기준으로 대시보드 정보를 조회하는 API
    @Operation(summary = "여행 지역별 대시보드 조회", description = "여행 지역을 기준으로 대시보드 정보를 조회합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "여행 지역별 대시보드 조회 성공")
    })
    @GetMapping("/destination/{destination}")
    public List<Dashboard> getDashboardByDestination(@PathVariable String destination) {
        return dashboardService.getDashboardByDestination(destination);
    }

    // id를 기준으로 기존 대시보드 정보를 수정하는 API
    @Operation(summary = "대시보드 수정", description = "대시보드 ID를 기준으로 기존 대시보드 정보를 수정합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "대시보드 수정 성공"),
            @ApiResponse(responseCode = "400", description = "잘못된 요청 데이터입니다."),
            @ApiResponse(responseCode = "404", description = "해당 ID의 대시보드 정보가 없습니다.")
    })
    @PutMapping("/{id}")
    public Dashboard updateDashboard(@PathVariable Long id, @RequestBody Dashboard dashboardData) {
        return dashboardService.updateDashboard(id, dashboardData);
    }

    // id를 기준으로 대시보드 정보를 삭제하는 API
    @Operation(summary = "대시보드 삭제", description = "대시보드 ID를 기준으로 저장된 대시보드 정보를 삭제합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "204", description = "대시보드 삭제 성공"),
            @ApiResponse(responseCode = "404", description = "해당 ID의 대시보드 정보가 없습니다.")
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteDashboard(@PathVariable Long id) {
        dashboardService.deleteDashboard(id);
        return ResponseEntity.noContent().build();
    }
}