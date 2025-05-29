-- Laboratory RA solutions/versuch3
-- Sommersemester 25
-- Group Details
-- Lab Date: 13.06.2025
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

entity signExtension is --bitbreite des werts wird erweitert min signExtension
    -- begin solution:
    generic (
        word_width : integer := WORD_WIDTH
    );
    port ( --immedate um direkt in der Instruktion erhalten 
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
    signal s_immediateImm_calc : std_logic_vector(word_width - 1 downto 0);
    signal s_storeImm_calc     : std_logic_vector(word_width - 1 downto 0);
    signal s_branchImm_calc    : std_logic_vector(word_width - 1 downto 0);
    signal s_jumpImm_calc      : std_logic_vector(word_width - 1 downto 0);
    signal s_unsignedImm_calc  : std_logic_vector(word_width - 1 downto 0);
    signal s_opcode            : std_logic_vector(6 downto 0);
begin
    -- Extraktion wie gehabt:
    s_immediateImm_calc <= std_logic_vector(resize(signed(pi_instr(31 downto 20)), word_width));
    s_storeImm_calc     <= std_logic_vector(resize(signed(pi_instr(31 downto 25) & pi_instr(11 downto 7)), word_width));
    s_branchImm_calc    <= std_logic_vector(resize(signed(pi_instr(31)&pi_instr(7)&pi_instr(30 downto 25)&pi_instr(11 downto 8)&'0'), word_width));
    --s_jumpImm_calc      <= std_logic_vector(resize(signed(pi_instr(31)&pi_instr(19 downto 12)&pi_instr(20)&pi_instr(30 downto 21)&'0'), word_width));
    --s_unsignedImm_calc  <= pi_instr(word_width-1 downto 12) & (11 downto 0 => '0');
    s_jumpImm_calc      <= std_logic_vector(resize(signed(pi_instr(31) &         -- Imm[20]
                                                     pi_instr(19 downto 12) & -- Imm[19:12]
                                                     pi_instr(20) &         -- Imm[11]
                                                     pi_instr(30 downto 21) & -- Imm[10:1]
                                                     '0'                     -- Trailing zero
                                                    ), word_width));
    s_unsignedImm_calc <= pi_instr(31 downto 12) & std_logic_vector(to_unsigned(0, 12)); -- Explicitly 12 zeros

    -- Opcode als Signal für concurrent assignment
    s_opcode <= pi_instr(6 downto 0);

    -- concurrent conditional signal assignment
    po_selectedImm <= s_immediateImm_calc when (s_opcode = I_INS_OP or
                                                 s_opcode = L_INS_OP or
                                                 s_opcode = JALR_INS_OP)
                     else s_storeImm_calc     when (s_opcode = S_INS_OP)
                     else s_branchImm_calc    when (s_opcode = B_INS_OP)
                     else s_unsignedImm_calc  when (s_opcode = LUI_INS_OP or
                                                    s_opcode = AUIPC_INS_OP)
                     else s_jumpImm_calc      when (s_opcode = JAL_INS_OP)
                     else (others => '0');

    -- die Einzelausgänge kannst du so belassen:
    po_immediateImm <= s_immediateImm_calc;
    po_storeImm     <= s_storeImm_calc;
    po_branchImm    <= s_branchImm_calc;
    po_jumpImm      <= s_jumpImm_calc;
    po_unsignedImm  <= s_unsignedImm_calc;
end architecture arc;

--Wieso immedate-werte? Um direkt in der Instruktion erhalten um nicht extra in register zu speichern
--Arithmetische Operationen auf den Werten
--Sprung- und Verzweigung
--Speicheroperationen um die adresse für den Speicherzugiff zu brechnen 

--Wieso ist die erweiterung der Breite notwendig?
--stellt sicher das auch kleinere werte in 32-bit register gespeichert werden können
--bei negativen adresse stellt sicher das diese in einem größeren Adressraum Interpretiert werden

