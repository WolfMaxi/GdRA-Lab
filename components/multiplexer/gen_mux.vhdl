-- Laboratory RA solutions/versuch1
-- Sommer Semester 25
-- Group Details
-- Lab Date: 03.06.2025
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
        pi_in0, pi_in1, pi_in2, pi_in3: in STD_LOGIC_VECTOR(dataWidth - 1 downto 0) := (others => '0');
        pi_sel: in STD_LOGIC_VECTOR(1 downto 0) := (others => '0'); -- 2-bit selector for 4 inputs
        pOut: out STD_LOGIC_VECTOR(dataWidth - 1 downto 0) := (others => '0')
    );
end gen_mux;

architecture behavior of gen_mux is
begin
    process(pi_in0, pi_in1, pi_in2, pi_in3, pi_sel)
    begin
        case pi_sel is
            when "00" =>
                pOut <= pi_in0;
            when "01" =>
                pOut <= pi_in1;
            when "10" =>
                pOut <= pi_in2;
            when "11" =>
                pOut <= pi_in3;
            when others =>
                pOut <= (others => '0');
        end case;
    end process;
end behavior;
