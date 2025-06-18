library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity cronometro is
    Port (
        clk    : in  STD_LOGIC;                -- Clock da placa
        botao  : in  STD_LOGIC;                -- Controle sequencial (Start/Stop/Reset)
        seg    : out STD_LOGIC_VECTOR(6 downto 0); -- Unidade de segundos
        seg_d  : out STD_LOGIC_VECTOR(6 downto 0); -- Dezena de segundos
        min    : out STD_LOGIC_VECTOR(6 downto 0); -- Unidade de minutos
        min_d  : out STD_LOGIC_VECTOR(6 downto 0)  -- Dezena de minutos
    );
end cronometro;

architecture Behavioral of cronometro is

    -- Clock divisor (50MHz -> 1Hz)
    signal count_clk : unsigned(25 downto 0) := (others => '0');
    signal clk_1hz   : STD_LOGIC := '0';

    -- Controle do botão
    signal botao_last : STD_LOGIC := '0';
    signal estado     : integer range 0 to 2 := 0; -- 0=stop, 1=start, 2=reset

    -- Contadores
    signal segundos_u : integer range 0 to 9 := 0;
    signal segundos_d : integer range 0 to 5 := 0;
    signal minutos_u  : integer range 0 to 9 := 0;
    signal minutos_d  : integer range 0 to 0 := 0; -- Máximo até 9 minutos

begin

    -------------------------------------------------------------------
    -- Divisor de clock (gera 1Hz)
    -------------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            if count_clk = 50_000_000 - 1 then
                count_clk <= (others => '0');
                clk_1hz <= not clk_1hz;
            else
                count_clk <= count_clk + 1;
            end if;
        end if;
    end process;

    -------------------------------------------------------------------
    -- Controle do botão sequencial
    -------------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            botao_last <= botao;
            if (botao = '1') and (botao_last = '0') then -- Detecção de borda de subida
                if estado = 0 then
                    estado <= 1; -- Start
                elsif estado = 1 then
                    estado <= 2; -- Stop
                else
                    estado <= 0; -- Reset
                end if;
            end if;
        end if;
    end process;

    -------------------------------------------------------------------
    -- Cronômetro
    -------------------------------------------------------------------
    process(clk_1hz)
    begin
        if rising_edge(clk_1hz) then
            if estado = 0 then -- Reset
                segundos_u <= 0;
                segundos_d <= 0;
                minutos_u  <= 0;
                minutos_d  <= 0;
            elsif estado = 1 then -- Start
                -- Incrementa segundos unidades
                if segundos_u = 9 then
                    segundos_u <= 0;
                    -- Incrementa segundos dezenas
                    if segundos_d = 5 then
                        segundos_d <= 0;
                        -- Incrementa minutos unidades
                        if minutos_u = 9 then
                            minutos_u <= 0;
                            -- Incrementa minutos dezenas (se desejado até 9 minutos)
                            if minutos_d = 0 then
                                minutos_d <= 0; -- Mantém 0 porque é só até 9 minutos
                            end if;
                        else
                            minutos_u <= minutos_u + 1;
                        end if;
                    else
                        segundos_d <= segundos_d + 1;
                    end if;
                else
                    segundos_u <= segundos_u + 1;
                end if;
            end if; -- estado 2 é stop → não faz nada
        end if;
    end process;

    -------------------------------------------------------------------
    -- Conversão para 7 segmentos
    -------------------------------------------------------------------
    function bcd_to_7seg(bcd : integer) return STD_LOGIC_VECTOR is
        variable seg : STD_LOGIC_VECTOR(6 downto 0);
    begin
        case bcd is
            when 0  => seg := "1000000";
            when 1  => seg := "1111001";
            when 2  => seg := "0100100";
            when 3  => seg := "0110000";
            when 4  => seg := "0011001";
            when 5  => seg := "0010010";
            when 6  => seg := "0000010";
            when 7  => seg := "1111000";
            when 8  => seg := "0000000";
            when 9  => seg := "0010000";
            when others => seg := "1111111"; -- apagado
        end case;
        return seg;
    end function;

    -- Atribuição dos displays
    seg   <= bcd_to_7seg(segundos_u);
    seg_d <= bcd_to_7seg(segundos_d);
    min   <= bcd_to_7seg(minutos_u);
    min_d <= bcd_to_7seg(minutos_d);

end Behavioral;
