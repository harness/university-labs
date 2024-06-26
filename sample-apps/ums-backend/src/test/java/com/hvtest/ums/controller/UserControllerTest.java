package com.hvtest.ums.controller;

import com.hvtest.ums.dto.ResponseDto;
import com.hvtest.ums.dto.UserDto;
import com.hvtest.ums.service.IUserService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.Mockito;
import org.mockito.MockitoAnnotations;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import java.util.Collections;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.when;

class UserControllerTest {

    @Mock
    private IUserService userService;

    @InjectMocks
    private UserController userController;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    void testCreateUser() {
        // Create a sample UserDto for testing
        UserDto userDto = new UserDto(); 

        // No need to use "when" for void methods, use verify instead
        Mockito.doNothing().when(userService).createUser(any(UserDto.class));

        ResponseEntity<ResponseDto> response = userController.createUser(userDto);

        // Assert the HTTP status code and response message
        assertEquals(HttpStatus.CREATED, response.getStatusCode());
        assertEquals("200", response.getBody().getStatusCode());
        assertEquals("User created successfully", response.getBody().getStatusMsg());

        // Verify that the createUser method is called with the provided UserDto
        Mockito.verify(userService, Mockito.times(1)).createUser(userDto);
    }

    @Test
    void testUpdateUser() {
        UserDto userDto = new UserDto(); // Create a sample UserDto for testing
        when(userService.updateUser(any(UserDto.class))).thenReturn(true);

        ResponseEntity<ResponseDto> response = userController.updateUser(userDto);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertEquals("200", response.getBody().getStatusCode());
        assertEquals("User updated successfully", response.getBody().getStatusMsg());

        Mockito.verify(userService, Mockito.times(1)).updateUser(userDto);
    }

    @Test
    void testDeleteUser() {
        String sampleEmail = "test@example.com";
        when(userService.deleteUser(eq(sampleEmail))).thenReturn(true);

        ResponseEntity<ResponseDto> response = userController.deleteUser(sampleEmail);

        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertEquals("200", response.getBody().getStatusCode());
        assertEquals("User deleted successfully", response.getBody().getStatusMsg());

        Mockito.verify(userService, Mockito.times(1)).deleteUser(sampleEmail);
    }

    @Test
    void testFetchUser() {
        String sampleEmail = "test@example.com";
        UserDto sampleUserDto = new UserDto(); // Create a sample UserDto for testing
        when(userService.fetchUser(eq(sampleEmail))).thenReturn(sampleUserDto);

        ResponseEntity<UserDto> response = userController.fetchUser(sampleEmail);

        assertEquals(HttpStatus.OK, response.getStatusCode());
    }

    @Test
    void testFetchAllUsers() {
        List<UserDto> sampleUserList = Collections.singletonList(new UserDto()); // Create a sample list for testing
        when(userService.fetchAllUsers()).thenReturn(sampleUserList);

        ResponseEntity<List<UserDto>> response = userController.fetchAllUsers();

        assertEquals(HttpStatus.OK, response.getStatusCode());
    }
}
