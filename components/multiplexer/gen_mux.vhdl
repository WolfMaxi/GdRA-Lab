-- Laboratory RA solutions/versuch1
-- Sommer Semester 25
-- Group Details
-- Lab Date: 29.04.2025
-- 1. Participant First and  Last Name: Maximilian Wolf
-- 2. Participant First and Last Name: Esad-Muhammed Cekmeci
 
 
-- coding conventions
-- g_<name> Generics
-- p_<name> Ports
-- c_<name> Constants
-- s_<name> Signals
-- v_<name> Variables

library ieee;
use ieee.std_logic_1164.all;
use work.constant_package.all;

entity gen_mux is
    generic (
        dataWidth: integer := DATA_WIDTH_GEN
    );
    port (
        pi_first, pi_second: in STD_LOGIC_VECTOR(dataWidth - 1 downto 0);
        pi_sel: in STD_LOGIC := '0';
        pOut: out STD_LOGIC_VECTOR(dataWidth - 1 downto 0)
    );
end gen_mux;

architecture behavior of gen_mux is
begin
    process(pi_first, pi_second, pi_sel)
    begin
        if pi_sel = '0' then
            pOut <= pi_first;
        else
            pOut <= pi_second;
        end if;
    end process;
end behavior;
