package com.poc.usecase

import com.poc.model.car.Car
import com.poc.repository.car.CarRepository
import com.poc.repository.car.toEntity
import org.springframework.stereotype.Component

@Component
class CarUseCase(
    private val carRepository: CarRepository,
) {

    suspend fun list() = carRepository.findAll().map { it.toModel() }

    suspend fun create(car: Car) = carRepository.save(car.toEntity()).toModel()

}