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
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.Constant_Package.ALL;

-- begin solution:
entity my_gen_and is
    generic (
        G_DATA_WIDTH: Integer := DATA_WIDTH_GEN
    );
    port (
        P_OP1: in std_logic_vector(G_DATA_WIDTH - 1 downto 0);
        P_OP2: in std_logic_vector(G_DATA_WIDTH - 1 downto 0);
        P_RESULT: out std_logic_vector(G_DATA_WIDTH - 1 downto 0)
    );
end my_gen_and;

architecture behaviour of my_gen_and is
    begin
        P_RESULT <= P_OP1 and P_OP2;
end architecture behaviour;
-- end solution!!
