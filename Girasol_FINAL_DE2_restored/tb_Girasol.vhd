library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_Girasol is
    -- Testbench não tem portas! É uma entidade vazia.
end tb_Girasol;

architecture behavior of tb_Girasol is

    -- Componente a ser testado (O seu projeto)
    component Girasol_RTL
    Port (
        clk       : in STD_LOGIC;
        rst       : in STD_LOGIC;
        sensor_L  : in STD_LOGIC_VECTOR(7 downto 0);
        sensor_R  : in STD_LOGIC_VECTOR(7 downto 0);
        motor_cw  : out STD_LOGIC;
        motor_ccw : out STD_LOGIC
    );
    end component;

    -- Sinais para conectar no componente
    signal clk : std_logic := '0';
    signal rst : std_logic := '0';
    signal sensor_L : std_logic_vector(7 downto 0) := (others => '0');
    signal sensor_R : std_logic_vector(7 downto 0) := (others => '0');
    signal motor_cw : std_logic;
    signal motor_ccw : std_logic;

    -- Definição do Clock (10ns = 100MHz simulação)
    constant clk_period : time := 10 ns;

begin

    -- Instanciar o Girasol (DUT - Device Under Test)
    uut: Girasol_RTL port map (
        clk => clk,
        rst => rst,
        sensor_L => sensor_L,
        sensor_R => sensor_R,
        motor_cw => motor_cw,
        motor_ccw => motor_ccw
    );

    -- Processo do Clock
    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Processo de Estímulos (O Roteiro do Teste)
    stim_proc: process
    begin
        -- 1. Reset inicial
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        wait for clk_period*2;

        -- 2. Cenário: Tudo escuro/igual (Motor deve ficar PARADO)
        -- Esquerda = 50, Direita = 50
        sensor_L <= std_logic_vector(to_unsigned(50, 8));
        sensor_R <= std_logic_vector(to_unsigned(50, 8));
        wait for 100 ns; -- Espera o filtro encher

        -- 3. Cenário: Sol na Esquerda (Motor deve girar CCW)
        -- Esquerda sobe para 100, Direita fica em 50
        sensor_L <= std_logic_vector(to_unsigned(100, 8));
        wait for 200 ns;

        -- 4. Cenário: Sol se move para a Direita (Motor deve girar CW)
        -- Esquerda cai para 50, Direita sobe para 100
        sensor_L <= std_logic_vector(to_unsigned(50, 8));
        sensor_R <= std_logic_vector(to_unsigned(100, 8));
        wait for 200 ns;

        -- 5. Cenário: Diferença pequena (Histerese/Zona Morta)
        -- Direita = 100, Esquerda = 105 (Diferença é 5, menor que o limite 10)
        -- Motor deve PARAR (não deve tentar corrigir diferença pequena)
        sensor_L <= std_logic_vector(to_unsigned(105, 8));
        wait for 200 ns;

        -- Fim da simulação
        assert false report "Fim da Simulação com Sucesso!" severity failure;
    end process;

end behavior;