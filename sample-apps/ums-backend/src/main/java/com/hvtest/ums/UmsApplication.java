package com.hvtest.ums;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;


@SpringBootApplication
@EnableJpaAuditing(auditorAwareRef = "auditAwareImpl")
public class UmsApplication {


	
	public static void main(String[] args) {
		SpringApplication.run(UmsApplication.class, args);

	}

}
