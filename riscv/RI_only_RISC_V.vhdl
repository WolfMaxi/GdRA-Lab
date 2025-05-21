-- Laboratory RA solutions/versuch5
-- Sommersemester 25
-- Group Details
-- Lab Date:
-- 1. Participant First and Last Name: 
-- 2. Participant First and Last Name:

-- ========================================================================
-- Author:       Marcel Rieß
-- Last updated: 22.05.2024
-- Description:  RUI-Only-RISC-V for an incomplete RV32I implementation, 
--               support only R/I/U-Instructions. 
-- ========================================================================

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use work.constant_package.all;
  use work.types.all;

entity ri_only_RISC_V is
  port (
    pi_rst         : in    std_logic;
    pi_clk         : in    std_logic;
    pi_instruction : in    memory := (others => (others => '0'));
    po_registersOut : out   registerMemory := (others => (others => '0'))
  );
end entity ri_only_RISC_V;

architecture structure of ri_only_RISC_V is

  constant PERIOD                : time                                            := 10 ns;
  constant ADD_FOUR_TO_ADDRESS   : std_logic_vector(WORD_WIDTH - 1 downto 0)       := std_logic_vector(to_signed((4), WORD_WIDTH));
  -- signals
  -- begin solution:
  -- end solution!!
end architecture;
