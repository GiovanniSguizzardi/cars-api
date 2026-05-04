package br.com.fiap.cars_api.controller;

import br.com.fiap.cars_api.model.Renault;
import br.com.fiap.cars_api.repository.RenaultRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("api/${api.version}/renault")
public class RenaultController {

    @Autowired
    private RenaultRepository repository;

    @PostMapping
    public ResponseEntity<Renault> create(@RequestBody Renault renault) {
        return ResponseEntity.status(HttpStatus.CREATED).body(repository.save(renault));
    }

    @GetMapping("/{id}")
    public ResponseEntity<Renault> findById(@PathVariable Long id) {
        return repository
                .findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping
    public ResponseEntity<List<Renault>> findAll() {
        return ResponseEntity.ok(repository.findAll());
    }

    @PutMapping("/{id}")
    public ResponseEntity<Renault> update(@PathVariable Long id,
                                        @RequestBody Renault renault) {

        Optional<Renault> optRenault = repository.findById(id);

        if (optRenault.isPresent()) {
            renault.setId(id);
            Renault marcaRenaultAlterada = repository.save(renault);
            return ResponseEntity.ok(marcaRenaultAlterada);
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteById(@PathVariable Long id) {
        repository.deleteById(id);
        return ResponseEntity.noContent().build();

    }
}
