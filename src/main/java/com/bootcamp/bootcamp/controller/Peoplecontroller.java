package com.bootcamp.bootcamp.controller;

import com.bootcamp.bootcamp.entity.People;
import com.bootcamp.bootcamp.service.Peopleservice;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/people")
@RequiredArgsConstructor

public class Peoplecontroller {

    // 여행 인원 관련 실제 기능을 처리하는 Service
    private final Peopleservice peopleService;

    // 인원 정보를 새로 저장하는 API
    @Operation(summary = "여행 인원 저장", description = "사용자가 선택한 여행 인원 수를 새로 저장합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "여행 인원 저장 성공"),
            @ApiResponse(responseCode = "400", description = "잘못된 요청 데이터입니다.")
    })
    @PostMapping
    public People createPeople(@RequestBody People peopleData) {
        return peopleService.createPeople(peopleData);
    }

    // 저장된 모든 인원 정보를 조회하는 API
    @Operation(summary = "전체 여행 인원 목록 조회", description = "DB에 저장된 모든 여행 인원 정보를 조회합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "전체 여행 인원 목록 조회 성공")
    })
    @GetMapping
    public List<People> getAllPeople() {
        return peopleService.getAllPeople();
    }

    // id를 기준으로 인원 정보 하나를 조회하는 API
    @Operation(summary = "특정 여행 인원 조회", description = "인원 ID를 기준으로 특정 여행 인원 정보를 조회합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "특정 여행 인원 조회 성공"),
            @ApiResponse(responseCode = "404", description = "해당 ID의 여행 인원 정보가 없습니다.")
    })
    @GetMapping("/{id}")
    public People getPeople(@PathVariable Long id) {
        return peopleService.getPeople(id);
    }

    // budgetId를 기준으로 인원 정보를 조회하는 API
    @Operation(summary = "예산별 여행 인원 조회", description = "budgetId를 기준으로 해당 예산에 연결된 여행 인원 정보를 조회합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "예산별 여행 인원 조회 성공"),
            @ApiResponse(responseCode = "404", description = "해당 budgetId의 여행 인원 정보가 없습니다.")
    })
    @GetMapping("/budget/{budgetId}")
    public List<People> getPeopleByBudgetId(@PathVariable Long budgetId) {
        return peopleService.getPeopleByBudgetId(budgetId);
    }

    // 로그인한 사용자의 userId를 기준으로 인원 정보를 조회하는 API
    @Operation(summary = "로그인 사용자 여행 인원 조회", description = "로그인한 사용자의 userId를 기준으로 여행 인원 정보를 조회합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "로그인 사용자 여행 인원 조회 성공"),
            @ApiResponse(responseCode = "404", description = "해당 userId의 여행 인원 정보가 없습니다.")
    })
    @GetMapping("/users/{userId}")
    public List<People> getPeopleByUserId(@PathVariable Long userId) {
        return peopleService.getPeopleByUserId(userId);
    }

    // 로그인하지 않고 스킵한 게스트 사용자의 guestId를 기준으로 인원 정보를 조회하는 API
    @Operation(summary = "게스트 사용자 여행 인원 조회", description = "로그인 스킵한 게스트 사용자의 guestId를 기준으로 여행 인원 정보를 조회합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "게스트 사용자 여행 인원 조회 성공"),
            @ApiResponse(responseCode = "404", description = "해당 guestId의 여행 인원 정보가 없습니다.")
    })
    @GetMapping("/guests/{guestId}")
    public List<People> getPeopleByGuestId(@PathVariable String guestId) {
        return peopleService.getPeopleByGuestId(guestId);
    }

    // id를 기준으로 기존 인원 수를 수정하는 API
    @Operation(summary = "여행 인원 수정", description = "인원 ID를 기준으로 기존 여행 인원 수를 수정합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "여행 인원 수정 성공"),
            @ApiResponse(responseCode = "400", description = "잘못된 요청 데이터입니다."),
            @ApiResponse(responseCode = "404", description = "해당 ID의 여행 인원 정보가 없습니다.")
    })
    @PutMapping("/{id}")
    public People updatePeople(@PathVariable Long id, @RequestBody People peopleData) {
        return peopleService.updatePeople(id, peopleData);
    }

    // id를 기준으로 인원 정보를 삭제하는 API
    @Operation(summary = "여행 인원 삭제", description = "인원 ID를 기준으로 저장된 여행 인원 정보를 삭제합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "204", description = "여행 인원 삭제 성공"),
            @ApiResponse(responseCode = "404", description = "해당 ID의 여행 인원 정보가 없습니다.")
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletePeople(@PathVariable Long id) {
        peopleService.deletePeople(id);
        return ResponseEntity.noContent().build();
    }
}