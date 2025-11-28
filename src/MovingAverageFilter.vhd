library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MovingAverageFilter is
    Port (
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        sensor_in : in STD_LOGIC_VECTOR(7 downto 0);
        filter_out : out STD_LOGIC_VECTOR(7 downto 0)
    );
end MovingAverageFilter;

architecture RTL of MovingAverageFilter is
    -- Sinais internos para guardar os valores (Registradores)
    signal reg0, reg1, reg2, reg3 : unsigned(7 downto 0);
    
    -- Sinais internos para fazer a soma (precisa ser maior para não estourar)
    signal sum_stage1_a : unsigned(8 downto 0);
    signal sum_stage1_b : unsigned(8 downto 0);
    signal total_sum    : unsigned(9 downto 0);
    
begin
    -- PARTE 1: Memória (Registradores)
    -- Aqui guardamos as últimas 4 leituras do sensor
    process(clk, rst)
    begin
        if rst = '0' then
            reg0 <= (others => '0');
            reg1 <= (others => '0');
            reg2 <= (others => '0');
            reg3 <= (others => '0');
        elsif rising_edge(clk) then
            reg0 <= unsigned(sensor_in); -- Entra valor novo
            reg1 <= reg0;                -- Passa pro lado ->
            reg2 <= reg1;                -- Passa pro lado ->
            reg3 <= reg2;                -- Passa pro lado ->
        end if;
    end process;

    -- PARTE 2: Cálculo (Lógica Combinacional)
    -- Soma tudo. Note que NÃO usamos "process" aqui.
    sum_stage1_a <= resize(reg0, 9) + resize(reg1, 9);
    sum_stage1_b <= resize(reg2, 9) + resize(reg3, 9);
    total_sum    <= resize(sum_stage1_a, 10) + resize(sum_stage1_b, 10);

    -- PARTE 3: Divisão por 4
    -- Pegamos os bits mais significativos (descartamos os 2 últimos)
    filter_out <= std_logic_vector(total_sum(9 downto 2));

end RTL;
