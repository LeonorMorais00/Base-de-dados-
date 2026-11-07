SET search_path TO bd027_schema;
DROP TABLE IF EXISTS bilhete_diário CASCADE;
DROP TABLE IF EXISTS passe_geral CASCADE;
DROP TABLE IF EXISTS bilhete CASCADE;
DROP TABLE IF EXISTS segue CASCADE;
DROP TABLE IF EXISTS alergia_multivalor CASCADE;
DROP TABLE IF EXISTS dispositivo CASCADE;
DROP TABLE IF EXISTS concerto CASCADE;
DROP TABLE IF EXISTS dia CASCADE;
DROP TABLE IF EXISTS edição CASCADE;
DROP TABLE IF EXISTS utilizador CASCADE;
DROP TABLE IF EXISTS artista CASCADE;
DROP TABLE IF EXISTS recinto CASCADE;
DROP TABLE IF EXISTS festival CASCADE;


CREATE TABLE festival(
    nome VARCHAR(60),
    ano_criação NUMERIC(4) NOT NULL,
    CONSTRAINT pk_festival PRIMARY KEY (nome)
);

--RECINTO (nome, rua, codigo_postal, localidade, cidade, capacidade_máx)

CREATE TABLE recinto(
    nome VARCHAR(60),
    rua VARCHAR(100) NOT NULL,
    código_postal VARCHAR(10) NOT NULL,
    localidade VARCHAR(60) NOT NULL,
    cidade VARCHAR(60) NOT NULL,
    capacidade_max NUMERIC(10) NOT NULL, 
    CONSTRAINT pk_recinto PRIMARY KEY(nome),
    CONSTRAINT ck_recinto CHECK (capacidade_max > 0) -- RIA-12
);

--utilizador(email, nome, data_nascimento, grupo_sanguíneo, contacto_emergência)
CREATE TABLE utilizador(
    email VARCHAR(100),
    nome VARCHAR(60) NOT NULL,
    data_nascimento DATE NOT NULL,
    grupo_sanguíneo VARCHAR(3) NOT NULL,
    contacto_emergência NUMERIC(9),
    CONSTRAINT pk_utilizador PRIMARY KEY (email),
    CONSTRAINT ck_utilizador_em CHECK (email LIKE '%@%'),
    CONSTRAINT ck_utilizador_sang CHECK (grupo_sanguíneo IN ('A+','A-','B+','B-','AB+','AB-','O+','O-'))
);

--alergia_multivalor (email, alergia)

CREATE TABLE alergia_multivalor(
    email VARCHAR(100),
    alergia VARCHAR(60),
    CONSTRAINT pk_alergia_multivalor PRIMARY KEY (email, alergia),
    CONSTRAINT fk_alergia_multivalor FOREIGN KEY (email) REFERENCES utilizador(email) 
);


--segue(seguidor, seguido)
CREATE TABLE segue(
    seguidor VARCHAR(100),
    seguido VARCHAR(100),
    CONSTRAINT pk_segue PRIMARY KEY (seguidor, seguido),
    CONSTRAINT fk_segue_seguidor FOREIGN KEY (seguidor) REFERENCES utilizador(email),
    CONSTRAINT fk_segue_seguido FOREIGN KEY (seguido) REFERENCES utilizador(email),
    CONSTRAINT ck_segue CHECK (seguido <> seguidor ) --RIA-11
);

--artista(nome,género_musical, tipo)
CREATE TABLE artista(
    nome VARCHAR(60),
    género_musical VARCHAR(20) NOT NULL,
    tipo VARCHAR(20) NOT NULL,
    CONSTRAINT pk_artista PRIMARY KEY (nome),
    CONSTRAINT ck_artista CHECK ( tipo IN ('grupo', 'artista')) -- RIA-3
);


--edição (nome, ano, preço_passe, nome)
CREATE TABLE edição(
    festival VARCHAR(60),  
    ano CHAR(4),
    recinto VARCHAR(60) NOT NULL,
    preço_passe NUMERIC(5,2) NOT NULL,
    CONSTRAINT pk_edição PRIMARY KEY (festival, ano),
    CONSTRAINT fk_edição_festival FOREIGN KEY (festival) REFERENCES festival(nome)
         ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_edição_recinto FOREIGN KEY (recinto) REFERENCES recinto (nome),
    CONSTRAINT ck_edição_preço_passe  CHECK (preço_passe > 0 ) --RIA-12
);


CREATE TABLE dia(
    festival VARCHAR(60),
    ano CHAR(4),
    data DATE,
    preço_diário NUMERIC(5,2) NOT NULL,
    CONSTRAINT pk_dia PRIMARY KEY (festival, ano, data),
    CONSTRAINT fk_dia_edição FOREIGN KEY (festival, ano) REFERENCES edição(festival, ano)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT ck_dia_preço_diário CHECK (preço_diário > 0), -- RIA-12
    CONSTRAINT  ck_dia_pertence_edição CHECK (EXTRACT(YEAR FROM data) = CAST(ano AS INTEGER)) -- RIA-1
);


CREATE TABLE concerto(
    id_concerto VARCHAR(20),
    hora_início TIME NOT NULL,
    hora_fim    TIME NOT NULL,
    artista VARCHAR(60) NOT NULL,
    festival VARCHAR(60) NOT NULL,
    ano CHAR(4) NOT NULL,
    data DATE NOT NULL,  
    CONSTRAINT pk_concerto PRIMARY KEY (id_concerto),
    CONSTRAINT fk_concerto_artista FOREIGN KEY (artista) REFERENCES artista(nome),
    CONSTRAINT fk_concerto_dia FOREIGN KEY (festival, ano, data) REFERENCES dia(festival, ano, data), 
    CONSTRAINT  ck_concerto_horas CHECK (hora_início < hora_fim) -- RIA-2
);


CREATE TABLE dispositivo(
    n_série NUMERIC(10),
    saldo NUMERIC(8,2) NOT NULL,
    estado VARCHAR(10) NOT NULL,
    utilizador VARCHAR(100) NOT NULL,
    CONSTRAINT pk_dispositivo PRIMARY KEY (n_série),
    CONSTRAINT fk_dispositivo_utilizador FOREIGN KEY (utilizador) REFERENCES utilizador(email),
    CONSTRAINT ck_dispositivo_saldo CHECK (saldo >= 0 ), --RIA-7
    CONSTRAINT ck_dispositivo_estado CHECK ( estado IN ('ativo', 'bloqueado', 'extraviado'))--RIA-7

);

CREATE TABLE bilhete(
    id_bilhete NUMERIC(10),
    data_compra DATE NOT NULL,
    comprador VARCHAR(100) NOT NULL,
    dispositivo NUMERIC(20),
    CONSTRAINT pk_bilhete PRIMARY KEY (id_bilhete),
    CONSTRAINT fk_bilhete_comprador FOREIGN KEY (comprador) REFERENCES utilizador(email),
    CONSTRAINT fk_bilhete_dispositivo FOREIGN KEY (dispositivo) REFERENCES dispositivo(n_série)
);

CREATE TABLE passe_geral(
    id_bilhete NUMERIC(10,0),
    festival VARCHAR(60) NOT NULL,
    ano CHAR(4) NOT NULL,
    CONSTRAINT pk_passe_geral PRIMARY KEY(id_bilhete),
    CONSTRAINT fk_passe_geral FOREIGN KEY(id_bilhete) REFERENCES bilhete
                        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_passe_geral_edição FOREIGN KEY (festival, ano) REFERENCES edição(festival, ano)
);

CREATE TABLE bilhete_diário(
    id_bilhete NUMERIC(10,0),
    festival VARCHAR(60) NOT NULL,
    ano CHAR(4) NOT NULL,
    data DATE NOT NULL,
    CONSTRAINT pk_bilhete_diário PRIMARY KEY(id_bilhete),
    CONSTRAINT fk_bilhete_diário FOREIGN KEY(id_bilhete) REFERENCES bilhete
                        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_bilhete_diário_dia FOREIGN KEY (festival, ano, data) REFERENCES dia(festival, ano, data)
);

------------------------------------------------------------------------------------------------------------------------
--INSERTS:
------------------------------------------------------------------------------------------------------------------------
INSERT INTO festival (nome, ano_criação) VALUES
    ('NOS Alive', 2007),
    ('Super Bock Super Rock', 1995),
    ('MEO Kalorama', 2018);

INSERT INTO recinto (nome, rua, código_postal, localidade, cidade, capacidade_max) VALUES
    ('Passeio Marítimo de Algés', 'Passeio Marítimo de Algés', '1495-165', 'Algés', 'Oeiras', 55000),
    ('Herdade do Cabeço da Flauta', 'Estrada Nacional 377', '2970-000', 'Meco', 'Sesimbra', 20000),
    ('Parque da Bela Vista', 'Avenida Doutor Arlindo Vicente', '1950-037', 'Marvila', 'Lisboa', 35000);

INSERT INTO utilizador(email, nome, data_nascimento, grupo_sanguíneo, contacto_emergência) VALUES
    ('miguel@gmail.com', 'Miguel','2003-08-06','A+','938000938'),
    ('luisa@gmail.com', 'Luísa','1968-07-04','AB+','955555555'),
    ('antonio@gmail.com', 'Antonio','1970-11-13','O-','938000938');

INSERT INTO artista(nome,género_musical, tipo) VALUES
    ('Katy Perry', 'pop', 'artista'), --artista solo
    ('Foo Fighters', 'rock alternativo', 'grupo'), --grupo
    ('Lorde', 'art pop', 'artista');

INSERT INTO edição(festival, ano, recinto, preço_passe) VALUES
    ('NOS Alive', '2025', 'Passeio Marítimo de Algés', 189.00),
    ('Super Bock Super Rock','2021','Herdade do Cabeço da Flauta', 200.00),
    ('MEO Kalorama', '2024', 'Parque da Bela Vista', 150.00),
    ('NOS Alive', '2023', 'Parque da Bela Vista', 179.00); -- o mesmo festival mudou de recinto entre edições

INSERT INTO alergia_multivalor(email, alergia) VALUES
    ('miguel@gmail.com', 'camarão'),
    ('luisa@gmail.com', 'morango'),
    ('antonio@gmail.com', 'caracol');

INSERT INTO segue(seguidor, seguido) VALUES
    ('miguel@gmail.com', 'luisa@gmail.com' ), 
    ('antonio@gmail.com', 'luisa@gmail.com'),
    ('luisa@gmail.com', 'miguel@gmail.com' );

INSERT INTO dispositivo (n_série, saldo, estado, utilizador) VALUES
    (1111, 3, 'ativo', 'miguel@gmail.com'),
    (3, 10, 'bloqueado', 'miguel@gmail.com'),   -- dispositivo bloqueado (o Miguel só tem um ativo)
    (2, 60, 'extraviado', 'luisa@gmail.com'),    -- dispositivo extraviado...
    (99, 100, 'ativo', 'luisa@gmail.com'),       -- ...e novo dispositivo ativo do mesmo utilizador
    (50, 100, 'ativo', 'antonio@gmail.com');

INSERT INTO dia (festival, ano, data, preço_diário) VALUES
    -- edição com 3 dias
    ('NOS Alive', '2025', '2025-07-10', 75.00),
    ('NOS Alive', '2025', '2025-07-11', 80.00),
    ('NOS Alive', '2025', '2025-07-12', 85.00),
    -- edição com 3 dias, noutro recinto (festival que mudou de recinto)
    ('NOS Alive', '2023', '2023-07-06', 70.00),
    ('NOS Alive', '2023', '2023-07-07', 75.00),
    ('NOS Alive', '2023', '2023-07-08', 80.00),
    -- edição com 2 dias (caso limite: mínimo)
    ('Super Bock Super Rock', '2021', '2021-07-16', 60.00),
    ('Super Bock Super Rock', '2021', '2021-07-17', 65.00),
    -- edição com 5 dias (caso limite: máximo)
    ('MEO Kalorama', '2024', '2024-06-05', 40.00),
    ('MEO Kalorama', '2024', '2024-06-06', 45.00),
    ('MEO Kalorama', '2024', '2024-06-07', 50.00),
    ('MEO Kalorama', '2024', '2024-06-08', 55.00),
    ('MEO Kalorama', '2024', '2024-06-09', 55.00);

INSERT INTO concerto(id_concerto, hora_início, hora_fim, artista, festival, ano, data) VALUES
    ('1111', '22:00', '23:00', 'Katy Perry', 'NOS Alive', '2025', '2025-07-10'),
    ('32', '00:00', '01:00', 'Lorde', 'MEO Kalorama', '2024', '2024-06-06'),
    ('100', '15:00', '16:00', 'Foo Fighters','Super Bock Super Rock', '2021', '2021-07-16');

INSERT INTO bilhete (id_bilhete, data_compra, comprador, dispositivo) VALUES
    (1, '2025-03-15', 'miguel@gmail.com',  1111),  -- passe geral já associado ao dispositivo do próprio titular
    (2, '2024-04-10', 'antonio@gmail.com', 50),    -- passe geral já associado
    (3, '2021-05-20', 'luisa@gmail.com',   NULL),  -- passe geral ainda por associar a um dispositivo
    (4, '2025-04-01', 'luisa@gmail.com',   99),    -- bilhete diário associado ao novo dispositivo ativo
    (5, '2025-05-02', 'miguel@gmail.com',  50),    -- bilhete comprado para terceiros (dispositivo do António)
    (6, '2021-06-01', 'luisa@gmail.com',   NULL);  -- bilhete diário ainda por associar a um dispositivo 

INSERT INTO passe_geral (id_bilhete, festival, ano) VALUES
    (1, 'NOS Alive', '2025'),
    (2, 'MEO Kalorama', '2024'),
    (3, 'Super Bock Super Rock', '2021');

INSERT INTO bilhete_diário (id_bilhete, festival, ano, data) VALUES
    (4, 'NOS Alive', '2025', '2025-07-10'),
    (5, 'NOS Alive', '2025', '2025-07-12'),
    (6, 'Super Bock Super Rock', '2021', '2021-07-17');

