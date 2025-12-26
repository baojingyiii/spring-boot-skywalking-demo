package com.baojingyi.prom.controller;


import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class hellocontroller {
    @GetMapping("/hello")
    public String Hello(){
        return "hello";
    }

}

