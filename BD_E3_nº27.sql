SET search_path TO tabelase3;

/* 1. Hora de início, hora de fim, nome e género musical do artista de cada concerto do Festival Atlântico no dia 19 de junho de 2025, por ordem de hora de início.*/

SELECT concerto.hora_inicio, concerto.hora_fim, concerto.artista, artista.genero_musical
FROM concerto , artista  
WHERE concerto.festival = 'Festival Atlântico' and concerto.data = '2025/6/19'

ORDER BY concerto.hora_inicio; 

/* 2. Nome dos artistas que atuaram no Festival Atlântico em 2025, mas não em 2026. */

(SELECT concerto.artista
FROM concerto
WHERE concerto.festival = 'Festival Atlântico' and concerto.ano = 2025)
EXCEPT
(SELECT concerto.artista
FROM concerto
WHERE concerto.festival = 'Festival Atlântico' and concerto.ano = 2026)


/* 3. Para cada festival, o género musical com mais concertos, considerando todas as edições, e o respetivo número de concertos. Em caso de empate, devem ser apresentados todos os géneros empatados. */

/* 4. Email dos compradores que compraram mais bilhetes para outras pessoas (titular diferente do comprador) do que para si próprios, com o número de bilhetes comprados para outras pessoas.*/ 

/* 5. Nome dos artistas que atuaram em todas as edições do Festival Atlântico.*/ 

/* 6. Para cada dia das edições de 2026, o festival, a data, o número de bilhetes com acesso a esse dia e o número de lugares ainda disponíveis (capacidade da edição menos o número de bilhetes), incluindo os dias sem bilhetes vendidos, por ordem de festival e data. Note que um passe geral dá acesso a todos os dias da sua edição.*/

/* 7. Função preco_pago(p_id_bilhete INTEGER) RETURNS NUMERIC, que devolve o preço pago por um bilhete (RIA-6): o preço do passe da edição, se for um passe geral, ou o preço diário do dia, se for um bilhete diário. Se o bilhete não existir, deve ser lançada uma exceção. Usar a função numa consulta que apresente, para cada edição, o festival, o ano, o número de bilhetes vendidos e a receita total. */

CREATE FUNCTION preco_pago(p_id_bilhete INTEGER)
RETURNS NUMERIC
AS $preco_pago$
DECLARE v_tipo VARCHAR(6);
        v_preco NUMERIC(7, 2);
BEGIN 
   SELECT bilhete.tipo INTO v_tipo
   FROM  bilhete
   WHERE bilhete.id_bilhete = p_id_bilhete;

   IF NOT FOUND THEN
      RAISE EXCEPTION 'O bilhete % não existe', p_id_bilhete;
   END IF;

   IF v_tipo = 'geral' THEN
      SELECT edicao.preco_passe INTO v_preco
      FROM bilhete, edicao
      WHERE bilhete.festival = edicao.festival
         AND bilhete.ano = edicao.ano    
         AND Bilhete.id_bilhete = p_id_bilhete;
   ELSE
      SELECT dia.preco_diario INTO v_preco
      FROM bilhete, dia
      WHERE bilhete.festival = dia.festival
         AND bilhete.ano = dia.ano
         AND bilhete.data = dia.data   
         AND Bilhete.id_bilhete = p_id_bilhete;
   END IF;
   RETURN v_preco;
End;
$preco_pago$
LANGUAGE plpgsql;

SELECT bilhete.festival, bilhete.ano,
       COUNT(*) AS bilhetes_vendidos,
       SUM(bilhete.id_bilhete) AS receita_total
FROM bilhete
GROUP BY bilhete.festival, bilhete.ano


/* 8. Procedimento comprar_bilhete(p_comprador VARCHAR, p_titular VARCHAR, p_festival VARCHAR, p_ano NUMERIC, p_data DATE, p_data_compra DATE, INOUT p_id_bilhete INTEGER DEFAULT NULL), que regista a compra de um bilhete diário para o dia p_data. Antes de inserir o bilhete, o procedimento deve verificar que:
a) A edição existe e o dia pertence a essa edição.
b) A data de compra não é posterior ao dia do bilhete (RIA-5).
c) Há lugar nesse dia, isto é, o número de bilhetes com acesso ao dia (passes gerais da
edição e bilhetes diários desse dia) é inferior à capacidade máxima da edição (RIA-4).
Se alguma condição falhar, deve ser lançada uma exceção com uma mensagem que a identifique; caso contrário, o bilhete é inserido e o seu identificador é devolvido em p_id_bilhete.*/
