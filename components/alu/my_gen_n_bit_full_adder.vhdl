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

entity my_gen_n_bit_full_adder is
  generic (
    G_DATA_WIDTH : integer := DATA_WIDTH_GEN
  );
  port (
    -- begin solution:
    pi_a, pi_b : in std_logic_vector(G_DATA_WIDTH - 1 downto 0) := (others => '0');
    pi_carryIn : in std_logic := '0';
    po_sum : out std_logic_vector(G_DATA_WIDTH - 1 downto 0) := (others => '0');
    po_carryOut : out std_logic := '0'
    -- end solution!!
  );
end my_gen_n_bit_full_adder;

-- structure
architecture structure of my_gen_n_bit_full_adder is
  -- begin solution:
  signal s_carry, s_b : std_logic_vector(G_DATA_WIDTH downto 0) := (others => '0');
begin
  s_carry(0) <= pi_carryIn;
  po_carryOut <= s_carry(G_DATA_WIDTH);
  GEN : for i in 0 to G_DATA_WIDTH - 1 generate
    FA : entity work.my_full_adder(structure)
      port map(
        pi_a => pi_a(i),
        pi_b => s_b(i),
        pi_carryIn => s_carry(i),
        po_sum => po_sum(i),
        po_carryOut => s_carry(i + 1)
      );
    s_b(i) <= ((s_carry(0) nand s_carry(0)) nand pi_b(i)) nand (s_carry(0) nand (pi_b(i) nand pi_b(i)));
  end generate;
  -- end solution!!
end structure;
