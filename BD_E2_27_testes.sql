
SET search_path TO bd027_schema;
-- Teste das restrições de integridade----

-- RIA-12: capacidade_max tem de ser > 0
-- Erro esperado: new row for relation "recinto" violates check constraint "ck_recinto"
INSERT INTO recinto (nome, rua, código_postal, localidade, cidade, capacidade_max)
VALUES ('Mini-Recinto', 'Rua 1', '1000-001', 'Lisboa', 'Lisboa', 0);

-- Email sem @
-- Erro esperado: new row for relation "utilizador" violates check constraint "ck_utilizador_em"
INSERT INTO utilizador (email, nome, data_nascimento, grupo_sanguíneo, contacto_emergência)
VALUES ('andregmail.com', 'João', '1990-01-01', 'O+', 912345678);

-- Grupo sanguíneo inexistente (C+)
-- Erro esperado: new row for relation "utilizador" violates check constraint "ck_utilizador_sang"
INSERT INTO utilizador (email, nome, data_nascimento, grupo_sanguíneo, contacto_emergência)
VALUES ('maria@gmail.com', 'Maria', '1990-01-01', 'C+', 912345678);

-- RIA-3: tipo de artista só pode ser 'artista' ou 'grupo' (aqui 'dupla')
-- Erro esperado: new row for relation "artista" violates check constraint "ck_artista"
INSERT INTO artista (nome, género_musical, tipo)
VALUES ('Toy', 'Pimba', 'dupla');

-- RIA-12: preço do passe negativo
-- Erro esperado: new row for relation "edição" violates check constraint "ck_edição_preço_passe"
INSERT INTO edição (festival, ano, recinto, preço_passe)
VALUES ('NOS Alive', '2022', 'Parque da Bela Vista', -50.00);

-- RIA-1: a data (2024) não pertence ao ano da edição (2025)
-- Erro esperado: new row for relation "dia" violates check constraint "ck_dia_pertence_edição"
INSERT INTO dia (festival, ano, data, preço_diário)
VALUES ('NOS Alive', '2025', '2024-06-15', 50.00);

-- RIA-2: hora_início posterior a hora_fim
-- Erro esperado: new row for relation "concerto" violates check constraint "ck_concerto_horas"
INSERT INTO concerto (id_concerto, hora_início, hora_fim, artista, festival, ano, data)
VALUES ('C01', '23:00', '21:00', 'Katy Perry', 'NOS Alive', '2025', '2025-07-11');

-- RIA-7: estado de dispositivo inexistente ('partido')
-- Erro esperado: new row for relation "dispositivo" violates check constraint "ck_dispositivo_estado"
INSERT INTO dispositivo (n_série, saldo, estado, utilizador)
VALUES (7, 10.00, 'partido', 'miguel@gmail.com');


-- Festival com nome repetido
-- Erro esperado: duplicate key value violates unique constraint "pk_festival"
INSERT INTO festival (nome, ano_criação) VALUES ('NOS Alive', 2024);


-- Festival sem ano de criação
-- Erro esperado: null value in column "ano_criação" of relation "festival" violates not-null constraint
INSERT INTO festival (nome, ano_criação) VALUES ('Paredes de Coura', NULL);


-- Edição de um festival que não existe
-- Erro esperado: insert or update on table "edição" violates foreign key constraint "fk_edição_festival"
INSERT INTO edição (festival, ano, recinto, preço_passe)
VALUES ('Festival Falso', '2024', 'Parque da Bela Vista', 100.00);

-- Concerto de um artista que não existe
-- Erro esperado: insert or update on table "concerto" violates foreign key constraint "fk_concerto_artista"
INSERT INTO concerto (id_concerto, hora_início, hora_fim, artista, festival, ano, data)
VALUES ('C02', '21:00', '23:00', 'Artista Fantasma', 'NOS Alive', '2025', '2025-07-10');

-- RIA-11: um utilizador não pode seguir-se a si próprio
-- Erro esperado: new row for relation "segue" violates check constraint "ck_segue"
INSERT INTO segue (seguidor, seguido) VALUES ('miguel@gmail.com', 'miguel@gmail.com');

-- RIA-7: saldo do dispositivo não pode ser negativo
-- Erro esperado: new row for relation "dispositivo" violates check constraint "ck_dispositvo_saldo"
INSERT INTO dispositivo (n_série, saldo, estado, utilizador)
VALUES (8, -5.00, 'ativo', 'miguel@gmail.com');

-- RIA-12: preço diário tem de ser > 0
-- Erro esperado: new row for relation "dia" violates check constraint "ck_dia_preço_diário"
INSERT INTO dia (festival, ano, data, preço_diário)
VALUES ('NOS Alive', '2025', '2025-07-13', 0);

-- Erro esperado: duplicate key value violates unique constraint "pk_recinto"
INSERT INTO recinto (nome, rua, código_postal, localidade, cidade, capacidade_max)
VALUES ('Parque da Bela Vista', 'Rua 2', '1000-002', 'Lisboa', 'Lisboa', 1000);

-- Erro esperado: duplicate key value violates unique constraint "pk_utilizador"
INSERT INTO utilizador (email, nome, data_nascimento, grupo_sanguíneo, contacto_emergência)
VALUES ('miguel@gmail.com', 'Outro Miguel', '2000-01-01', 'A+', 911111111);

-- Erro esperado: duplicate key value violates unique constraint "pk_alergia_multivalor"
INSERT INTO alergia_multivalor (email, alergia) VALUES ('miguel@gmail.com', 'camarão');

-- Erro esperado: duplicate key value violates unique constraint "pk_segue"
INSERT INTO segue (seguidor, seguido) VALUES ('miguel@gmail.com', 'luisa@gmail.com');

-- Erro esperado: duplicate key value violates unique constraint "pk_artista"
INSERT INTO artista (nome, género_musical, tipo) VALUES ('Katy Perry', 'pop', 'artista');

-- Erro esperado: duplicate key value violates unique constraint "pk_edição"
INSERT INTO edição (festival, ano, recinto, preço_passe)
VALUES ('NOS Alive', '2025', 'Parque da Bela Vista', 100.00);

-- Erro esperado: duplicate key value violates unique constraint "pk_dia"
INSERT INTO dia (festival, ano, data, preço_diário)
VALUES ('NOS Alive', '2025', '2025-07-10', 50.00);

-- Erro esperado: duplicate key value violates unique constraint "pk_concerto"
INSERT INTO concerto (id_concerto, hora_início, hora_fim, artista, festival, ano, data)
VALUES ('1111', '18:00', '19:00', 'Lorde', 'NOS Alive', '2025', '2025-07-11');

-- Erro esperado: duplicate key value violates unique constraint "pk_dispositivo"
INSERT INTO dispositivo (n_série, saldo, estado, utilizador)
VALUES (1111, 10.00, 'ativo', 'miguel@gmail.com');

-- Erro esperado: duplicate key value violates unique constraint "pk_bilhete"
INSERT INTO bilhete (id_bilhete, data_compra, comprador, dispositivo)
VALUES (1, '2025-01-01', 'miguel@gmail.com', NULL);

-- Erro esperado: duplicate key value violates unique constraint "pk_passe_geral"
INSERT INTO passe_geral (id_bilhete, festival, ano) VALUES (1, 'NOS Alive', '2025');

-- Erro esperado: duplicate key value violates unique constraint "pk_bilhete_diário"
INSERT INTO bilhete_diário (id_bilhete, festival, ano, data)
VALUES (4, 'NOS Alive', '2025', '2025-07-10');

-- Erro esperado: violates foreign key constraint "fk_alergia_multivalor"
INSERT INTO alergia_multivalor (email, alergia) VALUES ('inexistente@gmail.com', 'pólen');

-- Erro esperado: violates foreign key constraint "fk_segue_seguidor"
INSERT INTO segue (seguidor, seguido) VALUES ('inexistente@gmail.com', 'luisa@gmail.com');

-- Erro esperado: violates foreign key constraint "fk_segue_seguido"
INSERT INTO segue (seguidor, seguido) VALUES ('miguel@gmail.com', 'inexistente@gmail.com');

-- Erro esperado: violates foreign key constraint "fk_edição_recinto"
INSERT INTO edição (festival, ano, recinto, preço_passe)
VALUES ('NOS Alive', '2022', 'Recinto Fantasma', 100.00);

-- Edição 2022 do NOS Alive não existe
-- Erro esperado: violates foreign key constraint "fk_dia_edição"
INSERT INTO dia (festival, ano, data, preço_diário)
VALUES ('NOS Alive', '2022', '2022-07-10', 50.00);

-- O dia 2025-12-31 não existe
-- Erro esperado: violates foreign key constraint "fk_concerto_dia"
INSERT INTO concerto (id_concerto, hora_início, hora_fim, artista, festival, ano, data)
VALUES ('C03', '21:00', '22:00', 'Lorde', 'NOS Alive', '2025', '2025-12-31');

-- Erro esperado: violates foreign key constraint "fk_dispositivo_utilizador"
INSERT INTO dispositivo (n_série, saldo, estado, utilizador)
VALUES (9, 10.00, 'ativo', 'inexistente@gmail.com');

-- Erro esperado: violates foreign key constraint "fk_bilhete_comprador"
INSERT INTO bilhete (id_bilhete, data_compra, comprador, dispositivo)
VALUES (7, '2025-01-01', 'inexistente@gmail.com', NULL);

-- Erro esperado: violates foreign key constraint "fk_bilhete_dispositivo"
INSERT INTO bilhete (id_bilhete, data_compra, comprador, dispositivo)
VALUES (7, '2025-01-01', 'miguel@gmail.com', 9999);

-- O bilhete 9999 não existe
-- Erro esperado: violates foreign key constraint "fk_passe_geral"
INSERT INTO passe_geral (id_bilhete, festival, ano) VALUES (9999, 'NOS Alive', '2025');

-- Edição 2022 do NOS Alive não existe
-- Erro esperado: violates foreign key constraint "fk_passe_geral_edição"
INSERT INTO passe_geral (id_bilhete, festival, ano) VALUES (4, 'NOS Alive', '2022');

-- O bilhete 9999 não existe
-- Erro esperado: violates foreign key constraint "fk_bilhete_diário"
INSERT INTO bilhete_diário (id_bilhete, festival, ano, data)
VALUES (9999, 'NOS Alive', '2025', '2025-07-10');

-- O dia 2025-12-31 não existe
-- Erro esperado: violates foreign key constraint "fk_bilhete_diário_dia"
INSERT INTO bilhete_diário (id_bilhete, festival, ano, data)
VALUES (1, 'NOS Alive', '2025', '2025-12-31');
