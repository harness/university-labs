package com.hvtest.ums.service;

import java.util.List;
import java.util.Optional;

import org.springframework.stereotype.Service;

import com.hvtest.ums.dto.UserDto;
import com.hvtest.ums.entity.UserEntity;
import com.hvtest.ums.mapper.UserMapper;
import com.hvtest.ums.repository.IUserRepository;

import lombok.AllArgsConstructor;

@Service
@AllArgsConstructor
public class UserServiceImpl implements IUserService {

    private IUserRepository userRepository;
    
    @Override
    public void createUser(UserDto userDto) {
        Optional<UserEntity> optionalUser = userRepository.findByEmail(userDto.getEmail());
        if(optionalUser.isPresent()) {
            throw new RuntimeException("User already exists with email " + userDto.getEmail());
        }
        UserEntity user = UserMapper.mapToUser(userDto, new UserEntity());
        userRepository.save(user);
    }

    @Override
    public UserDto fetchUser(String email) {
        UserEntity user = userRepository.findByEmail(email).orElseThrow(
            () -> new RuntimeException("User not found with email " + email)
        );
        UserDto UserDto = UserMapper.mapToUserDto(user, new UserDto());
        return UserDto;
    }

    @Override
    public boolean updateUser(UserDto userDto) {
        boolean isUpdated = false;
        UserEntity user = userRepository.findByEmail(userDto.getEmail()).orElseThrow(
            () -> new RuntimeException("User not found with email " + userDto.getEmail())
        );
        UserMapper.mapToUser(userDto, user);
        userRepository.save(user);
        isUpdated = true;
        return isUpdated;
    }

    @Override
    public boolean deleteUser(String email) {
        UserEntity user = userRepository.findByEmail(email).orElseThrow(
            () -> new RuntimeException("User not found with email " + email)
        );
        userRepository.delete(user);
        return true;
    }

    @Override
    public List<UserDto> fetchAllUsers() {
        List<UserEntity> users = userRepository.findAll();
        List<UserDto> userDtos = users.stream().map(user -> UserMapper.mapToUserDto(user, new UserDto())).toList();
        return userDtos;
    }
    
}
