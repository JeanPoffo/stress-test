package com.poc

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class WithCoroutine

fun main(args: Array<String>): Unit = run { runApplication<WithCoroutine>(*args) }
