-- ====================================================================
-- PROJETO: MERCADO FICTÍCIO (PORTFÓLIO PRINCIPAL - DBA)
-- DESCRIÇÃO: SCRIPT RAIZ DE IMPLANTAÇÃO AUTOMATIZADA (DEPLOYMENT)
-- SGBD: POSTGRESQL (v17+)
-- ====================================================================

-- --------------------------------------------------------------------
-- 1. LIMPEZA SEGURA DE AMBIENTE (Garante reinicialização limpa - CASCADE)
-- --------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_processa_item_venda ON public.itens_venda;
DROP FUNCTION IF EXISTS public.processa_item_venda_automatica() CASCADE;
DROP FUNCTION IF EXISTS public.baixa_estoque_automatica() CASCADE;
DROP TABLE IF EXISTS public.pedidos_reposicao CASCADE;
DROP TABLE IF EXISTS public.itens_venda CASCADE;
DROP TABLE IF EXISTS public.vendas CASCADE;
DROP TABLE IF EXISTS public.produtos CASCADE;
DROP TABLE IF EXISTS public.fornecedores CASCADE;
DROP TABLE IF EXISTS public.clientes CASCADE;

-- --------------------------------------------------------------------
-- 2. CRIAÇÃO DA ESTRUTURA DE TABELAS E RESTRIÇÕES (DDL)
-- --------------------------------------------------------------------

CREATE TABLE public.clientes (
    id SERIAL PRIMARY KEY,
    nome character varying(100) NOT NULL,
    cpf character varying(14) UNIQUE,
    telefone character varying(20)
);

CREATE TABLE public.fornecedores (
    id SERIAL PRIMARY KEY,
    nome character varying(100) NOT NULL,
    telefone character varying(20)
);

CREATE TABLE public.produtos (
    id SERIAL PRIMARY KEY,
    nome_produto character varying(100) NOT NULL,
    preco_custo numeric(18,4) NOT NULL,
    preco_venda numeric(18,4) NOT NULL,
    estoque integer DEFAULT 0 NOT NULL,
    fornecedor_id integer,
    CONSTRAINT chk_estoque_positivo CHECK ((estoque >= 0)),
    CONSTRAINT fk_produtos_fornecedor FOREIGN KEY (fornecedor_id) 
        REFERENCES public.fornecedores(id) ON DELETE SET NULL
);

CREATE TABLE public.vendas (
    id SERIAL PRIMARY KEY,
    cliente_id integer,
    data_venda timestamp without time zone DEFAULT now(),
    valor_total numeric(18,4) NOT NULL DEFAULT 0.0000,
    CONSTRAINT fk_vendas_cliente FOREIGN KEY (cliente_id) 
        REFERENCES public.clientes(id) ON DELETE SET NULL
);

CREATE TABLE public.itens_venda (
    id SERIAL PRIMARY KEY,
    venda_id integer NOT NULL,
    produto_id integer NOT NULL,
    quantidade numeric(12,4) NOT NULL,
    preco_unitario numeric(18,4) NOT NULL,
    CONSTRAINT itens_venda_quantidade_check CHECK ((quantidade > 0.0000)),
    CONSTRAINT fk_itens_venda_venda FOREIGN KEY (venda_id) 
        REFERENCES public.vendas(id) ON DELETE CASCADE,
    CONSTRAINT fk_itens_venda_produto FOREIGN KEY (produto_id) 
        REFERENCES public.produtos(id)
);

CREATE TABLE public.pedidos_reposicao (
    id SERIAL PRIMARY KEY,
    produto_id integer,
    fornecedor_id integer,
    quantidade_pedida integer DEFAULT 50,
    data_pedido timestamp without time zone DEFAULT now(),
    status character varying(20) DEFAULT 'Pendente'::character varying,
    CONSTRAINT fk_pedidos_produto FOREIGN KEY (produto_id) 
        REFERENCES public.produtos(id) ON DELETE CASCADE,
    CONSTRAINT fk_pedidos_fornecedor FOREIGN KEY (fornecedor_id) 
        REFERENCES public.fornecedores(id) ON DELETE CASCADE
);

-- --------------------------------------------------------------------
-- 3. CAMADA PROCEDURAL E REGRAS DE NEGÓCIO (PL/pgSQL)
-- --------------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.processa_item_venda_automatica() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_estoque_atual INTEGER;
    v_ja_pedido BOOLEAN;
    v_fornecedor_id INTEGER;
    v_subtotal NUMERIC(18,4);
BEGIN
    -- 1. Calcula o subtotal do item adicionado e atualiza o valor total no cabeçalho da venda
    v_subtotal := NEW.quantidade * NEW.preco_unitario;
    
    UPDATE public.vendas 
    SET valor_total = valor_total + v_subtotal 
    WHERE id = NEW.venda_id;

    -- 2. Dá baixa automática no estoque do produto vendido e captura o saldo final e fornecedor
    UPDATE public.produtos 
    SET estoque = estoque - NEW.quantidade 
    WHERE id = NEW.produto_id
    RETURNING estoque, fornecedor_id INTO v_estoque_atual, v_fornecedor_id;

    -- 3. Monitoramento inteligente: se o estoque bater 10 unidades ou menos, abre pedido de reposição
    IF v_estoque_atual <= 10 THEN
        
        -- Evita duplicidade: checa se já não existe um pedido pendente para esse produto
        SELECT EXISTS (
            SELECT 1 FROM public.pedidos_reposicao 
            WHERE produto_id = NEW.produto_id AND status = 'Pendente'
        ) INTO v_ja_pedido;

        -- Se estiver limpo, abre a ordem de compra direcionada ao fornecedor correto do item
        IF NOT v_ja_pedido THEN
            INSERT INTO public.pedidos_reposicao (produto_id, fornecedor_id, quantidade_pedida)
            VALUES (NEW.produto_id, v_fornecedor_id, 50);
        END IF;
        
    END IF;

    RETURN NEW;
END;
$$;

-- Vinculando o Gatilho (Trigger) à tabela de Itens de Venda
CREATE TRIGGER trg_processa_item_venda
AFTER INSERT ON public.itens_venda
FOR EACH ROW 
EXECUTE FUNCTION public.processa_item_venda_automatica();

-- --------------------------------------------------------------------
-- 4. CARGA DE TESTE E DISPARO DA TRIGGER (Massa de Dados)
-- --------------------------------------------------------------------

INSERT INTO public.clientes (nome, cpf, telefone) 
VALUES ('Ada Lovelace', '123.456.789-00', '(11) 99999-1915');

INSERT INTO public.fornecedores (nome, telefone) 
VALUES ('Distribuidora Vale do Rio Doce', '(31) 3333-4444');

-- Cadastrando produto com estoque inicial de 15 unidades (Próximo do limite de gatilho)
INSERT INTO public.produtos (nome_produto, preco_custo, preco_venda, estoque, fornecedor_id) 
VALUES ('Arroz Integral Tipo 1 5kg', 18.50, 29.90, 15, 1);

-- Abrindo o cabeçalho da venda (Valor total inicia zerado)
INSERT INTO public.vendas (cliente_id, valor_total) 
VALUES (1, 0.00);

-- Venda de 6 unidades (O estoque vai cair de 15 para 9, forçando o disparo da Trigger)
INSERT INTO public.itens_venda (venda_id, produto_id, quantidade, preco_unitario) 
VALUES (1, 1, 6, 29.90);

-- --------------------------------------------------------------------
-- 5. RELATÓRIO DE AUDITORIA FINAL (O que o recrutador verá na tela)
-- --------------------------------------------------------------------
SELECT * FROM public.pedidos_reposicao;
