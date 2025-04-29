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

entity my_half_adder is
  port (
    -- begin solution:
    P_A, P_B: in std_logic;
    P_SUM, P_CARRY_OUT: out std_logic
    -- end solution!!
  );
end my_half_adder;

	--Notieren Sie ihre Umformungsschritte unter diesem Kommentar:
  
	-- begin solution:

  -- S  = A * (-B) + (-A) * B
  --    = -(-(A * (-B) + (-A) * B))
  --    = -(-(A * (-B)) * (-(-A) * B)))
  --    = (A NAND (B NAND B)) NAND ((A NAND A) NAND B)

  -- C  = A * B
  --    = -(-(A * B))
  --    = (A NAND B) NAND (A NAND B)

	-- end solution!!	

-- dataflow
architecture dataflow of my_half_adder is
signal s_temp : std_logic;
  begin
-- begin solution:
  P_SUM <= (P_A NAND (P_B NAND P_B)) NAND ((P_A NAND P_A) NAND P_B);
  P_CARRY_OUT <= (P_A NAND P_B) NAND (P_A NAND P_B);
-- end solution!!
end dataflow;
