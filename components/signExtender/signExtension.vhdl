-- Laboratory RA solutions/versuch3
-- Sommersemester 25
-- Group Details
-- Lab Date: 03.06.2025
-- 1. Participant First and Last Name: Maximilian Wolf
-- 2. Participant First and Last Name: Esad-Muhammed Cekmeci

-- ========================================================================
-- Description:  Sign extender for a RV32I processor. Takes the entire instruction
--               and produces a 32-Bit value by sign-extending, shifting and piecing
--               together the immedate value in the instruction.
-- ========================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.constant_package.all;

/*
    Extracts each immediate type from instruction and sign extends them.
    Immediates are being used for Jump, Branch, Store and Immediate Instructions.
*/

entity signExtension is
    -- begin solution:
    generic (
        word_width : integer := WORD_WIDTH
    );
    port (
        pi_instr : in std_logic_vector(word_width - 1 downto 0) := (others => '0');
        po_jumpImm : out std_logic_vector(word_width - 1 downto 0) := (others => '0');
        po_branchImm : out std_logic_vector(word_width - 1 downto 0) := (others => '0');
        po_unsignedImm : out std_logic_vector(word_width - 1 downto 0) := (others => '0'); --für adressberechnung
        po_immediateImm : out std_logic_vector(word_width - 1 downto 0) := (others => '0');
        po_storeImm : out std_logic_vector(word_width - 1 downto 0) := (others => '0');
        po_selectedImm : out std_logic_vector(word_width - 1 downto 0) := (others => '0') --für ALU-Operationen
    );
    -- end solution!!
end entity signExtension;

architecture arc of signExtension is
    signal s_immediateImm : std_logic_vector(word_width - 1 downto 0);
    signal s_storeImm : std_logic_vector(word_width - 1 downto 0);
    signal s_branchImm : std_logic_vector(word_width - 1 downto 0);
    signal s_jumpImm : std_logic_vector(word_width - 1 downto 0);
    signal s_unsignedImm : std_logic_vector(word_width - 1 downto 0);
    signal s_opcode : std_logic_vector(6 downto 0);
begin
    -- Deconstruct each immediate type from instruction
    s_immediateImm <= std_logic_vector(resize(signed(pi_instr(31 downto 20)), word_width));
    s_storeImm <= std_logic_vector(resize(signed(pi_instr(31 downto 25) & pi_instr(11 downto 7)), word_width));
    s_branchImm <= std_logic_vector(resize(signed(pi_instr(31) & pi_instr(7) & pi_instr(30 downto 25) & pi_instr(11 downto 8) & '0'), word_width));
    s_jumpImm <= std_logic_vector(resize(signed(pi_instr(31) & pi_instr(19 downto 12) & pi_instr(20) & pi_instr(30 downto 21) & '0'), word_width));
    s_unsignedImm <= pi_instr(word_width - 1 downto 12) & (11 downto 0 => '0');
    s_jumpImm <= std_logic_vector(resize(signed(pi_instr(31) & pi_instr(19 downto 12) & pi_instr(20) & pi_instr(30 downto 21) & '0'), word_width));
    s_unsignedImm <= pi_instr(31 downto 12) & std_logic_vector(to_unsigned(0, 12)); -- Explicitly 12 zeros

    -- Opcode for selecting immediate
    s_opcode <= pi_instr(6 downto 0);

    -- Signal assignment for selected immediate
    po_selectedImm <= s_immediateImm when (s_opcode = I_INS_OP or s_opcode = L_INS_OP or s_opcode = JALR_INS_OP) else
                      s_storeImm when (s_opcode = S_INS_OP) else
                      s_branchImm when (s_opcode = B_INS_OP) else
                      s_unsignedImm when (s_opcode = LUI_INS_OP or s_opcode = AUIPC_INS_OP) else
                      s_jumpImm when (s_opcode = JAL_INS_OP) else
                      (others => '0');

    -- Set immediates for eatch type
    po_immediateImm <= s_immediateImm;
    po_storeImm <= s_storeImm;
    po_branchImm <= s_branchImm;
    po_jumpImm <= s_jumpImm;
    po_unsignedImm <= s_unsignedImm;
end architecture arc;
