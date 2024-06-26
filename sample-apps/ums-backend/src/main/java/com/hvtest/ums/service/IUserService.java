package com.hvtest.ums.service;

import java.util.List;

import com.hvtest.ums.dto.UserDto;

public interface IUserService {
    
    void createUser(UserDto userDto);

    UserDto fetchUser(String email);

    List<UserDto> fetchAllUsers();

    boolean updateUser(UserDto userDto);

    boolean deleteUser(String email);
}
