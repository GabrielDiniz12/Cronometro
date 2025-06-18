library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_cronometro is
end tb_cronometro;

architecture sim of tb_cronometro is

    -- Sinais de entrada/saída da UUT (Unit Under Test)
    signal clk        : STD_LOGIC := '0';
    signal reset      : STD_LOGIC := '1';  -- nível alto = inativo (botão não pressionado)
    signal start_stop : STD_LOGIC := '1';  -- idem

    signal seg_anodo  : STD_LOGIC_VECTOR(3 downto 0);
    signal seg_catodo : STD_LOGIC_VECTOR(6 downto 0);

    constant CLK_PERIOD : time := 20 ns;  -- 50 MHz para simulação

begin

    -- Instancia o cronômetro
    uut: entity work.cronometro
        port map (
            clk        => clk,
            reset      => reset,
            start_stop => start_stop,
            seg_anodo  => seg_anodo,
            seg_catodo => seg_catodo
        );

    -- Geração de clock
    clk_process : process
    begin
        while now < 2 sec loop  -- simula por 2 segundos
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process;

    -- Estímulos de teste
    stim_proc: process
    begin
        -- Mantém reset pressionado por 100ns
        reset <= '0';  -- botão pressionado
        wait for 100 ns;
        reset <= '1';  -- solta botão

        -- Espera um pouco
        wait for 200 ns;

        -- Pressiona start
        start_stop <= '0';  -- botão pressionado
        wait for 40 ns;
        start_stop <= '1';  -- solta botão

        -- Espera 4 segundos simulados
        wait for 4 sec;

        -- Pressiona stop
        start_stop <= '0';
        wait for 40 ns;
        start_stop <= '1';

        -- Espera 2 segundos com cronômetro parado
        wait for 2 sec;

        -- Pressiona reset
        reset <= '0';
        wait for 100 ns;
        reset <= '1';

        wait;
    end process;

end sim;
