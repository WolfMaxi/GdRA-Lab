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
        word_width : integer := WORD_WIDTH
    );
    port (
        pi_clk : in std_logic := '0';
        pi_instruction : in std_logic_vector(word_width - 1 downto 0) := (others => '0');
        po_controlWord : out controlword := control_word_init
    );
    -- end solution!!
end entity decoder;
architecture arc of decoder is
begin
    -- begin solution:
    process (pi_clk)
        variable v_insFormat : t_instruction_type;

        variable v_opcode : std_logic_vector(6 downto 0) := (others => '0');
        variable v_func7 : std_logic_vector(6 downto 0) := (others => '0');
        variable v_func3 : std_logic_vector(2 downto 0) := (others => '0');
    begin
        if rising_edge(pi_clk) then
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
                when others =>
                    po_controlWord <= control_word_init;
            end case;
        end if;
    end process;
    -- end solution!!
end architecture;