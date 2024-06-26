package com.hvtest.ums.mapper;

import com.hvtest.ums.dto.UserDto;
import com.hvtest.ums.entity.UserEntity;

public class UserMapper {
    
    public static UserDto mapToUserDto(UserEntity user, UserDto userDto) {
        userDto.setName(user.getName());
        userDto.setEmail(user.getEmail());
        userDto.setPhone(user.getPhone());
        return userDto;
    }

    public static UserEntity mapToUser(UserDto userDto, UserEntity user) {
        user.setName(userDto.getName());
        user.setEmail(userDto.getEmail());
        user.setPhone(userDto.getPhone());
        return user;
    }
}
