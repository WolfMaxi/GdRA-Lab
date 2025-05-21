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
use IEEE.STD_LOGIC_1164.all;
use work.Constant_Package.all;

-- begin solution:
entity my_gen_xor is
    generic (
        G_DATA_WIDTH : integer := DATA_WIDTH_GEN
    );
    port (
        pi_op1, pi_op2 : in std_logic_vector(G_DATA_WIDTH - 1 downto 0) := (others => '0');
        po_res : out std_logic_vector(G_DATA_WIDTH - 1 downto 0) := (others => '0')
    );
end my_gen_xor;

architecture behaviour of my_gen_xor is
begin
    po_res <= pi_op1 xor pi_op2;
end architecture behaviour;
-- end solution!!
