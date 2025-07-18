-- Laboratory RA solutions/versuch4
-- Sommersemester 25
-- Group Details
-- Lab Date: 20.05.2025
-- 1. Participant First and Last Name: Maximilan Wolf
-- 2. Participant First and Last Name: Esad-Muhammed Cekmeci

-- ========================================================================
-- Author:       Niklas Gutsmiedl
-- Last updated: 02.2024
-- Description:  Register to hold signals of type controlWord,
--               as defined in types.vhdl. Used as phase registers  
--               for the control path in the RV pipeline
-- ========================================================================
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.MATH_REAL.all;
use work.Constant_Package.all;
use work.types.all;

entity ControlWordRegister is

  port (
    pi_rst : in std_logic := '0';
    pi_clk : in std_logic := '0';
    pi_flush : in std_logic := '0';
    pi_controlWord : in controlWord := CONTROL_WORD_INIT; -- incoming control word
    po_controlWord : out controlWord := CONTROL_WORD_INIT -- outgoing control word
  );
end ControlWordRegister;

architecture arc1 of ControlWordRegister is
  signal s_controlWord : controlWord := CONTROL_WORD_INIT;
begin

  process (pi_clk, pi_rst)

  begin

    if (pi_rst) then
      s_controlWord <= CONTROL_WORD_INIT;
    elsif rising_edge (pi_clk) then
      if pi_flush then
        s_controlWord <= control_word_init;
      else
        s_controlWord <= pi_controlWord; -- update register contents on falling clock edge
      end if;
    end if;
  end process;

  po_controlWord <= s_controlWord;
end arc1;
