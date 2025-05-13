-- Laboratory RA solutions/versuch4
-- Sommersemester 25
-- Group Details
-- Lab Date:
-- 1. Participant First and Last Name: 
-- 2. Participant First and Last Name:

-- ========================================================================
-- Author:       Marcel Rieß
-- Last updated: 09.04.2025
-- Description:  R-Only-RISC-V foran incomplete RV32I implementation, support
--               only R-Instructions. 
--
-- ========================================================================

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use work.constant_package.all;
  use work.types.all;

entity R_only_RISC_V is
  port (
    pi_rst         : in    std_logic := '0';
    pi_clk         : in    std_logic;
    pi_instruction : in    memory := (others => (others => '0'));
    po_registersOut : out   registerMemory := (others => (others => '0'));
    po_debugdatamemory :out memory :=(others => (others => '0'))
   );
end entity R_only_RISC_V;

architecture structure of R_only_RISC_V is

  constant ADD_FOUR_TO_ADDRESS   : std_logic_vector(WORD_WIDTH - 1 downto 0)      := std_logic_vector(to_signed((4), WORD_WIDTH));
  -- signals
  -- begin solution:
  -- end solution!!

begin

-- instanciate program counter adder and pc-register
-- begin solution:
-- end solution!!

-- instanciate instruction cache 
-- begin solution:
-- end solution!!
-- instanciate instruction decoder
-- begin solution:
-- end solution!!
-- instanciate register file
-- begin solution:
-- end solution!!
-- instanciate ALU
-- begin solution:
-- end solution!!
-- instanciate pipeline-register id to ex for op1
-- begin solution:
-- end solution!!
-- instanciate pipeline-register id to ex for op2
-- begin solution:
-- end solution!!


-- instanciate pipeline-register if to id for instruction
-- begin solution:
-- end solution!!

-- instanciate pipeline-register id to ex for controlword
-- begin solution:
-- end solution!!
-- instanciate pipeline-register id to ex for rs-adress
-- begin solution:
-- end solution!!

-- instanciate pipeline-register ex to mem for controlword
-- begin solution:
-- end solution!!
-- instanciate pipeline-register ex to mem for rs-adress
-- begin solution:
-- end solution!!
-- instanciate pipeline-register ex to mem for alu-result
-- begin solution:
-- end solution!!

-- instanciate pipeline-register mem to wb for controlword
-- begin solution:
-- end solution!!
-- instanciate pipeline-register ex to mem for rs-adress
-- begin solution:
-- end solution!!
-- instanciate pipeline-register mem to wb for alu-result
-- begin solution:
-- end solution!!

end architecture;
