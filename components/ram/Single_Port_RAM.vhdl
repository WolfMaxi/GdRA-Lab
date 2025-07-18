-- Laboratory RA solutions/versuch2
-- Sommersemester 25
-- Group Details
-- Lab Date:06.05.25
-- 1. Participant First and  Last Name: Maximilian Wolf
-- 2. Participant First and Last Name: Esad-Muhammed Cekmeci

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.constant_package.all;

entity Single_Port_RAM is
    generic (
        word_width: integer := WORD_WIDTH;
        adr_width: integer := ADR_WIDTH
    );
    port (
        pi_clk, pi_rst, pi_we: in STD_LOGIC := '0';
        pi_addr: in STD_LOGIC_VECTOR(adr_width - 1 downto 0) := (others => '0');
        pi_data: in STD_LOGIC_VECTOR(word_width - 1 downto 0) := (others => '0');
        po_data: out STD_LOGIC_VECTOR(word_width - 1 downto 0) := (others => '0')
    );
end entity Single_Port_RAM;

architecture behavior of Single_Port_RAM is
    type memory is array (0 to 2 ** adr_width - 1) of std_logic_vector(word_width - 1 downto 0);
    signal s_regs: memory := (others => (others => '0'));
begin
    process(pi_clk, pi_rst)
    begin
        if pi_rst then
            -- Reset all words
            s_regs <= (others => (others => '0'));
            po_data <= (others => '0'); 
        elsif rising_edge(pi_clk) then
            -- Set output to value of current address
            po_data <= s_regs(to_integer(unsigned(pi_addr)));
            if pi_we then
                s_regs(to_integer(unsigned(pi_addr))) <= pi_data;
            end if;
        end if;
    end process;
end behavior;
