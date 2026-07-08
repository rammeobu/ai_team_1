    package com.bootcamp.bootcamp.controller;

    import com.bootcamp.bootcamp.entity.User;
    import com.bootcamp.bootcamp.service.userservice;
    import io.swagger.v3.oas.annotations.Operation;
    import io.swagger.v3.oas.annotations.responses.ApiResponse;
    import io.swagger.v3.oas.annotations.responses.ApiResponses;
    import lombok.RequiredArgsConstructor;
    import org.springframework.http.ResponseEntity;
    import org.springframework.web.bind.annotation.*;

    @RestController
    @RequestMapping("/api/v1")
    @RequiredArgsConstructor

    public class Usercontroller {
        private final userservice userservice;
        @Operation(summary = "유저조회",description = "특정 유저 조회")
        @ApiResponses({
                @ApiResponse(responseCode = "200", description = "유저조회 완료"),
                @ApiResponse(responseCode = "204", description = "유저 없음")
            }
        )
        @GetMapping("/{id}")
        public ResponseEntity<User> getUser(@PathVariable Long id){
            return ResponseEntity.ok(userservice.getuser(id));
        }

        @Operation(summary = "유저업데이트",description = "특정 유저 업데이트")
        @ApiResponses({
                @ApiResponse(responseCode = "200", description = "유저 업데이트 완료"),
                @ApiResponse(responseCode = "5oo", description = "업데이트 실패")
        }
        )
        @PutMapping("/{id}")
        public ResponseEntity<User> updateUser(@PathVariable Long id, @RequestBody User user){
            return ResponseEntity.ok(userservice.updateuser(user));
        }
        @Operation(summary = "유저삭제",description = "특정 유저 삭제 ")
        @ApiResponses({
                @ApiResponse(responseCode = "200", description = "유저 삭제 완료"),
        }
        )
        @DeleteMapping("/{id}")
        public ResponseEntity<User> deleteUser(@PathVariable Long id){
            User user = userservice.getuser(id);
            userservice.deleteuser(user);
            return ResponseEntity.ok(user);
        }


    }
