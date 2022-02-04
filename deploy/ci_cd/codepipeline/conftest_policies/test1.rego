package main

deny[__message] {
    __message := "test1 failed"

    true != true
}