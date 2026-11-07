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

--utilizador(email, nome, data_nascimento, grupo_sanguíneo, contacto_emergência, segue)
CREATE TABLE utilizador(
    email VARCHAR(100),
    nome VARCHAR(60) NOT NULL,
    data_nascimento DATE NOT NULL,
    grupo_sanguíneo VARCHAR(3) NOT NULL,
    contacto_emergência NUMERIC(9) NOT NULL,
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
    data DATE,
    nome VARCHAR(60),
    preço_diário NUMERIC(5,2) NOT NULL,
    edição CHAR(4),
    CONSTRAINT pk_dia PRIMARY KEY (festival, edição, data),
    CONSTRAINT fk_edição FOREIGN KEY (ano) REFERENCES edição(festival, ano)
        ON DELETE CASCADE ON UPDATE CASCADE ,
    CONSTRAINT ck_dia_preço_diário CHECK (preço_diário > 0) --RIA-12
    CONSTRAINT  ck_dia_pertence_edição (dia in (edição)) -- RIA-1
);


--Opção 2 - Correção da IA, mas não estou a perceber bem porque
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
    CONSTRAINT fk_concerto_dia FOREIGN KEY (festival, ano, data) REFERENCES dia(festival, edição, data), 
    CONSTRAINT  ck_concerto_horas CHECK (hora_início < hora_fim) -- RIA-2
);


CREATE TABLE dispositivo(
    n_série NUMERIC(10),
    saldo NUMERIC(8,2) NOT NULL,
    estado VARCHAR(10) NOT NULL,
    utilizador VARCHAR(100) NOT NULL,
    CONSTRAINT pk_dispositivo PRIMARY KEY (n_série),
    CONSTRAINT fk_dispositivo_utilizador FOREIGN KEY (utilizador) REFERENCES utilizador(email),
    CONSTRAINT ck_dispositvo_saldo CHECK (saldo >= 0 ), --RIA-7
    CONSTRAINT ck_dispositivo_estado CHECK ( estado IN ('ativo', 'desativado', 'extraviado'))--RIA7

);

CREATE TABLE bilhete(
    id_bilhete NUMERIC(10,0),
    data_compra DATE NOT NULL,
    comprador VARCHAR(100) NOT NULL,
    dispositivo VARCHAR(20),
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
                        ON DELETE CASCADE ON UPDATE CASCADE
    CONSTRAINT fk_passe_geral_edição FOREIGN KEY (festival, ano) REFERENCES edição(festival, ano)
);

CREATE TABLE bilhete_diário(
    id_bilhete NUMERIC(10,0),
    festival VARCHAR(60) NOT NULL,
    ano CHAR(4) NOT NULL,
    data DATE NOT NULL,
    CONSTRAINT pk_bilhete_diário PRIMARY KEY(id_bilhete),
    CONSTRAINT fk_bilhete_diário FOREIGN KEY(id_bilhete) REFERENCES bilhete
                        ON DELETE CASCADE ON UPDATE CASCADE
    CONSTRAINT fk_bilhete_diário_dia FOREIGN KEY (festival, ano, data) REFERENCES dia(festival, ano, data)
);

------------------------------------------------------------------------------------------------------------------------
INSERT INTO