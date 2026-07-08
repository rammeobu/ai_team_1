package com.bootcamp.bootcamp.repository;

import com.bootcamp.bootcamp.dto.Provider;
import com.bootcamp.bootcamp.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface Userrepository extends JpaRepository<User,Long> {
    Optional<User> findByProviderAndProviderId(Provider provider, String providerId);
}