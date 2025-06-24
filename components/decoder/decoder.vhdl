-- Laboratory RA solutions/versuch3
-- Sommersemester 25
-- Group Details
-- Lab Date: 03.06.2025
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
        variable v_insFormat : t_instruction_type := nullFormat; --Instruction Format

        variable v_opcode : std_logic_vector(6 downto 0) := (others => '0'); -- Instruction Opcode
        variable v_func7 : std_logic_vector(6 downto 0) := (others => '0'); -- Funct7
        variable v_func3 : std_logic_vector(2 downto 0) := (others => '0'); -- Funct3
        variable v_aluOp : std_logic_vector(3 downto 0) := (others => '0'); -- ALU Opcode
    begin
        po_controlWord <= control_word_init; -- Reset control word
        v_opcode := pi_instruction(6 downto 0);
        case v_opcode is -- Determine Instruction format
            when R_INS_OP => v_insFormat := rFormat;
            when JALR_INS_OP | L_INS_OP | I_INS_OP => v_insFormat := iFormat;
            when S_INS_OP => v_insFormat := sFormat;
            when B_INS_OP => v_insFormat := bFormat;
            when LUI_INS_OP | AUIPC_INS_OP => v_insFormat := uFormat;
            when JAL_INS_OP => v_insFormat := uFormat;
            when others => v_insFormat := nullFormat;
        end case;
        case v_insFormat is
            when rFormat => -- R-Format (Register)
                v_func7 := pi_instruction(31 downto 25);
                v_func3 := pi_instruction(14 downto 12);
                v_aluOp := v_func7(5) & v_func3;

                po_controlWord.ALU_OP <= v_aluOp;
                po_controlWord.I_IMM_SEL <= '0';
                po_controlWord.REG_WRITE <= '1';
                po_controlWord.WB_SEL <= "00";
            when iFormat => -- I-Format (Immediate)
                v_func7 := pi_instruction(31 downto 25);
                v_func3 := pi_instruction(14 downto 12);

                if v_opcode = L_INS_OP then -- LOAD-Instruktionen
                    po_controlWord.ALU_OP <= (others => '0');
                    po_controlWord.I_IMM_SEL <= '1';
                    po_controlWord.WB_SEL <= "11";
                    po_controlWord.REG_WRITE <= '1';
                    po_controlWord.A_SEL <= '0';
                    po_controlWord.PC_SEL <= '0';
                    po_controlWord.IS_BRANCH <= '0';
                    po_controlWord.CMP_RESULT <= '0';
                    po_controlWord.MEM_READ <= '1';
                    po_controlWord.MEM_WRITE <= '0';

                    case v_func3 is
                        when LB_OP => po_controlWord.MEM_CTR <= "000";
                        when LH_OP => po_controlWord.MEM_CTR <= "001";
                        when LW_OP => po_controlWord.MEM_CTR <= "010";
                        when LBU_OP => po_controlWord.MEM_CTR <= "100";
                        when LHU_OP => po_controlWord.MEM_CTR <= "101";
                        when others => po_controlWord.MEM_CTR <= "000"; -- default
                    end case;

                elsif v_opcode = JALR_INS_OP then -- JALR Instruktion
                    po_controlWord.ALU_OP <= ADD_ALU_OP;
                    po_controlWord.I_IMM_SEL <= '1';
                    po_controlWord.A_SEL <= '0';
                    po_controlWord.PC_SEL <= '1';
                    po_controlWord.REG_WRITE <= '1';
                    po_controlWord.WB_SEL <= "10";

                else -- Arithmetische I-Typ Instruktionen wie ADDI, SLTI, ORI, etc.
                    case v_func3 is
                        when "000" => v_aluOp := ADD_ALU_OP; -- ADDI
                        when "010" => v_aluOp := SLT_ALU_OP; -- SLTI
                        when "100" => v_aluOp := XOR_ALU_OP; -- XORI
                        when "110" => v_aluOp := OR_ALU_OP; -- ORI
                        when "111" => v_aluOp := AND_ALU_OP; -- ANDI
                        when "001" => v_aluOp := SLL_ALU_OP; -- SLLI
                        when "101" =>
                            if v_func7(5) = '1' then
                                v_aluOp := SRA_ALU_OP; -- SRAI
                            else
                                v_aluOp := SRL_ALU_OP; -- SRLI
                            end if;
                        when others => v_aluOp := (others => '0');
                    end case;

                    po_controlWord.ALU_OP <= v_aluOp;
                    po_controlWord.I_IMM_SEL <= '1';
                    po_controlWord.A_SEL <= '0';
                    po_controlWord.PC_SEL <= '0';
                    po_controlWord.REG_WRITE <= '1';
                    po_controlWord.WB_SEL <= "00"; -- ALU-Ergebnis
                end if;

            when uFormat => -- U-Format (Upper Immediate)
                if v_opcode = LUI_INS_OP then
                    po_controlWord.ALU_OP <= ADD_ALU_OP;
                    po_controlWord.I_IMM_SEL <= '1';
                    po_controlWord.A_SEL <= '0'; -- A-Selection for ALU
                    po_controlWord.REG_WRITE <= '1';
                    po_controlWord.WB_SEL <= "01"; -- Register WB sel (Immediate)
                elsif v_opcode = AUIPC_INS_OP then
                    po_controlWord.ALU_OP <= ADD_ALU_OP;
                    po_controlWord.A_SEL <= '1'; -- A-Selection for ALU
                    po_controlWord.I_IMM_SEL <= '1';
                    po_controlWord.REG_WRITE <= '1';
                    po_controlWord.WB_SEL <= "00"; -- Register WB sel (ALU)
                elsif v_opcode = JAL_INS_OP then
                    po_controlWord.ALU_OP <= ADD_ALU_OP;
                    po_controlWord.I_IMM_SEL <= '1';
                    po_controlWord.A_SEL <= '1'; -- A-Selection for ALU
                    po_controlWord.REG_WRITE <= '1';
                    po_controlWord.PC_SEL <= '1'; -- Program Counter Selection
                    po_controlWord.WB_SEL <= "10"; -- JAL Write Back Selection
                else
                    po_controlWord <= control_word_init; -- Reset control word for unknown uFormat
                end if;
            when bFormat => -- B-Format (Conditional branch)
                po_controlWord.IS_BRANCH <= '1';
                v_func3 := pi_instruction(14 downto 12);
                case v_func3 is
                    when FUNC3_BEQ =>
                        po_controlWord.CMP_RESULT <= '0';
                        po_controlWord.ALU_OP <= SUB_ALU_OP;
                    when FUNC3_BNE =>
                        po_controlWord.CMP_RESULT <= '1';
                        po_controlWord.ALU_OP <= SUB_ALU_OP;
                    when FUNC3_BLT =>
                        po_controlWord.CMP_RESULT <= '1';
                        po_controlWord.ALU_OP <= SLT_ALU_OP;
                    when FUNC3_BGE =>
                        po_controlWord.CMP_RESULT <= '0';
                        po_controlWord.ALU_OP <= SLT_ALU_OP;
                    when FUNC3_BLTU =>
                        po_controlWord.CMP_RESULT <= '1';
                        po_controlWord.ALU_OP <= SLTU_ALU_OP;
                    when FUNC3_BGEU =>
                        po_controlWord.CMP_RESULT <= '0';
                        po_controlWord.ALU_OP <= SLTU_ALU_OP;
                    when others => null;
                end case;
            when sFormat =>
                v_func3 := pi_instruction(14 downto 12);
                case v_func3 is
                    when SB_OP =>
                        po_controlWord.ALU_OP <= (others => '0');
                        po_controlWord.I_IMM_SEL <= '1';
                        po_controlWord.MEM_WRITE <= '1';
                    when SH_OP =>
                        po_controlWord.ALU_OP <= (others => '0');
                        po_controlWord.I_IMM_SEL <= '1';
                        po_controlWord.MEM_CTR <= "001";
                        po_controlWord.MEM_WRITE <= '1';
                    when SW_OP =>
                        po_controlWord.ALU_OP <= (others => '0');
                        po_controlWord.I_IMM_SEL <= '1';
                        po_controlWord.MEM_CTR <= "010";
                        po_controlWord.MEM_WRITE <= '1';
                    when others =>
                        po_controlWord <= CONTROL_WORD_INIT;
                end case;
            when others =>
                po_controlWord <= control_word_init;
        end case;
    end process;
    -- end solution!!
end architecture;