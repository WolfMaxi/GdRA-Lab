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
    pi_a, pi_b : in std_logic;
    po_sum, po_carryOut : out std_logic
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
begin
  -- begin solution:
  po_sum <= (pi_a nand (pi_b nand pi_b)) nand ((pi_a nand pi_a) nand pi_b);
  po_carryOut <= (pi_a nand pi_b) nand (pi_a nand pi_b);
  -- end solution!!
end dataflow;
