package com.bootcamp.bootcamp.controller;

import com.bootcamp.bootcamp.entity.Budget;
import com.bootcamp.bootcamp.service.Budgetservice;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/budgets")
@RequiredArgsConstructor
public class Budgetcontroller {

    // 예산 관련 실제 기능을 처리하는 Service
    private final Budgetservice budgetService;

    // 예산 정보를 새로 저장하는 API
    // POST /api/budgets 요청을 처리
    @Operation(
            summary = "예산 정보 저장",
            description = "사용자가 입력한 총 여행 예산을 새로 저장합니다. 로그인 사용자는 userId로 저장하고, 게스트 사용자는 guestId를 자동 생성하여 저장합니다."
    )
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "예산 정보 저장 성공"),
            @ApiResponse(responseCode = "400", description = "잘못된 요청 데이터")
    })
    @PostMapping
    public Budget createBudget(@RequestBody Budget budgetData) {
        return budgetService.createBudget(budgetData);
    }


    @Operation(summary = "전체 예산 목록 조회", description = "DB에 저장된 모든 사용자의 예산 정보를 조회합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "전체 예산 목록 조회 성공")
    })
    @GetMapping
    public List<Budget> getAllBudgets() {
        return budgetService.getAllBudgets();
    }


    // id를 기준으로 예산 정보 하나를 조회하는 API
// GET /api/budgets/{id} 요청을 처리
    @Operation(summary = "특정 예산 조회", description = "예산 ID를 기준으로 특정 예산 정보를 조회합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "특정 예산 정보 조회 성공"),
            @ApiResponse(responseCode = "404", description = "해당 ID의 예산 정보가 없습니다.")
    })
    @GetMapping("/{id}")
    public Budget getBudget(@PathVariable Long id) {
        return budgetService.getBudget(id);
    }


    // 로그인한 사용자의 userId를 기준으로 예산 목록을 조회하는 API
// GET /api/budgets/users/{userId} 요청을 처리
    @Operation(summary = "로그인 사용자 예산 목록 조회", description = "로그인한 사용자의 userId를 기준으로 저장된 예산 목록을 조회합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "로그인 사용자 예산 목록 조회 성공"),
            @ApiResponse(responseCode = "404", description = "해당 userId의 예산 정보가 없습니다.")
    })
    @GetMapping("/users/{userId}")
    public List<Budget> getBudgetsByUserId(@PathVariable Long userId) {
        return budgetService.getBudgetsByUserId(userId);
    }


    // 로그인하지 않고 스킵한 게스트 사용자의 guestId를 기준으로 예산 목록을 조회하는 API
// GET /api/budgets/guests/{guestId} 요청을 처리
    @Operation(summary = "게스트 사용자 예산 목록 조회", description = "로그인하지 않고 스킵한 게스트 사용자의 guestId를 기준으로 저장된 예산 목록을 조회합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "게스트 사용자 예산 목록 조회 성공"),
            @ApiResponse(responseCode = "404", description = "해당 guestId의 예산 정보가 없습니다.")
    })
    @GetMapping("/guests/{guestId}")
    public List<Budget> getBudgetsByGuestId(@PathVariable String guestId) {
        return budgetService.getBudgetsByGuestId(guestId);
    }


    // id를 기준으로 기존 예산 금액을 수정하는 API
// PUT /api/budgets/{id} 요청을 처리
// 예: PUT /api/budgets/1
// 요청 body에 들어온 totalBudget 값으로 기존 예산을 수정
    @Operation(summary = "기존 예산 수정", description = "예산 ID를 기준으로 기존 예산 정보를 조회한 뒤, 요청 body에 담긴 totalBudget 값으로 예산 금액을 수정합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "예산 정보 수정 성공"),
            @ApiResponse(responseCode = "400", description = "잘못된 요청 데이터입니다."),
            @ApiResponse(responseCode = "404", description = "해당 ID의 예산 정보가 없습니다.")
    })
    @PutMapping("/{id}")
    public Budget updateBudget(@PathVariable Long id, @RequestBody Budget budgetData) {
        return budgetService.updateBudget(id, budgetData);
    }


    // id를 기준으로 예산 정보를 삭제하는 API
// DELETE /api/budgets/{id} 요청을 처리
// 예: DELETE /api/budgets/1
    @Operation(summary = "예산 삭제", description = "예산 ID를 기준으로 저장된 예산 정보를 삭제합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "예산 정보 삭제 성공"),
            @ApiResponse(responseCode = "404", description = "해당 ID의 예산 정보가 없습니다.")
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<Budget> deleteBudget(@PathVariable Long id) {
        budgetService.deleteBudget(id);
        return ResponseEntity.noContent().build();
    }
}