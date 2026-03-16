package br.com.fiap.cars_api.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping()
public class HondaController {

    @GetMapping("honda")
    public String honda() {
        return "Bem-vindo a Honda!";
    }

    @GetMapping("honda/civic")
    public String hondacivic() {
        return "Honda Civic | 184CV";
    }

}
