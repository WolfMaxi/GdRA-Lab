-- Laboratory RA solutions/versuch3
-- Sommersemester 25
-- Group Details
-- Lab Date:
-- 1. Participant First and Last Name: 
-- 2. Participant First and Last Name:

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Constant_package.all;
use work.types.all;

entity decoder is
    -- begin solution:
    generic (
        word_width: integer := WORD_WIDTH
    );
    port (
        pi_clk: in STD_LOGIC := '0';
        pi_instruction: in STD_LOGIC_VECTOR(word_width - 1 downto 0) := (others => '0')
    );
    -- end solution!!
end entity decoder;
architecture arc of decoder is
begin
    -- begin solution:
    -- end solution!!
end architecture;