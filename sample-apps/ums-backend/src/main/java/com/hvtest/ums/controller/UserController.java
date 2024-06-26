package com.hvtest.ums.controller;

//import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.hvtest.ums.dto.ResponseDto;
import com.hvtest.ums.dto.UserDto;
import com.hvtest.ums.service.IUserService;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import jakarta.validation.Valid;

@RestController
@Validated
@RequestMapping(path="/api/v1/", produces = {MediaType.APPLICATION_JSON_VALUE})
public class UserController {
    
    private static final Logger logger = LoggerFactory.getLogger(UserController.class);

    private final IUserService iUserService;

    public UserController(IUserService iUserService) {
        this.iUserService = iUserService;
    }

    @Value("${spring.application.name}")
    private String appName;

    @Value("${spring.profiles.active}")
    private String activeProfile;

    @Value("${myapp.harnessbuildversion}")
    private String harnessbuildversion;

    @Value("${myapp.harnessffsdkkey}")
    private String harnessffsdkkey;

    @Value("#{systemProperties['java.runtime.version'] ?: 'some java version'}")
    private String javaRuntimeVersion;

    @Value("#{systemProperties['java.runtime.name'] ?: 'some java name'}")
    private String javaRuntimeName;

    @Value("${myapp.javahome}")
    private String javaHome;

    @Value("${myapp.hostname}")
    private String hostName;

    @Value("${server.port}")
    private String port;

    @Value("#{systemProperties['os.arch'] ?: 'some os arch'}")
    private String osArch;

    @Value("#{systemProperties['os.version'] ?: 'some os version'}")
    private String osVersion;

    @GetMapping("/configinfo")
    public ResponseEntity<Map<String, Object>> getConfigInfo() {

        Map<String, Object> configInfo = new HashMap<String, Object>();
        configInfo.put("appName", appName);
        configInfo.put("activeProfile", activeProfile);
        configInfo.put("harnessBuildVersion", harnessbuildversion);
        configInfo.put("harnessFFSDKKey", harnessffsdkkey);
        configInfo.put("javaRuntimeVersion", javaRuntimeVersion);
        configInfo.put("javaRuntimeName", javaRuntimeName);
        configInfo.put("javaHome", javaHome);
        configInfo.put("hostName", hostName);
        configInfo.put("port", port);
        configInfo.put("osArch", osArch);
        configInfo.put("osVersion", osVersion);

        return ResponseEntity
                .status(HttpStatus.OK)
                .body(configInfo);
    }

    @PostMapping("/create")
    public ResponseEntity<ResponseDto> createUser(@Valid @RequestBody UserDto userDto) {
        
        logger.debug("User creation request started");
        iUserService.createUser(userDto);
        logger.debug("User creation request completed");
        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body(new ResponseDto("200", "User created successfully"));
    }    

    @PutMapping("/update")
    public ResponseEntity<ResponseDto> updateUser(@Valid @RequestBody UserDto userDto) {
        
        logger.debug("User update request started");
        boolean isUpdated = iUserService.updateUser(userDto);
        logger.debug("User update request completed");
        if(isUpdated) {
            return ResponseEntity
                    .status(HttpStatus.OK)
                    .body(new ResponseDto("200", "User updated successfully"));
        }else{
            return ResponseEntity
                    .status(HttpStatus.OK)
                    .body(new ResponseDto("417", "User update failed"));
        }
    }

    @DeleteMapping("/delete")
    public ResponseEntity<ResponseDto> deleteUser(@Valid @RequestParam String email) {
        
        logger.debug("User deletion request started");
        boolean isDeleted = iUserService.deleteUser(email);
        logger.debug("User deletion request completed");
        if(isDeleted) {
            return ResponseEntity
                    .status(HttpStatus.OK)
                    .body(new ResponseDto("200", "User deleted successfully"));
        }else{
            return ResponseEntity
                    .status(HttpStatus.OK)
                    .body(new ResponseDto("417", "User deletion failed"));
        }
    }

    // GET /api/v1/fetch?email=xyz@xyz.com
    @GetMapping("/fetch")
    public ResponseEntity<UserDto> fetchUser(@Valid @RequestParam String email) {
        
        logger.debug("User fetch request started");
        UserDto userDto = iUserService.fetchUser(email);
        logger.debug("User fetch request completed");
        return ResponseEntity
                .status(HttpStatus.OK)
                .body(userDto);
    }

    // GET /api/v1/fetch/all
    @GetMapping("/fetch/all")
    public ResponseEntity<List<UserDto>> fetchAllUsers() {

        logger.debug("User fetch all request started");
        List<UserDto> userDtos = iUserService.fetchAllUsers();
        logger.debug("User fetch all request completed");
        return ResponseEntity
                .status(HttpStatus.OK)
                .body(userDtos);
    }
    
}
