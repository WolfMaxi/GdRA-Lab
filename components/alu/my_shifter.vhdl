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
use IEEE.NUMERIC_STD.all;
use IEEE.MATH_REAL.all;
use work.CONSTANT_Package.all;

entity my_shifter is
    generic (
        G_DATA_WIDTH : integer := DATA_WIDTH_GEN
    );
    port (
        -- begin solution:
        P_OP1, P_OP2 : in std_logic_vector(G_DATA_WIDTH - 1 downto 0) := (others => '0');
        P_SHIFT_TYPE, P_SHIFT_DIR : in std_logic := '0';
        P_RES : out std_logic_vector(G_DATA_WIDTH - 1 downto 0) := (others => '0')
        -- end solution!!
    );
end entity;

architecture behavior of my_shifter is
    signal s_shamtInt : integer range 0 to (2 ** (integer(log2(real(G_DATA_WIDTH))))) := 0;
    signal s_tmp_val : std_logic := '0';
begin
    s_shamtInt <= to_integer(unsigned(P_OP2(integer(log2(real(G_DATA_WIDTH))) - 1 downto 0)));
    -- begin solution:
    process (P_OP1, P_OP2, P_SHIFT_TYPE, P_SHIFT_DIR)
    begin
        if P_SHIFT_DIR = '1' then
            if P_SHIFT_TYPE = '1' then
                P_RES <= std_logic_vector(shift_right(signed(P_OP1), to_integer(unsigned(P_OP2))));
            else
                P_RES <= std_logic_vector(shift_right(unsigned(P_OP1), to_integer(unsigned(P_OP2))));
            end if;
        else
            if P_SHIFT_TYPE = '1' then
                P_RES <= std_logic_vector(shift_left(signed(P_OP1), to_integer(unsigned(P_OP2))));
            else
                P_RES <= std_logic_vector(shift_left(unsigned(P_OP1), to_integer(unsigned(P_OP2))));
            end if;
        end if;
    end process;
    -- end solution!!
end architecture behavior;

architecture dataflow of my_shifter is
    signal s_shamtInt : integer range 0 to (2 ** (integer(log2(real(G_DATA_WIDTH)))));
    signal s_sra, s_srl, s_sla, s_sll, s_res : std_logic_vector(G_DATA_WIDTH - 1 downto 0) := (others => '0');
    signal s_sel : std_logic_vector(1 downto 0) := (others => '0');

begin
    --begin solution: 
    s_sra <= std_logic_vector(shift_right(signed(P_OP1), to_integer(unsigned(P_OP2))));
    s_srl <= std_logic_vector(shift_right(unsigned(P_OP1), to_integer(unsigned(P_OP2))));
    s_sla <= std_logic_vector(shift_left(signed(P_OP1), to_integer(unsigned(P_OP2))));
    s_sll <= std_logic_vector(shift_left(unsigned(P_OP1), to_integer(unsigned(P_OP2))));

    s_sel <= P_SHIFT_DIR & P_SHIFT_TYPE;
    with s_sel select
        s_res <= s_sra when "11",
        s_srl when "10",
        s_sla when "01",
        s_sll when "00",
        (others => '0') when others;
    --end solution!!
    P_RES <= s_res;
end architecture dataflow;