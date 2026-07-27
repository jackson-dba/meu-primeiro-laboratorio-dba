--
-- PostgreSQL database dump
--

\restrict lYniUT7k2cw2UlwTvOorC1ueXVt390Dd1mPkh1TBQrfFVTnWhluoanF2mFggBlE

-- Dumped from database version 17.10
-- Dumped by pg_dump version 17.10

-- Started on 2026-07-27 17:44:15

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 229 (class 1255 OID 16431)
-- Name: baixa_estoque_automatica(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.baixa_estoque_automatica() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_estoque_atual INTEGER;
    v_ja_pedido BOOLEAN;
BEGIN
    -- 1. Reduz o estoque e guarda o novo valor na variável
    UPDATE public.produtos
    SET estoque = estoque - NEW.quantidade_vendida
    WHERE id = NEW.produto_id
    RETURNING estoque INTO v_estoque_atual;

    -- 2. Se o estoque atingir 10 unidades ou menos (10% de um estoque padrão de 100)
    IF v_estoque_atual <= 10 THEN
        
        -- Verifica se já não existe um pedido pendente para evitar duplicidade
        SELECT EXISTS (
            SELECT 1 FROM public.pedidos_reposicao 
            WHERE produto_id = NEW.produto_id AND status = 'Pendente'
        ) INTO v_ja_pedido;

        -- Se não houver pedido aberto, gera um novo automaticamente
        IF NOT v_ja_pedido THEN
            INSERT INTO public.pedidos_reposicao (produto_id, quantidade_pedida)
            VALUES (NEW.produto_id, 50);
        END IF;
        
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.baixa_estoque_automatica() OWNER TO postgres;

--
-- TOC entry 241 (class 1255 OID 16561)
-- Name: processa_item_venda_automatica(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.processa_item_venda_automatica() RETURNS trigger
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

    -- 2. Dá baixa automática no estoque do produto vendido e captura o saldo final
    UPDATE public.produtos
    SET estoque = estoque - NEW.quantidade
    WHERE id = NEW.produto_id
    RETURNING estoque, fornecedor_id INTO v_estoque_atual, v_fornecedor_id;

    -- 3. Monitoramento inteligente: se o estoque bater 10% (10 unidades ou menos), abre pedido de reposição
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


ALTER FUNCTION public.processa_item_venda_automatica() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 220 (class 1259 OID 16571)
-- Name: clientes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.clientes (
    id integer NOT NULL,
    nome character varying(100) NOT NULL,
    cpf character varying(14),
    telefone character varying(20)
);


ALTER TABLE public.clientes OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 16570)
-- Name: clientes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.clientes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.clientes_id_seq OWNER TO postgres;

--
-- TOC entry 4865 (class 0 OID 0)
-- Dependencies: 219
-- Name: clientes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.clientes_id_seq OWNED BY public.clientes.id;


--
-- TOC entry 218 (class 1259 OID 16564)
-- Name: fornecedores; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fornecedores (
    id integer NOT NULL,
    nome character varying(100) NOT NULL,
    telefone character varying(20)
);


ALTER TABLE public.fornecedores OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 16563)
-- Name: fornecedores_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.fornecedores_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.fornecedores_id_seq OWNER TO postgres;

--
-- TOC entry 4866 (class 0 OID 0)
-- Dependencies: 217
-- Name: fornecedores_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.fornecedores_id_seq OWNED BY public.fornecedores.id;


--
-- TOC entry 226 (class 1259 OID 16608)
-- Name: itens_venda; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.itens_venda (
    id integer NOT NULL,
    venda_id integer NOT NULL,
    produto_id integer NOT NULL,
    quantidade numeric(12,4) NOT NULL,
    preco_unitario numeric(18,4) NOT NULL,
    CONSTRAINT itens_venda_quantidade_check CHECK ((quantidade > 0.0000))
);


ALTER TABLE public.itens_venda OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 16607)
-- Name: itens_venda_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.itens_venda_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.itens_venda_id_seq OWNER TO postgres;

--
-- TOC entry 4867 (class 0 OID 0)
-- Dependencies: 225
-- Name: itens_venda_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.itens_venda_id_seq OWNED BY public.itens_venda.id;


--
-- TOC entry 228 (class 1259 OID 16626)
-- Name: pedidos_reposicao; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pedidos_reposicao (
    id integer NOT NULL,
    produto_id integer,
    fornecedor_id integer,
    quantidade_pedida integer DEFAULT 50,
    data_pedido timestamp without time zone DEFAULT now(),
    status character varying(20) DEFAULT 'Pendente'::character varying
);


ALTER TABLE public.pedidos_reposicao OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 16625)
-- Name: pedidos_reposicao_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pedidos_reposicao_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.pedidos_reposicao_id_seq OWNER TO postgres;

--
-- TOC entry 4868 (class 0 OID 0)
-- Dependencies: 227
-- Name: pedidos_reposicao_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pedidos_reposicao_id_seq OWNED BY public.pedidos_reposicao.id;


--
-- TOC entry 222 (class 1259 OID 16580)
-- Name: produtos; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.produtos (
    id integer NOT NULL,
    nome_produto character varying(100) NOT NULL,
    preco_custo numeric(18,4) NOT NULL,
    preco_venda numeric(18,4) NOT NULL,
    estoque integer DEFAULT 0 NOT NULL,
    fornecedor_id integer,
    CONSTRAINT chk_estoque_positivo CHECK ((estoque >= 0))
);


ALTER TABLE public.produtos OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16579)
-- Name: produtos_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.produtos_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.produtos_id_seq OWNER TO postgres;

--
-- TOC entry 4869 (class 0 OID 0)
-- Dependencies: 221
-- Name: produtos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.produtos_id_seq OWNED BY public.produtos.id;


--
-- TOC entry 224 (class 1259 OID 16594)
-- Name: vendas; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.vendas (
    id integer NOT NULL,
    cliente_id integer NOT NULL,
    data_venda timestamp without time zone DEFAULT now() NOT NULL,
    valor_total numeric(18,4) DEFAULT 0.0000 NOT NULL
);


ALTER TABLE public.vendas OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16593)
-- Name: vendas_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.vendas_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.vendas_id_seq OWNER TO postgres;

--
-- TOC entry 4870 (class 0 OID 0)
-- Dependencies: 223
-- Name: vendas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.vendas_id_seq OWNED BY public.vendas.id;


--
-- TOC entry 4669 (class 2604 OID 16574)
-- Name: clientes id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clientes ALTER COLUMN id SET DEFAULT nextval('public.clientes_id_seq'::regclass);


--
-- TOC entry 4668 (class 2604 OID 16567)
-- Name: fornecedores id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fornecedores ALTER COLUMN id SET DEFAULT nextval('public.fornecedores_id_seq'::regclass);


--
-- TOC entry 4675 (class 2604 OID 16611)
-- Name: itens_venda id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.itens_venda ALTER COLUMN id SET DEFAULT nextval('public.itens_venda_id_seq'::regclass);


--
-- TOC entry 4676 (class 2604 OID 16629)
-- Name: pedidos_reposicao id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pedidos_reposicao ALTER COLUMN id SET DEFAULT nextval('public.pedidos_reposicao_id_seq'::regclass);


--
-- TOC entry 4670 (class 2604 OID 16583)
-- Name: produtos id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.produtos ALTER COLUMN id SET DEFAULT nextval('public.produtos_id_seq'::regclass);


--
-- TOC entry 4672 (class 2604 OID 16597)
-- Name: vendas id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vendas ALTER COLUMN id SET DEFAULT nextval('public.vendas_id_seq'::regclass);


--
-- TOC entry 4851 (class 0 OID 16571)
-- Dependencies: 220
-- Data for Name: clientes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.clientes (id, nome, cpf, telefone) FROM stdin;
1	Consumidor Final	000.000.000-00	(00) 00000-0000
\.


--
-- TOC entry 4849 (class 0 OID 16564)
-- Dependencies: 218
-- Data for Name: fornecedores; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.fornecedores (id, nome, telefone) FROM stdin;
1	Paulo Fornecedor	(11) 99999-8888
2	Carlos Distribuidora	(11) 98888-7777
3	Distribuidora Souza	(21) 97777-6666
\.


--
-- TOC entry 4857 (class 0 OID 16608)
-- Dependencies: 226
-- Data for Name: itens_venda; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.itens_venda (id, venda_id, produto_id, quantidade, preco_unitario) FROM stdin;
1	1	1	2.0000	7.9900
2	1	2	5.0000	8.5000
\.


--
-- TOC entry 4859 (class 0 OID 16626)
-- Dependencies: 228
-- Data for Name: pedidos_reposicao; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pedidos_reposicao (id, produto_id, fornecedor_id, quantidade_pedida, data_pedido, status) FROM stdin;
\.


--
-- TOC entry 4853 (class 0 OID 16580)
-- Dependencies: 222
-- Data for Name: produtos; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.produtos (id, nome_produto, preco_custo, preco_venda, estoque, fornecedor_id) FROM stdin;
3	Macarrão Espaguete	2.1000	4.2000	100	3
1	Arroz Integral 1kg	4.5000	7.9900	98	1
2	Feijão Preto 1kg	5.2000	8.5000	95	2
\.


--
-- TOC entry 4855 (class 0 OID 16594)
-- Dependencies: 224
-- Data for Name: vendas; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.vendas (id, cliente_id, data_venda, valor_total) FROM stdin;
1	1	2026-07-27 16:34:20.76171	58.4800
\.


--
-- TOC entry 4871 (class 0 OID 0)
-- Dependencies: 219
-- Name: clientes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.clientes_id_seq', 1, true);


--
-- TOC entry 4872 (class 0 OID 0)
-- Dependencies: 217
-- Name: fornecedores_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.fornecedores_id_seq', 3, true);


--
-- TOC entry 4873 (class 0 OID 0)
-- Dependencies: 225
-- Name: itens_venda_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.itens_venda_id_seq', 2, true);


--
-- TOC entry 4874 (class 0 OID 0)
-- Dependencies: 227
-- Name: pedidos_reposicao_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pedidos_reposicao_id_seq', 1, false);


--
-- TOC entry 4875 (class 0 OID 0)
-- Dependencies: 221
-- Name: produtos_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.produtos_id_seq', 3, true);


--
-- TOC entry 4876 (class 0 OID 0)
-- Dependencies: 223
-- Name: vendas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.vendas_id_seq', 1, true);


--
-- TOC entry 4685 (class 2606 OID 16578)
-- Name: clientes clientes_cpf_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT clientes_cpf_key UNIQUE (cpf);


--
-- TOC entry 4687 (class 2606 OID 16576)
-- Name: clientes clientes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT clientes_pkey PRIMARY KEY (id);


--
-- TOC entry 4683 (class 2606 OID 16569)
-- Name: fornecedores fornecedores_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fornecedores
    ADD CONSTRAINT fornecedores_pkey PRIMARY KEY (id);


--
-- TOC entry 4693 (class 2606 OID 16614)
-- Name: itens_venda itens_venda_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.itens_venda
    ADD CONSTRAINT itens_venda_pkey PRIMARY KEY (id);


--
-- TOC entry 4695 (class 2606 OID 16634)
-- Name: pedidos_reposicao pedidos_reposicao_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pedidos_reposicao
    ADD CONSTRAINT pedidos_reposicao_pkey PRIMARY KEY (id);


--
-- TOC entry 4689 (class 2606 OID 16587)
-- Name: produtos produtos_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.produtos
    ADD CONSTRAINT produtos_pkey PRIMARY KEY (id);


--
-- TOC entry 4691 (class 2606 OID 16601)
-- Name: vendas vendas_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vendas
    ADD CONSTRAINT vendas_pkey PRIMARY KEY (id);


--
-- TOC entry 4702 (class 2620 OID 16646)
-- Name: itens_venda trigger_processa_item; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_processa_item AFTER INSERT ON public.itens_venda FOR EACH ROW EXECUTE FUNCTION public.processa_item_venda_automatica();


--
-- TOC entry 4698 (class 2606 OID 16620)
-- Name: itens_venda itens_venda_produto_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.itens_venda
    ADD CONSTRAINT itens_venda_produto_id_fkey FOREIGN KEY (produto_id) REFERENCES public.produtos(id);


--
-- TOC entry 4699 (class 2606 OID 16615)
-- Name: itens_venda itens_venda_venda_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.itens_venda
    ADD CONSTRAINT itens_venda_venda_id_fkey FOREIGN KEY (venda_id) REFERENCES public.vendas(id) ON DELETE CASCADE;


--
-- TOC entry 4700 (class 2606 OID 16640)
-- Name: pedidos_reposicao pedidos_reposicao_fornecedor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pedidos_reposicao
    ADD CONSTRAINT pedidos_reposicao_fornecedor_id_fkey FOREIGN KEY (fornecedor_id) REFERENCES public.fornecedores(id);


--
-- TOC entry 4701 (class 2606 OID 16635)
-- Name: pedidos_reposicao pedidos_reposicao_produto_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pedidos_reposicao
    ADD CONSTRAINT pedidos_reposicao_produto_id_fkey FOREIGN KEY (produto_id) REFERENCES public.produtos(id);


--
-- TOC entry 4696 (class 2606 OID 16588)
-- Name: produtos produtos_fornecedor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.produtos
    ADD CONSTRAINT produtos_fornecedor_id_fkey FOREIGN KEY (fornecedor_id) REFERENCES public.fornecedores(id);


--
-- TOC entry 4697 (class 2606 OID 16602)
-- Name: vendas vendas_cliente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vendas
    ADD CONSTRAINT vendas_cliente_id_fkey FOREIGN KEY (cliente_id) REFERENCES public.clientes(id);


-- Completed on 2026-07-27 17:44:17

--
-- PostgreSQL database dump complete
--

\unrestrict lYniUT7k2cw2UlwTvOorC1ueXVt390Dd1mPkh1TBQrfFVTnWhluoanF2mFggBlE

