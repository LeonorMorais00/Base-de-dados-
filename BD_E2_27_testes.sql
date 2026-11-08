-- Teste das restrições de integridade----


--RIA-12: capacidade_max tem de ser > 0
INSERT INTO recinto (nome, rua, código_postal, localidade, cidade, capacidade_max) 
VALUES ('Mini-Recinto', 'Rua 1', '1000-001', 'Lisboa', 'Lisboa', 0);
-- Criar um recinto com capacidade para zero pessoas 
--new row for relation "recinto" violates check constraint "ck_recinto"
--DETAIL: Failing row contains (Mini-Recinto, Rua 1, 1000-001, Lisboa, Lisboa, 0).



INSERT INTO utilizador (email, nome, data_nascimento, grupo_sanguíneo, contacto_emergência) 
VALUES ('andregmail.com', 'João', '1990-01-01', 'O+', 912345678);
--Email sem @ 
--new row for relation "utilizador" violates check constraint "ck_utilizador_em"
--DETAIL: Failing row contains (andregmail.com, João, 1990-01-01, O+, 912345678).


INSERT INTO utilizador (email, nome, data_nascimento, grupo_sanguíneo, contacto_emergência) 
VALUES ('maria@gmail.com', 'Maria', '1990-01-01', 'C+', 912345678);
-- Inserir utilizador com grupo sanguíneo que não existe neste caso C+ 
--new row for relation "utilizador" violates check constraint "ck_utilizador_sang"
--DETAIL: Failing row contains (maria@gmail.com, Maria, 1990-01-01, C+, 912345678).



INSERT INTO artista (nome, género_musical, tipo) 
VALUES ('Toy', 'Pimba', 'dupla');
-- Tentar criar um artista com um tipo não permitido (viola ck_artista)
--new row for relation "artista" violates check constraint "ck_artista"
--DETAIL: Failing row contains (Toy, Pimba, dupla).
--Tambem tenta criar uma dupla erro pois só há artista ou grupo viola a restrição ck_artista


INSERT INTO edição (festival, ano, recinto, preço_passe) 
VALUES ('Rock in Rio', '2024', 'Parque da Bela Vista', -50.00);
-- Preço de passe negativo (viola ck_edição_preço_passe)
--new row for relation "edição" violates check constraint "ck_edição_preço_passe"
--DETAIL: Failing row contains (Rock in Rio, 2024, Parque da Bela Vista, -50.00).


INSERT INTO dia (festival, ano, data, preço_diário) 
VALUES ('Rock in Rio', '2024', '2025-06-15', 50.00);
-- Tenta cria um dia do ano  de 2025 porém onde o festival é do ano 2024  (viola ck_dia_pertence_edição)
--new row for relation "dia" violates check constraint "ck_dia_pertence_edição"
--DETAIL: Failing row contains (Rock in Rio, 2024, 2025-06-15, 50.00).

INSERT INTO concerto (id_concerto, hora_início, hora_fim, artista, festival, ano, data)
VALUES ('C01', '23:00', '21:00', 'Muse', 'Rock in Rio', '2024', '2024-06-15');
-- Criar um concerto que começa a duas horas depois que acaba ou seja paradoxo (viola ck_concerto_horas)
--new row for relation "concerto" violates check constraint "ck_concerto_horas"
--DETAIL: Failing row contains (C01, 23:00:00, 21:00:00, Muse, Rock in Rio, 2024, 2024-06-15).


INSERT INTO dispositivo (n_série, saldo, estado, utilizador) 
VALUES (1234567891, 10.00, 'partido', 'kathia@gmail.com');
-- Tentar associar um estado inexistente que não existe  (viola ck_dispositivo_estado)
--new row for relation "dispositivo" violates check constraint "ck_dispositivo_estado"
--DETAIL: Failing row contains (1234567891, 10.00, partido, kathia@gmail.com).



INSERT INTO festival (nome, ano_criação) VALUES ('NOS Alive', 2007);
INSERT INTO festival (nome, ano_criação) VALUES ('NOS Alive', 2024);
-- Festivais com o mesmo nome(viola pk_festival / UNIQUE)
--duplicate key value violates unique constraint "pk_festival"
--DETAIL: Key (nome)=(NOS Alive) already exists.




INSERT INTO festival (nome, ano_criação) 
VALUES ('Paredes de Coura', NULL);
-- Tentar inserir um festival sem indicar o ano de criação (viola NOT NULL)
--null value in column "ano_criação" of relation "festival" violates not-null constraint
--DETAIL: Failing row contains (Paredes de Coura, null).




INSERT INTO edição (festival, ano, recinto, preço_passe) 
VALUES ('Festival Falso', '2024', 'Parque da Bela Vista', 100.00);
-- Tentar criar uma edição para um festival que não existe na tabela "festival" (viola fk_edição_festival)
--insert or update on table "edição" violates foreign key constraint "fk_edição_festival"
--DETAIL: Key (festival)=(Festival Falso) is not present in table "festival".


INSERT INTO concerto (id_concerto, hora_início, hora_fim, artista, festival, ano, data)
VALUES ('C02', '21:00', '23:00', 'Artista Fantasma', 'NOS Alive', '2024', '2024-07-10');

-- Tentar inserir um concerto sem um artista existente na tabela "artista" (viola fk_concerto_artista)
--insert or update on table "concerto" violates foreign key constraint "fk_concerto_artista"
--DETAIL: Key (artista)=(Artista Fantasma) is not present in table "artista".
