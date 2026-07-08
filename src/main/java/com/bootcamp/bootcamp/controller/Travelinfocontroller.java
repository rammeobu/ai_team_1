package com.bootcamp.bootcamp.controller;

import com.bootcamp.bootcamp.entity.Travelinfo;
import com.bootcamp.bootcamp.service.Travelinfoservice;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

// 여행 장소/날짜 관련 API 요청을 처리하는 Controller
@RestController

// 이 Controller의 기본 주소
@RequestMapping("/api/travel-info")

// final 필드를 생성자로 자동 주입
@RequiredArgsConstructor
public class Travelinfocontroller {

    // 여행 장소/날짜 관련 실제 기능을 처리하는 Service
    private final Travelinfoservice travelinfoService;

    // 여행 장소/날짜 정보를 새로 저장하는 API
    @Operation(summary = "여행 장소/날짜 저장", description = "사용자가 선택한 여행 장소와 시작일, 종료일을 저장합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "여행 장소/날짜 저장 성공"),
            @ApiResponse(responseCode = "400", description = "잘못된 요청 데이터입니다.")
    })
    @PostMapping
    public Travelinfo createTravelinfo(@RequestBody Travelinfo travelinfoData) {
        return travelinfoService.createTravelinfo(travelinfoData);
    }

    // 저장된 모든 여행 장소/날짜 정보를 조회하는 API
    @Operation(summary = "전체 여행 장소/날짜 목록 조회", description = "DB에 저장된 모든 여행 장소/날짜 정보를 조회합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "전체 여행 장소/날짜 목록 조회 성공")
    })
    @GetMapping
    public List<Travelinfo> getAllTravelinfo() {
        return travelinfoService.getAllTravelinfo();
    }

    // id를 기준으로 여행 장소/날짜 정보 하나를 조회하는 API
    @Operation(summary = "특정 여행 장소/날짜 조회", description = "여행 정보 ID를 기준으로 특정 여행 장소/날짜 정보를 조회합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "특정 여행 장소/날짜 조회 성공"),
            @ApiResponse(responseCode = "404", description = "해당 ID의 여행 정보가 없습니다.")
    })
    @GetMapping("/{id}")
    public Travelinfo getTravelinfo(@PathVariable Long id) {
        return travelinfoService.getTravelinfo(id);
    }

    // userId를 기준으로 여행 장소/날짜 정보를 조회하는 API
    @Operation(summary = "로그인 사용자 여행 장소/날짜 조회", description = "로그인한 사용자의 userId를 기준으로 여행 장소/날짜 정보를 조회합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "로그인 사용자 여행 장소/날짜 조회 성공"),
            @ApiResponse(responseCode = "404", description = "해당 userId의 여행 정보가 없습니다.")
    })
    @GetMapping("/users/{userId}")
    public List<Travelinfo> getTravelinfoByUserId(@PathVariable Long userId) {
        return travelinfoService.getTravelinfoByUserId(userId);
    }

    // guestId를 기준으로 여행 장소/날짜 정보를 조회하는 API
    @Operation(summary = "게스트 사용자 여행 장소/날짜 조회", description = "로그인하지 않고 스킵한 게스트 사용자의 guestId를 기준으로 여행 장소/날짜 정보를 조회합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "게스트 사용자 여행 장소/날짜 조회 성공"),
            @ApiResponse(responseCode = "404", description = "해당 guestId의 여행 정보가 없습니다.")
    })
    @GetMapping("/guests/{guestId}")
    public List<Travelinfo> getTravelinfoByGuestId(@PathVariable String guestId) {
        return travelinfoService.getTravelinfoByGuestId(guestId);
    }

    // destination을 기준으로 여행 장소/날짜 정보를 조회하는 API
    @Operation(summary = "여행 지역별 조회", description = "사용자가 선택한 여행 지역을 기준으로 여행 정보를 조회합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "여행 지역별 조회 성공")
    })
    @GetMapping("/destination/{destination}")
    public List<Travelinfo> getTravelinfoByDestination(@PathVariable String destination) {
        return travelinfoService.getTravelinfoByDestination(destination);
    }

    // id를 기준으로 기존 여행 장소/날짜 정보를 수정하는 API
    @Operation(summary = "여행 장소/날짜 수정", description = "여행 정보 ID를 기준으로 기존 여행 장소와 시작일, 종료일을 수정합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "여행 장소/날짜 수정 성공"),
            @ApiResponse(responseCode = "400", description = "잘못된 요청 데이터입니다."),
            @ApiResponse(responseCode = "404", description = "해당 ID의 여행 정보가 없습니다.")
    })
    @PutMapping("/{id}")
    public Travelinfo updateTravelinfo(@PathVariable Long id, @RequestBody Travelinfo travelinfoData) {
        return travelinfoService.updateTravelinfo(id, travelinfoData);
    }

    // id를 기준으로 여행 장소/날짜 정보를 삭제하는 API
    @Operation(summary = "여행 장소/날짜 삭제", description = "여행 정보 ID를 기준으로 저장된 여행 장소/날짜 정보를 삭제합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "204", description = "여행 장소/날짜 삭제 성공"),
            @ApiResponse(responseCode = "404", description = "해당 ID의 여행 정보가 없습니다.")
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteTravelinfo(@PathVariable Long id) {
        travelinfoService.deleteTravelinfo(id);
        return ResponseEntity.noContent().build();
    }

    @Operation(summary = "예산별 여행 장소/날짜 조회", description = "budgetId를 기준으로 해당 예산에 연결된 여행 장소/날짜 정보를 조회합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "예산별 여행 장소/날짜 조회 성공"),
            @ApiResponse(responseCode = "404", description = "해당 budgetId의 여행 정보가 없습니다.")
    })
    @GetMapping("/budget/{budgetId}")
    public List<Travelinfo> getTravelinfoByBudgetId(@PathVariable Long budgetId) {
        return travelinfoService.getTravelinfoByBudgetId(budgetId);
    }
}