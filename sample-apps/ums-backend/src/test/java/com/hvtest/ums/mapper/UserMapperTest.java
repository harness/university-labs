package com.hvtest.ums.mapper;

import com.hvtest.ums.dto.UserDto;
import com.hvtest.ums.entity.UserEntity;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

class UserMapperTest {

    @Test
    void testMapToUserDto() {
        // Create a sample UserEntity
        UserEntity userEntity = new UserEntity();
        userEntity.setName("John Doe");
        userEntity.setEmail("john.doe@example.com");
        userEntity.setPhone("123-456-7890");

        // Create an empty UserDto
        UserDto userDto = new UserDto();

        // Call the mapToUserDto method
        UserDto mappedUserDto = UserMapper.mapToUserDto(userEntity, userDto);

        // Verify the mapping
        assertEquals("John Doe", mappedUserDto.getName());
        assertEquals("john.doe@example.com", mappedUserDto.getEmail());
        assertEquals("123-456-7890", mappedUserDto.getPhone());
    }

    @Test
    void testMapToUser() {
        // Create a sample UserDto
        UserDto userDto = new UserDto();
        userDto.setName("Jane Doe");
        userDto.setEmail("jane.doe@example.com");
        userDto.setPhone("987-654-3210");

        // Create an empty UserEntity
        UserEntity userEntity = new UserEntity();

        // Call the mapToUser method
        UserEntity mappedUserEntity = UserMapper.mapToUser(userDto, userEntity);

        // Verify the mapping
        assertEquals("Jane Doe", mappedUserEntity.getName());
        assertEquals("jane.doe@example.com", mappedUserEntity.getEmail());
        assertEquals("987-654-3210", mappedUserEntity.getPhone());
    }
}
