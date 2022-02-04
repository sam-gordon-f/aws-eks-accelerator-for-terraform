package main

deny[__message] {
    __message := "test2 failed"

    true == true
}