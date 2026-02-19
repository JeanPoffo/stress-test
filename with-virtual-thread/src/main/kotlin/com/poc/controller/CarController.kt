package com.poc.controller

import com.poc.model.car.Car
import com.poc.usecase.CarUseCase
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RestController

@RestController
class CarController(
    private val carUseCase: CarUseCase,
) {

    @GetMapping("/cars")
    fun get() = carUseCase.list().also { println(Thread.currentThread()) }

    @PostMapping("/cars")
    fun save(@RequestBody car: Car) = carUseCase.create(car).also { println(Thread.currentThread()) }
}
