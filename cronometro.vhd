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
    signal estado     : integer range 0 to 2 := 0; -- 0
