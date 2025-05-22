-- Laboratory RA solutions/versuch3
-- Sommersemester 25
-- Group Details
-- Lab Date: 13.05.2025
-- 1. Participant First and Last Name: Maximilan Wolf
-- 2. Participant First and Last Name: Esad-Muhammed Cekmeci

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Constant_package.all;
use work.types.all;

/*
    Funktionsweise des R-Typs in RISC-V

    Der R-Typ ist ein Instruction Format in RISC-V,
    mit dem Register-Register-Operationen durchgeführt
    werden können, d.h. die die Instruktion enthält drei
    Adressen und einen Befehl, zwei Source Adressen und
    eine Destination Adresse. Die RISC-V führt den Befehl
    mit den zwei Operanden in den Source Adressen aus und
    speichert das Ergebnis in dem Register, dessen Adresse
    durch die Register Destination festgelegt wurde.
*/

entity decoder is
    -- begin solution:
    generic (
        word_width : integer := WORD_WIDTH
    );
    port (
        pi_instruction : in std_logic_vector(word_width - 1 downto 0) := (others => '0');
        po_controlWord : out controlword := control_word_init
    );
    -- end solution!!
end entity decoder;
architecture arc of decoder is
begin
    -- begin solution:
    process (pi_instruction)
        variable v_insFormat : t_instruction_type := nullFormat;

        variable v_opcode : std_logic_vector(6 downto 0) := (others => '0');
        variable v_func7 : std_logic_vector(6 downto 0) := (others => '0');
        variable v_func3 : std_logic_vector(2 downto 0) := (others => '0');
    begin
        v_opcode := pi_instruction(6 downto 0);
        case v_opcode is
            when R_INS_OP => v_insFormat := rFormat;
            when JALR_INS_OP | L_INS_OP | I_INS_OP => v_insFormat := iFormat;
            when S_INS_OP => v_insFormat := sFormat;
            when B_INS_OP => v_insFormat := bFormat;
            when LUI_INS_OP | AUIPC_INS_OP => v_insFormat := uFormat;
            when JAL_INS_OP => v_insFormat := jFormat;
            when others => v_insFormat := nullFormat;
        end case;
        case v_insFormat is
            when rFormat =>
                v_func7 := pi_instruction(31 downto 25);
                v_func3 := pi_instruction(14 downto 12);
                po_controlWord.ALU_OP <= v_func7(5) & v_func3;
                po_controlWord.I_IMM_SEL <= '0';
                po_controlWord.REG_WRITE <= '1';
            when iFormat =>
                v_func7 := pi_instruction(31 downto 25);
                v_func3 := pi_instruction(14 downto 12);
                po_controlWord.ALU_OP <= v_func7(5) & v_func3;
                po_controlWord.I_IMM_SEL <= '1';
                po_controlWord.REG_WRITE <= '1';
            when others =>
                po_controlWord <= control_word_init;
        end case;
    end process;
    -- end solution!!
end architecture;