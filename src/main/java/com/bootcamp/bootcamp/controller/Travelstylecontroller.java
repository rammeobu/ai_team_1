package com.bootcamp.bootcamp.controller;

import com.bootcamp.bootcamp.entity.Travelstyle;
import com.bootcamp.bootcamp.service.Travelstyleservice;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

// 여행 스타일 관련 API 요청을 처리하는 Controller
@RestController

// 이 Controller의 기본 주소
@RequestMapping("/api/travel-style")

// final 필드를 생성자로 자동 주입
@RequiredArgsConstructor
public class Travelstylecontroller {

    // 여행 스타일 관련 실제 기능을 처리하는 Service
    private final Travelstyleservice travelstyleService;

    // 여행 스타일 정보를 새로 저장하는 API
    @Operation(summary = "여행 스타일 저장", description = "사용자가 선택한 여행 스타일 정보를 저장합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "여행 스타일 저장 성공"),
            @ApiResponse(responseCode = "400", description = "잘못된 요청 데이터입니다.")
    })
    @PostMapping
    public Travelstyle createTravelstyle(@RequestBody Travelstyle travelstyleData) {
        return travelstyleService.createTravelstyle(travelstyleData);
    }

    // 저장된 모든 여행 스타일 정보를 조회하는 API
    @Operation(summary = "전체 여행 스타일 목록 조회", description = "DB에 저장된 모든 여행 스타일 정보를 조회합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "전체 여행 스타일 목록 조회 성공")
    })
    @GetMapping
    public List<Travelstyle> getAllTravelstyle() {
        return travelstyleService.getAllTravelstyle();
    }

    // id를 기준으로 여행 스타일 정보 하나를 조회하는 API
    @Operation(summary = "특정 여행 스타일 조회", description = "여행 스타일 ID를 기준으로 특정 여행 스타일 정보를 조회합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "특정 여행 스타일 조회 성공"),
            @ApiResponse(responseCode = "404", description = "해당 ID의 여행 스타일 정보가 없습니다.")
    })
    @GetMapping("/{id}")
    public Travelstyle getTravelstyle(@PathVariable Long id) {
        return travelstyleService.getTravelstyle(id);
    }

    // budgetId를 기준으로 여행 스타일 정보를 조회하는 API
    @Operation(summary = "예산별 여행 스타일 조회", description = "budgetId를 기준으로 해당 예산에 연결된 여행 스타일 정보를 조회합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "예산별 여행 스타일 조회 성공"),
            @ApiResponse(responseCode = "404", description = "해당 budgetId의 여행 스타일 정보가 없습니다.")
    })
    @GetMapping("/budget/{budgetId}")
    public List<Travelstyle> getTravelstyleByBudgetId(@PathVariable Long budgetId) {
        return travelstyleService.getTravelstyleByBudgetId(budgetId);
    }

    // userId를 기준으로 여행 스타일 정보를 조회하는 API
    @Operation(summary = "로그인 사용자 여행 스타일 조회", description = "로그인한 사용자의 userId를 기준으로 여행 스타일 정보를 조회합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "로그인 사용자 여행 스타일 조회 성공"),
            @ApiResponse(responseCode = "404", description = "해당 userId의 여행 스타일 정보가 없습니다.")
    })
    @GetMapping("/users/{userId}")
    public List<Travelstyle> getTravelstyleByUserId(@PathVariable Long userId) {
        return travelstyleService.getTravelstyleByUserId(userId);
    }

    // guestId를 기준으로 여행 스타일 정보를 조회하는 API
    @Operation(summary = "게스트 사용자 여행 스타일 조회", description = "로그인하지 않고 스킵한 게스트 사용자의 guestId를 기준으로 여행 스타일 정보를 조회합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "게스트 사용자 여행 스타일 조회 성공"),
            @ApiResponse(responseCode = "404", description = "해당 guestId의 여행 스타일 정보가 없습니다.")
    })
    @GetMapping("/guests/{guestId}")
    public List<Travelstyle> getTravelstyleByGuestId(@PathVariable String guestId) {
        return travelstyleService.getTravelstyleByGuestId(guestId);
    }

    // styleName을 기준으로 여행 스타일 정보를 조회하는 API
    @Operation(summary = "여행 스타일별 조회", description = "사용자가 선택한 여행 스타일 이름을 기준으로 여행 스타일 정보를 조회합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "여행 스타일별 조회 성공")
    })
    @GetMapping("/style/{styleName}")
    public List<Travelstyle> getTravelstyleByStyleName(@PathVariable String styleName) {
        return travelstyleService.getTravelstyleByStyleName(styleName);
    }

    // id를 기준으로 기존 여행 스타일 정보를 수정하는 API
    @Operation(summary = "여행 스타일 수정", description = "여행 스타일 ID를 기준으로 기존 여행 스타일 정보를 수정합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "여행 스타일 수정 성공"),
            @ApiResponse(responseCode = "400", description = "잘못된 요청 데이터입니다."),
            @ApiResponse(responseCode = "404", description = "해당 ID의 여행 스타일 정보가 없습니다.")
    })
    @PutMapping("/{id}")
    public Travelstyle updateTravelstyle(@PathVariable Long id, @RequestBody Travelstyle travelstyleData) {
        return travelstyleService.updateTravelstyle(id, travelstyleData);
    }

    // id를 기준으로 여행 스타일 정보를 삭제하는 API
    @Operation(summary = "여행 스타일 삭제", description = "여행 스타일 ID를 기준으로 저장된 여행 스타일 정보를 삭제합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "204", description = "여행 스타일 삭제 성공"),
            @ApiResponse(responseCode = "404", description = "해당 ID의 여행 스타일 정보가 없습니다.")
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteTravelstyle(@PathVariable Long id) {
        travelstyleService.deleteTravelstyle(id);
        return ResponseEntity.noContent().build();
    }
}