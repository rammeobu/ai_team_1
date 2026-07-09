package com.bootcamp.bootcamp.controller;

import com.bootcamp.bootcamp.entity.Requireditem;
import com.bootcamp.bootcamp.entity.Requireditemdetail;
import com.bootcamp.bootcamp.service.Requireditemservice;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/required-items")
@RequiredArgsConstructor
public class Requireditemcontroller {

    private final Requireditemservice requireditemService;

    @Operation(summary = "필수 항목 묶음 저장", description = "한 사람의 한 여행에 대한 필수 항목 묶음을 저장합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "필수 항목 묶음 저장 성공"),
            @ApiResponse(responseCode = "400", description = "잘못된 요청 데이터입니다.")
    })
    @PostMapping
    public Requireditem createRequireditem(@RequestBody Requireditem requireditemData) {
        return requireditemService.createRequireditem(requireditemData);
    }

    @Operation(summary = "아이콘별 필수 항목 저장/수정", description = "항공권, 호텔, 서류, 추가 아이콘 요청을 같은 여행 묶음 ID 아래에 저장하거나 수정합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "아이콘별 필수 항목 저장 또는 수정 성공"),
            @ApiResponse(responseCode = "400", description = "잘못된 요청 데이터입니다.")
    })
    @PostMapping("/icon")
    public Requireditemdetail saveIconRequireditem(@RequestBody Requireditemdetail requireditemdetailData) {
        return requireditemService.saveIconRequireditem(requireditemdetailData);
    }

    @Operation(summary = "전체 필수 항목 묶음 조회", description = "DB에 저장된 모든 필수 항목 묶음을 조회합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "전체 필수 항목 묶음 조회 성공")
    })
    @GetMapping
    public List<Requireditem> getAllRequireditem() {
        return requireditemService.getAllRequireditem();
    }

    @Operation(summary = "특정 필수 항목 묶음 조회", description = "필수 항목 묶음 ID를 기준으로 조회합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "특정 필수 항목 묶음 조회 성공"),
            @ApiResponse(responseCode = "404", description = "해당 ID의 필수 항목 묶음 정보가 없습니다.")
    })
    @GetMapping("/{id}")
    public Requireditem getRequireditem(@PathVariable Long id) {
        return requireditemService.getRequireditem(id);
    }

    @Operation(summary = "여행 일정별 필수 항목 묶음 조회", description = "travelplanId를 기준으로 필수 항목 묶음을 조회합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "여행 일정별 필수 항목 묶음 조회 성공")
    })
    @GetMapping("/travel-plan/{travelplanId}")
    public List<Requireditem> getRequireditemByTravelplanId(@PathVariable Long travelplanId) {
        return requireditemService.getRequireditemByTravelplanId(travelplanId);
    }

    @Operation(summary = "로그인 사용자 필수 항목 묶음 조회", description = "userId를 기준으로 필수 항목 묶음을 조회합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "로그인 사용자 필수 항목 묶음 조회 성공")
    })
    @GetMapping("/users/{userId}")
    public List<Requireditem> getRequireditemByUserId(@PathVariable Long userId) {
        return requireditemService.getRequireditemByUserId(userId);
    }

    @Operation(summary = "게스트 사용자 필수 항목 묶음 조회", description = "guestId를 기준으로 필수 항목 묶음을 조회합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "게스트 사용자 필수 항목 묶음 조회 성공")
    })
    @GetMapping("/guests/{guestId}")
    public List<Requireditem> getRequireditemByGuestId(@PathVariable String guestId) {
        return requireditemService.getRequireditemByGuestId(guestId);
    }

    @Operation(summary = "필수 항목 묶음 안의 아이콘 상세 조회", description = "requireditemId를 기준으로 항공권, 호텔, 서류, 추가 상세 정보를 조회합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "필수 항목 상세 조회 성공")
    })
    @GetMapping("/{requireditemId}/details")
    public List<Requireditemdetail> getDetailsByRequireditemId(@PathVariable Long requireditemId) {
        return requireditemService.getDetailsByRequireditemId(requireditemId);
    }

    @Operation(summary = "여행 일정별 아이콘 상세 조회", description = "travelplanId를 기준으로 아이콘별 상세 정보를 조회합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "여행 일정별 아이콘 상세 조회 성공")
    })
    @GetMapping("/details/travel-plan/{travelplanId}")
    public List<Requireditemdetail> getDetailsByTravelplanId(@PathVariable Long travelplanId) {
        return requireditemService.getDetailsByTravelplanId(travelplanId);
    }

    @Operation(summary = "아이콘 종류별 상세 조회", description = "FLIGHT, HOTEL, DOCUMENT, EXTRA 기준으로 상세 정보를 조회합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "아이콘 종류별 상세 조회 성공")
    })
    @GetMapping("/details/type/{itemType}")
    public List<Requireditemdetail> getDetailsByItemType(@PathVariable String itemType) {
        return requireditemService.getDetailsByItemType(itemType);
    }

    @Operation(summary = "아이콘 상태별 상세 조회", description = "NOT_STARTED, SEARCHED, SELECTED, COMPLETED 기준으로 상세 정보를 조회합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "아이콘 상태별 상세 조회 성공")
    })
    @GetMapping("/details/status/{itemStatus}")
    public List<Requireditemdetail> getDetailsByItemStatus(@PathVariable String itemStatus) {
        return requireditemService.getDetailsByItemStatus(itemStatus);
    }

    @Operation(summary = "특정 아이콘 상세 조회", description = "아이콘 상세 ID를 기준으로 상세 정보를 조회합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "특정 아이콘 상세 조회 성공"),
            @ApiResponse(responseCode = "404", description = "해당 ID의 아이콘 상세 정보가 없습니다.")
    })
    @GetMapping("/details/{id}")
    public Requireditemdetail getRequireditemdetail(@PathVariable Long id) {
        return requireditemService.getRequireditemdetail(id);
    }

    @Operation(summary = "아이콘 상세 수정", description = "아이콘 상세 ID를 기준으로 상세 정보를 수정합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "아이콘 상세 수정 성공"),
            @ApiResponse(responseCode = "404", description = "해당 ID의 아이콘 상세 정보가 없습니다.")
    })
    @PutMapping("/details/{id}")
    public Requireditemdetail updateRequireditemdetail(@PathVariable Long id, @RequestBody Requireditemdetail requireditemdetailData) {
        return requireditemService.updateRequireditemdetail(id, requireditemdetailData);
    }

    @Operation(summary = "필수 항목 묶음 삭제", description = "필수 항목 묶음 ID를 기준으로 묶음과 하위 상세 정보를 함께 삭제합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "204", description = "필수 항목 묶음 삭제 성공"),
            @ApiResponse(responseCode = "404", description = "해당 ID의 필수 항목 묶음 정보가 없습니다.")
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteRequireditem(@PathVariable Long id) {
        requireditemService.deleteRequireditem(id);
        return ResponseEntity.noContent().build();
    }

    @Operation(summary = "아이콘 상세 삭제", description = "아이콘 상세 ID를 기준으로 상세 정보를 삭제합니다.")
    @ApiResponses({
            @ApiResponse(responseCode = "204", description = "아이콘 상세 삭제 성공"),
            @ApiResponse(responseCode = "404", description = "해당 ID의 아이콘 상세 정보가 없습니다.")
    })
    @DeleteMapping("/details/{id}")
    public ResponseEntity<Void> deleteRequireditemdetail(@PathVariable Long id) {
        requireditemService.deleteRequireditemdetail(id);
        return ResponseEntity.noContent().build();
    }
}