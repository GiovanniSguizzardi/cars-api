package br.com.fiap.cars_api.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping()
public class FerrariController {

    @GetMapping("purosangue")
    public String purosangue() {
        return "Ferrari Purosangue | V12 - 725CV";
    }
}
