library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Girasol_RTL is
    Port (
        clk       : in STD_LOGIC;
        rst       : in STD_LOGIC;
        sensor_L  : in STD_LOGIC_VECTOR(7 downto 0); -- Entrada Sensor Esquerdo
        sensor_R  : in STD_LOGIC_VECTOR(7 downto 0); -- Entrada Sensor Direito
        motor_cw  : out STD_LOGIC; -- Girar Horário (Clockwise)
        motor_ccw : out STD_LOGIC  -- Girar Anti-Horário
    );
end Girasol_RTL;

architecture RTL of Girasol_RTL is

    -- 1. Declaramos o COMPONENTE que criamos antes (o Filtro)
    component MovingAverageFilter
        Port (
            clk : in STD_LOGIC;
            rst : in STD_LOGIC;
            sensor_in : in STD_LOGIC_VECTOR(7 downto 0);
            filter_out : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;

    -- Sinais para conectar as saídas dos filtros
    signal L_filtrado, R_filtrado : std_logic_vector(7 downto 0);
    signal L_unsigned, R_unsigned : unsigned(7 downto 0);

    -- Definição da FSM (Máquina de Estados)
    type state_type is (PARADO, GIRA_ESQ, GIRA_DIR);
    signal estado_atual, proximo_estado : state_type;

    -- Constante de Histerese (Zona Morta)
    -- O motor só mexe se a diferença for maior que 10 (para evitar tremedeira)
    constant THRESHOLD : unsigned(7 downto 0) := to_unsigned(10, 8);

begin

    -- =========================================================
    -- BLOCO 1: INSTANCIAÇÃO DO DATAPATH (Os Filtros)
    -- =========================================================
    
    -- Filtro do Sensor Esquerdo
    Filtro_Esquerdo: MovingAverageFilter
    port map (
        clk => clk,
        rst => rst,
        sensor_in  => sensor_L,
        filter_out => L_filtrado
    );

    -- Filtro do Sensor Direito
    Filtro_Direito: MovingAverageFilter
    port map (
        clk => clk,
        rst => rst,
        sensor_in  => sensor_R,
        filter_out => R_filtrado
    );

    -- Conversão para unsigned para fazer contas
    L_unsigned <= unsigned(L_filtrado);
    R_unsigned <= unsigned(R_filtrado);

    -- =========================================================
    -- BLOCO 2: MÁQUINA DE ESTADOS (FSM)
    -- =========================================================

    -- Processo A: Memória de Estado 
    process(clk, rst)
    begin
        if rst = '1' then
            estado_atual <= PARADO;
        elsif rising_edge(clk) then
            estado_atual <= proximo_estado;
        end if;
    end process;

    -- Processo B: Lógica de Próximo Estado 
    -- Aqui decidimos o que fazer baseados nos sensores
    process(estado_atual, L_unsigned, R_unsigned)
    begin
        -- Valor padrão: fica como está
        proximo_estado <= estado_atual;

        case estado_atual is
            when PARADO =>
                if L_unsigned > (R_unsigned + THRESHOLD) then
                    proximo_estado <= GIRA_ESQ; -- Sol ta na esquerda
                elsif R_unsigned > (L_unsigned + THRESHOLD) then
                    proximo_estado <= GIRA_DIR; -- Sol ta na direita
                else
                    proximo_estado <= PARADO;
                end if;

            when GIRA_ESQ =>
                -- Se já equilibrou (diferença pequena), para.
                if L_unsigned <= (R_unsigned + THRESHOLD) then
                    proximo_estado <= PARADO;
                else
                    proximo_estado <= GIRA_ESQ;
                end if;

            when GIRA_DIR =>
                -- Se já equilibrou, para.
                if R_unsigned <= (L_unsigned + THRESHOLD) then
                    proximo_estado <= PARADO;
                else
                    proximo_estado <= GIRA_DIR;
                end if;
        end case;
    end process;

    -- =========================================================
    -- BLOCO 3: SAÍDAS 
    -- =========================================================
    with estado_atual select
        motor_cw <= '1' when GIRA_DIR,
                    '0' when others;

    with estado_atual select
        motor_ccw <= '1' when GIRA_ESQ,
                     '0' when others;

end RTL;