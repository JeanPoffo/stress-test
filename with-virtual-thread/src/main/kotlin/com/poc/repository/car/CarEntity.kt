package com.poc.repository.car

import com.poc.model.car.Car
import jakarta.persistence.Entity
import jakarta.persistence.GeneratedValue
import jakarta.persistence.GenerationType.IDENTITY
import jakarta.persistence.Id
import jakarta.persistence.Table

@Table
@Entity(name = "car_entity")
data class CarEntity(
    @Id
    @GeneratedValue(strategy = IDENTITY)
    val id: Long? = null,
    val name: String,
    val manufacture: String,
    val year: Int,
) {

    fun toModel(): Car = Car(
        id = id!!,
        name = name,
        manufacture = manufacture,
        year = year,
    )
}

fun Car.toEntity() = CarEntity(
    id = id,
    name = name,
    manufacture = manufacture,
    year = year,
)
