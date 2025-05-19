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
        pi_op1, pi_op2 : in std_logic_vector(G_DATA_WIDTH - 1 downto 0) := (others => '0');
        pi_shiftType, pi_shiftDir : in std_logic := '0';
        po_res : out std_logic_vector(G_DATA_WIDTH - 1 downto 0) := (others => '0')
        -- end solution!!
    );
end entity;

architecture behavior of my_shifter is
    signal s_shamtInt : integer range 0 to (2 ** (integer(log2(real(G_DATA_WIDTH))))) := 0;
begin
    s_shamtInt <= to_integer(unsigned(pi_op2(integer(log2(real(G_DATA_WIDTH))) - 1 downto 0)));
    -- begin solution:
    process (pi_op1, pi_op2, pi_shiftType, pi_shiftDir)
    begin
        if pi_shiftDir = '1' then
            if pi_shiftType = '1' then
                po_res <= std_logic_vector(shift_right(signed(pi_op1), to_integer(unsigned(pi_op2))));
            else
                po_res <= std_logic_vector(shift_right(unsigned(pi_op1), to_integer(unsigned(pi_op2))));
            end if;
        else
            if pi_shiftType = '1' then
                po_res <= std_logic_vector(shift_left(signed(pi_op1), to_integer(unsigned(pi_op2))));
            else
                po_res <= std_logic_vector(shift_left(unsigned(pi_op1), to_integer(unsigned(pi_op2))));
            end if;
        end if;
    end process;
    -- end solution!!
end architecture behavior;

architecture dataflow of my_shifter is
    signal s_sra, s_srl, s_sla, s_sll, s_res : std_logic_vector(G_DATA_WIDTH - 1 downto 0) := (others => '0');
    signal s_sel : std_logic_vector(1 downto 0) := (others => '0');

begin
    --begin solution: 
    s_sra <= std_logic_vector(shift_right(signed(pi_op1), to_integer(unsigned(pi_op2))));
    s_srl <= std_logic_vector(shift_right(unsigned(pi_op1), to_integer(unsigned(pi_op2))));
    s_sla <= std_logic_vector(shift_left(signed(pi_op1), to_integer(unsigned(pi_op2))));
    s_sll <= std_logic_vector(shift_left(unsigned(pi_op1), to_integer(unsigned(pi_op2))));

    s_sel <= pi_shiftDir & pi_shiftType;
    with s_sel select
        s_res <= s_sra when "11",
        s_srl when "10",
        s_sla when "01",
        s_sll when "00",
        (others => '0') when others;
    --end solution!!
    po_res <= s_res;
end architecture dataflow;
