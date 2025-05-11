-- Laboratory RA solutions/versuch3
-- Sommersemester 25
-- Group Details
-- Lab Date:
-- 1. Participant First and Last Name: 
-- 2. Participant First and Last Name:

-- ========================================================================
-- Description:  Sign extender for a RV32I processor. Takes the entire instruction
--               and produces a 32-Bit value by sign-extending, shifting and piecing
--               together the immedate value in the instruction.
-- ========================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constant_package.all;

entity signExtension is
    -- begin solution:
    generic (
        word_width : integer := WORD_WIDTH
    );
    port (
        pi_instr : in std_logic_vector(word_width - 1 downto 0);
        po_jumpImm : out std_logic_vector(word_width - 1 downto 0);
        po_branchImm : out std_logic_vector(word_width - 1 downto 0);
        po_unsignedImm : out std_logic_vector(word_width - 1 downto 0);
        po_immediateImm : out std_logic_vector(word_width - 1 downto 0);
        po_storeImm : out std_logic_vector(word_width - 1 downto 0)
    );
    -- end solution!!
end entity signExtension;

architecture arc of signExtension is
    -- begin solution:
    --signal s_jumpImm : std_logic_vector(20 downto 0) := (others => '0');
    --signal s_branchImm : std_logic_vector(12 downto 0) := (others => '0');
    --signal s_immediateImm : std_logic_vector(11 downto 0) := (others => '0');
    --signal s_storeImm : std_logic_vector(11 downto 0) := (others => '0');

begin
    process (pi_instr)

        variable v_immediateImm : signed (11 downto 0) := (others => '0');
        variable v_storeImm : signed (11 downto 0) := (others => '0');
        variable v_branchImm : signed (12 downto 0) := (others => '0');
        variable v_jumpImm : signed (20 downto 0) := (others => '0');

    begin
        v_immediateImm := signed(pi_instr(31 downto 20));
        po_immediateImm <= std_logic_vector(resize(v_immediateImm, word_width));

        v_storeImm := signed(pi_instr(31 downto 25) & pi_instr(11 downto 7));
        po_storeImm <= std_logic_vector(resize(v_storeImm, word_width));

        v_branchImm := signed(pi_instr(31) & pi_instr(7) & pi_instr(30 downto 25) & pi_instr(11 downto 8) & '0');
        po_branchImm <= std_logic_vector(resize(v_branchImm, word_width));

        v_jumpImm := signed(pi_instr(31) & pi_instr(19 downto 12) & pi_instr(20) & pi_instr(30 downto 21) & '0');
        po_jumpImm <= std_logic_vector(resize(v_jumpImm, word_width));

        po_unsignedImm <= pi_instr(word_width - 1 downto 12) & (11 downto 0 => '0');
    end process;
    -- end solution!!
end architecture arc;