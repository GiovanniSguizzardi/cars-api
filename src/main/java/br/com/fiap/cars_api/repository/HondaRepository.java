package br.com.fiap.cars_api.repository;

import br.com.fiap.cars_api.model.Honda;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface HondaRepository extends JpaRepository<Honda, Long> {

}
