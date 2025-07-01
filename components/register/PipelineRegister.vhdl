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
use work.Constant_Package.all;

entity PipelineRegister is
    generic (
        registerWidth : integer := DATA_WIDTH_GEN
    );
    port (
        pi_clk, pi_rst, pi_flush : in STD_LOGIC := '0';
        pi_enable: in STD_LOGIC := '1';
        pi_data: in STD_LOGIC_VECTOR(registerWidth - 1 downto 0) := (others => '0');
        po_data: out STD_LOGIC_VECTOR(registerWidth - 1 downto 0) := (others => '0')
    );
end entity;

architecture behavior of PipelineRegister is
begin
    process (pi_clk, pi_rst)
    begin
    	if pi_rst then
	        po_data <= (others => '0');
	    elsif rising_edge(pi_clk) then
            if pi_flush then
                po_data <= (others => '0');
            elsif pi_enable then
                po_data <= pi_data;
            end if;
        end if;
    end process;
end behavior;
