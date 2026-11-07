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
    código_postal NUMERIC(4) NOT NULL,
    localidade VARCHAR(60) NOT NULL,
    cidade VARCHAR(60) NOT NULL,
    capacidade_máx NUMERIC(10) NOT NULL,
    CONSTRAINT pk_recinto PRIMARY KEY(nome)

);
--utilizador(email, nome, data_nascimento, grupo_sanguíneo, contacto_emergência, segue)
CREATE TABLE utilizador(

    email VARCHAR(100),
    nome VARCHAR(60) NOT NULL,
    data_nascimento DATE NOT NULL,
    grupo_sanguíneo VARCHAR(2) NOT NULL,
    contacto_emergência NUMERIC(9) NOT NULL,
    segue VARCHAR(60) NOT NULL,
    CONSTRAINT pk_utilizador PRIMARY KEY (email),
    CONSTRAINT fk_utilizador_segue FOREIGN KEY (segue) REFERENCES utilizador(email),
    CONSTRAINT ck_utilizador CHECK (email LIKE '%@%'),
    CONSTRAINT ck_utilizador CHECK (grupo_sanguíneo IN ('A', 'B', 'AB', 'O'))

);

--alergia_multivalor (email, alergia)

CREATE TABLE alergia_multivalor(

    email VARCHAR(100),
    alergia VARCHAR(60),
    CONSTRAINT pk_alergia_multivalor PRIMARY KEY (email, alergia),
    CONSTRAINT fk_alergia_multivalor FOREIGN KEY (email) REFERENCES utilizador

);




--segue(seguidor, seguido)
CREATE TABLE segue(
    seguidor VARCHAR(60),
    seguido VARCHAR(60),
    CONSTRAINT pk_segue PRIMARY KEY (seguidor, seguido),
    CONSTRAINT fk_seguidor FOREIGN KEY (seguidor) REFERENCES utilizador(email),
    CONSTRAINT fk_seguido FOREIGN KEY (seguido) REFERENCES utilizador(email),
    CONSTRAINT ck_segue CHECK (seguido <> seguidor )


);

--artista(nome,género_musical, tipo)
CREATE TABLE artista(

    nome VARCHAR(60),
    género_musical VARCHAR(20) NOT NULL,
    tipo VARCHAR(20) NOT NULL,
    CONSTRAINT pk_artista PRIMARY KEY (nome),
    CONSTRAINT ck_artista CHECK ( tipo IN ('grupo', 'artista'))


);










--edição (nome, ano, preço_passe, nome)


CREATE TABLE edição(
    nome VARCHAR(60),  --DUVIDA AQUI
    ano CHAR(4),
    recinto VARCHAR(60) NOT NULL,
    preço_passe NUMERIC(5,2) NOT NULL,
    CONSTRAINT pk_edição PRIMARY KEY (nome, ano),
    CONSTRAINT fk_edição_festival FOREIGN KEY (nome) REFERENCES festival(nome)
         ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_edição_recinto FOREIGN KEY (recinto) REFERENCES recinto (nome),
    CONSTRAINT ck_edição_preço_passe  CHECK (preço_passe > 0 )


);


CREATE TABLE dia(
    data DATE,
    nome VARCHAR(60),
    preço_diário NUMERIC(5,2) NOT NULL,
    CONSTRAINT pk_dia PRIMARY KEY (data, nome),
    CONSTRAINT fk_dia_festival FOREIGN KEY (nome) REFERENCES festival(nome)
        ON DELETE CASCADE ON UPDATE CASCADE ,
    --ria 12 :  O preço_passe, o preço_diário e a capacidade_máx do recinto são > 0.
    CONSTRAINT ck_dia_preço_diário CHECK (preço_diário > 0 )

);


CREATE TABLE tem_dia(

    data DATE,
    nome VARCHAR(60),
    ano CHAR(4),
    CONSTRAINT pk_tem_dia PRIMARY KEY (data, nome, ano),
    CONSTRAINT fk_tem_dia_edição FOREIGN KEY (nome) REFERENCES festival,
    CONSTRAINT fk_tem_dia_dia FOREIGN KEY (nome) REFERENCES festival,
    CONSTRAINT fk_tem_dia_edição FOREIGN KEY (data) REFERENCES dia,
    CONSTRAINT fk_tem_dia_dia FOREIGN KEY (ano) REFERENCES edição



);


CREATE TABLE concerto(

    id_concerto VARCHAR(20),
    artista VARCHAR(60) NOT NULL




);


CREATE TABLE dispositivo(

    n_série NUMERIC(10),
    saldo NUMERIC(10) NOT NULL,
    estado NUMERIC(10) NOT NULL,
    utilizador VARCHAR(100) NOT NULL,
    CONSTRAINT pk_dispositivo PRIMARY KEY (n_série),
    CONSTRAINT fk_dispositivo_utilizador FOREIGN KEY (utilizador) REFERENCES utilizador(email),
    CONSTRAINT ck_dispositvo_saldo CHECK (saldo > 0 ),
    CONSTRAINT ck_dispositivo_estado CHECK ( estado IN ('ativo', 'desativado', 'extraviado'))

);

CREATE TABLE bilhete(

    id_bilhete NUMERIC(10,0),
    data_compra DATE NOT NULL,
    comprador VARCHAR(100) NOT NULL,
    dispositivo VARCHAR(20) NOT NULL,
    CONSTRAINT pk_bilhete PRIMARY KEY (id_bilhete),
    CONSTRAINT fk_bilhete_comprador FOREIGN KEY (comprador) REFERENCES utilizador(email),
    CONSTRAINT fk_bilhete_dispositivo FOREIGN KEY (dispositivo) REFERENCES dispositivo(n_série)

);

CREATE TABLE passe_geral(

    id_bilhete NUMERIC(10,0),
    CONSTRAINT pk_passe_geral PRIMARY KEY(id_bilhete),
    CONSTRAINT fk_passe_geral FOREIGN KEY(id_bilhete) REFERENCES bilhete
                        ON DELETE CASCADE ON UPDATE CASCADE


);
CREATE TABLE bilhete_diário(

    id_bilhete NUMERIC(10,0),
    CONSTRAINT pk_bilhete_diário PRIMARY KEY(id_bilhete),
    CONSTRAINT fk_bilhete_diário FOREIGN KEY(id_bilhete) REFERENCES bilhete
                        ON DELETE CASCADE ON UPDATE CASCADE


);