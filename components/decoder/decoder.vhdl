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
        po_controlWord : out controlword := control_word_init;
        po_rs1Addr : out std_logic_vector(REG_ADR_WIDTH-1 downto 0);
        po_rs2Addr : out std_logic_vector(REG_ADR_WIDTH-1 downto 0);
        po_rdAddr  : out std_logic_vector(REG_ADR_WIDTH-1 downto 0)
    );
    -- end solution!!
end entity decoder;

architecture arc of decoder is
begin
    process (pi_instruction)
        variable v_insFormat : t_instruction_type := nullFormat;

        variable v_opcode : std_logic_vector(6 downto 0) := (others => '0');
        variable v_func7 : std_logic_vector(6 downto 0) := (others => '0');
        variable v_func3 : std_logic_vector(2 downto 0) := (others => '0');
    begin
        -- Standard-Zuweisungen zu Beginn des Prozesses
        po_controlWord <= control_word_init;
        -- Adress-Outputs müssen auch standardmäßig initialisiert werden, falls sie nicht gesetzt werden
        po_rs1Addr <= (others => '0');
        po_rs2Addr <= (others => '0');
        po_rdAddr  <= (others => '0');

        v_opcode := pi_instruction(6 downto 0);

        -- Erste Case: Instruktionsformat basierend auf Opcode
        case v_opcode is
            when R_INS_OP => v_insFormat := rFormat;
            when JALR_INS_OP | L_INS_OP | I_INS_OP => v_insFormat := iFormat;
            when S_INS_OP => v_insFormat := sFormat;
            when B_INS_OP => v_insFormat := bFormat;
            when LUI_INS_OP | AUIPC_INS_OP => v_insFormat := uFormat;
            when JAL_INS_OP => v_insFormat := jFormat;
            when others => v_insFormat := nullFormat;
        end case;

        -- Zweite Case: Detaillierte Dekodierung basierend auf Format
        case v_insFormat is
            when rFormat =>
                v_func7 := pi_instruction(31 downto 25);
                v_func3 := pi_instruction(14 downto 12);

                -- Setze Standard-Control-Signale für R-Typen
                po_controlWord.I_IMM_SEL <= '0'; -- R-Typen nutzen keine Immediates für ALU-Operanden
                po_controlWord.REG_WRITE <= '1'; -- R-Typen schreiben immer ins Register

                -- Adressen extrahieren (kombinatorisch vom Decoder)
                po_rs1Addr <= pi_instruction(19 downto 15);
                po_rs2Addr <= pi_instruction(24 downto 20);
                po_rdAddr  <= pi_instruction(11 downto 7);

                -- Wichtiger Teil: Spezifische ALU_OP für R-Typ-Befehle
                case v_func3 is
                    when F3_ADD_SUB_ARITH => -- func3 "000"
                        if v_func7 = F7_ARITH_BASE then -- func7 "0000000" für ADD
                            po_controlWord.ALU_OP <= ADD_ALU_OP;
                        elsif v_func7 = F7_ARITH_ALT then -- func7 "0100000" für SUB
                            po_controlWord.ALU_OP <= SUB_ALU_OP;
                        else
                            po_controlWord.ALU_OP <= (others => 'X'); -- Undefiniert
                            report "DECODER: Unbekannter R-Typ Befehl (func3=" & to_hstring(unsigned(v_func3)) & ", func7=" & to_hstring(unsigned(v_func7)) & ")" severity error;
                        end if;
                    when F3_SLL_LOGIC => -- func3 "001" für SLL
                        po_controlWord.ALU_OP <= SLL_ALU_OP;
                    when F3_SLT_COMPARE => -- func3 "010" für SLT
                        po_controlWord.ALU_OP <= SLT_ALU_OP;
                    when F3_SLTU_COMPARE => -- func3 "011" für SLTU
                        po_controlWord.ALU_OP <= SLTU_ALU_OP;
                    when F3_XOR_LOGIC => -- func3 "100" für XOR
                        po_controlWord.ALU_OP <= XOR_ALU_OP;
                    when F3_SHIFT_LOGIC => -- func3 "101" für SRL/SRA
                        if v_func7 = F7_ARITH_BASE then -- func7 "0000000" für SRL
                            po_controlWord.ALU_OP <= SRL_ALU_OP;
                        elsif v_func7 = F7_ARITH_ALT then -- func7 "0100000" für SRA
                            po_controlWord.ALU_OP <= SRA_ALU_OP;
                        else
                            po_controlWord.ALU_OP <= (others => 'X'); -- Undefiniert
                            report "DECODER: Unbekannter R-Typ Shift Befehl (func3=" & to_hstring(unsigned(v_func3)) & ", func7=" & to_hstring(unsigned(v_func7)) & ")" severity error;
                        end if;
                    when F3_OR_LOGIC => -- func3 "110" für OR
                        po_controlWord.ALU_OP <= OR_ALU_OP;
                    when F3_AND_LOGIC => -- func3 "111" für AND
                        po_controlWord.ALU_OP <= AND_ALU_OP;
                    when others =>
                        po_controlWord.ALU_OP <= (others => 'X'); -- Undefiniert
                        report "DECODER: Unbekannter R-Typ func3-Wert: " & to_hstring(unsigned(v_func3)) severity error;
                end case;

                report "DECODER (R-Type): Instruction=" & to_hstring(unsigned(pi_instruction)) &
                       " Opcode=" & to_hstring(unsigned(v_opcode)) &
                       " Func3=" & to_hstring(unsigned(v_func3)) &
                       " Func7=" & to_hstring(unsigned(v_func7)) &
                       " ALU_OP=" & to_hstring(unsigned(po_controlWord.ALU_OP)) &
                       " rs1=" & integer'image(to_integer(unsigned(po_rs1Addr))) &
                       " rs2=" & integer'image(to_integer(unsigned(po_rs2Addr))) &
                       " rd="  & integer'image(to_integer(unsigned(po_rdAddr)))
                severity note;

            -- Hier würden die Logik und Zuweisungen für andere Formate (I, S, B, U, J) folgen
            -- Beispiel für I-Type ALU-Ops (z.B. ADDI - Opcode I_INS_OP)
            when iFormat =>
                v_func3 := pi_instruction(14 downto 12);
                -- po_rs1Addr <= pi_instruction(19 downto 15);
                -- po_rdAddr <= pi_instruction(11 downto 7);
                po_controlWord.I_IMM_SEL <= '1'; -- Für I-Type ALU Ops wird ein Immediate verwendet
                po_controlWord.REG_WRITE <= '1';

                case v_func3 is
                    when F3_ADD_SUB_ARITH => -- ADDI (func3 "000")
                        po_controlWord.ALU_OP <= ADD_ALU_OP;
                    -- Füge hier weitere I-Typ Befehle hinzu (SLLI, SLTI, XORI, SRLI, SRAI, ORI, ANDI)
                    when others =>
                        po_controlWord.ALU_OP <= (others => 'X'); -- Undefiniert
                        report "DECODER: Unbekannter I-Typ func3-Wert: " & to_hstring(unsigned(v_func3)) severity error;
                end case;
                report "DECODER: I-Type format detected, but not fully implemented." severity note;

            when others =>
                -- Für alle nicht gematchten Formate (z.B. nullFormat)
                po_controlWord <= control_word_init; -- Reset auf Standardwerte
                report "DECODER: Unknown instruction format or opcode. Instruction: " & to_hstring(unsigned(pi_instruction)) severity warning;
        end case;
    end process;
end architecture;