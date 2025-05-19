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

entity my_full_adder is
  port (
    -- begin solution:
    pi_a, pi_b, pi_carryIn : in std_logic;
    po_sum, po_carryOut : out std_logic
    -- end solution!!
  );
end my_full_adder;

-- structure
architecture structure of my_full_adder is
  -- begin solution:
  signal s_sum, s_carry1, s_carry2 : std_logic := '0';
begin
  HA_1 : entity work.my_half_adder(dataflow)
    port map(
      pi_a => pi_a,
      pi_b => pi_b,
      po_sum => s_sum,
      po_carryOut => s_carry1
    );

  HA_2 : entity work.my_half_adder(dataflow)
    port map(
      pi_a => s_sum,
      pi_b => pi_carryIn,
      po_sum => po_sum,
      po_carryOut => s_carry2
    );

  -- C1 or C2 = -(-(C1 or C2))
  --          = -(-(C1) and -(C2))
  --          = (C1 NAND C1) NAND (C2 NAND C2)

  po_carryOut <= (S_CARRY1 nand S_CARRY1) nand (S_CARRY2 nand S_CARRY2);

  -- end solution!!
end structure;