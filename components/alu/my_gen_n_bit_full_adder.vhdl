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
use work.Constant_Package.ALL;

entity my_gen_n_bit_full_adder is
  Generic (
    G_DATA_WIDTH : integer := DATA_WIDTH_GEN
  );
  port (
    -- begin solution:
    P_A, P_B: in std_logic_vector(G_DATA_WIDTH - 1 downto 0);
    P_CARRY_IN: in std_logic := '0';
    P_SUM: out std_logic_vector(G_DATA_WIDTH - 1 downto 0);
    P_CARRY_OUT: out std_logic := '0'
    -- end solution!!
  );
end my_gen_n_bit_full_adder;

-- structure
architecture structure of my_gen_n_bit_full_adder is
-- begin solution:
  signal S_CARRY, S_B: std_logic_vector(G_DATA_WIDTH downto 0);
begin
  S_CARRY(0) <= P_CARRY_IN;
  P_CARRY_OUT <= S_CARRY(G_DATA_WIDTH);
  GEN: for i in 0 to G_DATA_WIDTH - 1 generate
    FA: entity work.my_full_adder(structure)
      port map (
        P_A => P_A(i),
        P_B => S_B(i),
        P_CARRY_IN => S_CARRY(i),
        P_SUM => P_SUM(i),
        P_CARRY_OUT => S_CARRY(i + 1)
      );
    S_B(i) <= ((S_CARRY(0) NAND S_CARRY(0)) NAND P_B(i)) NAND (S_CARRY(0) NAND (P_B(i) NAND P_B(i)));
  end generate;
-- end solution!!
end structure;
