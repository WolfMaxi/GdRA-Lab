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
    P_A, P_B, P_CARRY_IN: in std_logic;
    P_SUM, P_CARRY_OUT: out std_logic
    -- end solution!!
  );
end my_full_adder;

-- structure
architecture structure of my_full_adder is
-- begin solution:
  signal S_SUM, S_CARRY1, S_CARRY2: std_logic := '0';
begin
  HA_1: entity work.my_half_adder(dataflow)
    port map(
      P_A => P_A,
      P_B => P_B,
      P_SUM => S_SUM,
      P_CARRY_OUT => S_CARRY1
    );

  HA_2: entity work.my_half_adder(dataflow)
    port map(
      P_A => S_SUM,
      P_B => P_CARRY_IN,
      P_SUM => P_SUM,
      P_CARRY_OUT => S_CARRY2
    );

  -- C1 or C2 = -(-(C1 or C2))
  --          = -(-(C1) and -(C2))
  --          = (C1 NAND C1) NAND (C2 NAND C2)

  P_CARRY_OUT <= (S_CARRY1 NAND S_CARRY1) NAND (S_CARRY2 NAND S_CARRY2);

-- end solution!!
end structure;
