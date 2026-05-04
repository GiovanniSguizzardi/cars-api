package br.com.fiap.cars_api.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "honda")
public class Honda {

    @Id
    private Long id;

    @Column(name= "modelo_carros", length = 100,
            columnDefinition="char(100)", nullable = false)
    private String modelo;

    @Column(name= "ano_carros", length = 100,
            columnDefinition="char(100)", nullable = false)
    private String ano;

    @Column(name= "potencia_carros", length = 100,
            columnDefinition="char(100)", nullable = false)
    private String potencia;

    @Column(name= "cor_carros", length = 100,
            columnDefinition="char(100)", nullable = false)
    private String cor;

    @Column(name= "nome_ex_dono_carros", length = 100,
            columnDefinition="char(100)", nullable = true)
    private String ex_dono_carro;


    // Getters and Setters

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getModelo() {
        return modelo;
    }

    public void setModelo(String modelo) {
        this.modelo = modelo;
    }
}
