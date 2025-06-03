-- Laboratory RA solutions/versuch71
-- Sommersemester 25
-- Group Details
-- Lab Date:
-- 1. Participant First and Last Name: 
-- 2. Participant First and Last Name:

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constant_package.all;
USE work.util_asm_package.ALL;
use work.types.all;


entity decoder_tb is
end entity decoder_tb;

architecture behavior of decoder_tb is

  constant PERIOD : time := 10 ns; -- Example: ClockPERIOD of 10 ns
  signal s_instruction : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
  signal s_controlword : controlWord := CONTROL_WORD_INIT;
  signal s_clk : std_logic := '0';

begin

  lu8 : entity work.decoder
    port map(
      pi_instruction => s_instruction,
      po_controlWord => s_controlword
    );

  lu : process is

    -- For each architecture, check if the instruction format it adds to the decoder is decoded correctly

    variable v_aluoperation : std_logic_vector(ALU_OPCODE_WIDTH - 1 downto 0) := ADD_ALU_OP;
    variable v_rs1 : integer := 5;
    variable v_rs2 : integer := 4;
    variable v_rd  : integer := 6;
    variable v_shamt: integer :=12;
    variable v_expectedcontrolword : controlWord := CONTROL_WORD_INIT;
    variable func7 : std_logic_vector(6 downto 0)              := "0" & ADD_ALU_OP (ALU_OPCODE_WIDTH - 1) & "00000";
    variable func3 : std_logic_vector(2 downto 0)              := ADD_ALU_OP(ALU_OPCODE_WIDTH - 2 downto 0);

  begin

    -- R-Format Decoding
    v_expectedControlWord := CONTROL_WORD_INIT;
    v_expectedControlWord.I_IMM_SEL := '0';
    v_expectedControlWord.ALU_OP := ADD_ALU_OP;
    v_expectedControlWord.REG_WRITE := '1';
    s_instruction <= Asm2Std("ADD",1,2,3);wait for PERIOD / 2;
    assert (s_controlword = v_expectedcontrolword) report "Error in R-Format decoding"  severity error;
    
  
    v_expectedControlWord.ALU_OP := SUB_ALU_OP;
    s_instruction <=Asm2Std("SUB",1,2,3);wait for PERIOD / 2;
    assert (s_controlword = v_expectedcontrolword)
    report "Error in R-Format decoding"  severity error;


    v_expectedControlWord.ALU_OP := SRA_ALU_OP;
    s_instruction <=Asm2Std("SRA",1,2,3);wait for PERIOD / 2;
    assert (s_controlword = v_expectedcontrolword) report "Error in R-Format decoding"  severity error;


    v_expectedControlWord.ALU_OP := SRL_ALU_OP;
    s_instruction <= Asm2Std("SRL",1,2,3);wait for PERIOD / 2;
    assert (s_controlword = v_expectedcontrolword) report "Error in R-Format decoding"  severity error;


  
    s_instruction <=Asm2Std("SLL",1,2,3);wait for PERIOD / 2;
    v_expectedControlWord := CONTROL_WORD_INIT;
    v_expectedControlWord.I_IMM_SEL := '0';
    v_expectedControlWord.ALU_OP := SLL_ALU_OP;
    v_expectedControlWord.REG_WRITE := '1';
    assert (s_controlword = v_expectedcontrolword)    report "Error in R-Format decoding"  severity error;

    s_instruction <=Asm2Std("OR",1,2,3);wait for PERIOD / 2;
     v_expectedControlWord := CONTROL_WORD_INIT;
     v_expectedControlWord.I_IMM_SEL := '0';
    v_expectedControlWord.ALU_OP := OR_ALU_OP;
    v_expectedControlWord.REG_WRITE := '1';
    assert (s_controlword = v_expectedcontrolword)    report "Error in R-Format decoding"  severity error;


      
    s_instruction <= Asm2Std("XOR",1,2,3);wait for PERIOD / 2;
     v_expectedControlWord := CONTROL_WORD_INIT;
     v_expectedControlWord.I_IMM_SEL := '0';
    v_expectedControlWord.ALU_OP := XOR_ALU_OP;
    v_expectedControlWord.REG_WRITE := '1';
    assert (s_controlword = v_expectedcontrolword)    report "Error in R-Format decoding"  severity error;


      
    s_instruction <=Asm2Std("AND",1,2,3);wait for PERIOD / 2;
     v_expectedControlWord := CONTROL_WORD_INIT;
     v_expectedControlWord.I_IMM_SEL := '0';
    v_expectedControlWord.ALU_OP := AND_ALU_OP;
    v_expectedControlWord.REG_WRITE := '1';
    assert (s_controlword = v_expectedcontrolword)    report "Error in R-Format decoding"  severity error;

    s_instruction <=Asm2Std("SLTU",1,2,3);wait for PERIOD / 2;
     v_expectedControlWord := CONTROL_WORD_INIT;
     v_expectedControlWord.I_IMM_SEL := '0';
    v_expectedControlWord.ALU_OP := SLTU_ALU_OP;
    v_expectedControlWord.REG_WRITE := '1';
    assert (s_controlword = v_expectedcontrolword)    report "Error in R-Format decoding"  severity error;

  
    s_instruction <= Asm2Std("SLT",1,2,3);wait for PERIOD / 2;
     v_expectedControlWord := CONTROL_WORD_INIT;
     v_expectedControlWord.I_IMM_SEL := '0';
    v_expectedControlWord.ALU_OP := SLT_ALU_OP;
    v_expectedControlWord.REG_WRITE := '1';
    assert (s_controlword = v_expectedcontrolword)    report "Error in R-Format decoding"  severity error;


--  I-Format Decoding
  
    s_instruction <=Asm2Std("ADDI",1,2,3);wait for PERIOD / 2;
     v_expectedControlWord := CONTROL_WORD_INIT;
     v_expectedControlWord.I_IMM_SEL := '1';
    v_expectedControlWord.ALU_OP := ADD_ALU_OP;
    v_expectedControlWord.REG_WRITE := '1';
    assert (s_controlword = v_expectedcontrolword) report "Error in I-Format decoding"  severity error;


    s_instruction <=Asm2Std("ORI",1,2,3);wait for PERIOD / 2;
     v_expectedControlWord := CONTROL_WORD_INIT;
     v_expectedControlWord.I_IMM_SEL := '1';
    v_expectedControlWord.ALU_OP := OR_ALU_OP;
    v_expectedControlWord.REG_WRITE := '1';
    assert (s_controlword = v_expectedcontrolword)    report "Error in I-Format decoding"  severity error;

    s_instruction <=Asm2Std("XORI",1,2,3);wait for PERIOD / 2;
    v_expectedControlWord := CONTROL_WORD_INIT;
     v_expectedControlWord.I_IMM_SEL := '1';
    v_expectedControlWord.ALU_OP := XOR_ALU_OP;
    v_expectedControlWord.REG_WRITE := '1';
    assert (s_controlword = v_expectedcontrolword)    report "Error in I-Format decoding"  severity error;

    s_instruction <=Asm2Std("ANDI",1,2,3);wait for PERIOD / 2;
    v_expectedControlWord := CONTROL_WORD_INIT;
     v_expectedControlWord.I_IMM_SEL := '1';
    v_expectedControlWord.ALU_OP := AND_ALU_OP;
    v_expectedControlWord.REG_WRITE := '1';
    assert (s_controlword = v_expectedcontrolword)    report "Error in I-Format decoding"  severity error;

    
    func3 := ADD_ALU_OP(ALU_OPCODE_WIDTH - 2 downto 0);
    s_instruction <=Asm2Std("JALR",1,2,3);-- std_logic_vector(to_signed(9, 12))  & std_logic_vector(to_unsigned(v_rs1, REG_ADR_WIDTH)) & func3 & std_logic_vector(to_unsigned(v_rd, REG_ADR_WIDTH)) & JALR_INS_OP;
    wait for PERIOD / 2;
    v_expectedControlWord := CONTROL_WORD_INIT;
    v_expectedControlWord.I_IMM_SEL := '1';
    v_expectedControlWord.WB_SEL:= "10";
    v_expectedControlWord.ALU_OP := ADD_ALU_OP;
    v_expectedControlWord.PC_SEL:= '1';
    v_expectedControlWord.REG_WRITE := '1';
    assert (s_controlword = v_expectedcontrolword) report "Error in JALR-Format decoding"  severity error;


    --  U-Format Decoding

    s_instruction <=Asm2Std("LUI",1,2,3);-- std_logic_vector(to_signed(9, 20)) & std_logic_vector(to_unsigned(v_rd, REG_ADR_WIDTH)) & LUI_INS_OP; 
    wait for PERIOD / 2;
     v_expectedControlWord := CONTROL_WORD_INIT;
     v_expectedControlWord.I_IMM_SEL := '1';
    v_expectedControlWord.WB_SEL:= "01";
    v_expectedControlWord.ALU_OP := ADD_ALU_OP;
    v_expectedControlWord.REG_WRITE := '1';
    assert (s_controlword = v_expectedcontrolword)    report "Error in LUI-Format decoding"  severity error;

    s_instruction <=Asm2Std("AUIPC",1,2,3);-- std_logic_vector(to_signed(9, 20)) & std_logic_vector(to_unsigned(v_rd, REG_ADR_WIDTH)) & AUIPC_INS_OP; 
    wait for PERIOD / 2;
    v_expectedControlWord := CONTROL_WORD_INIT;
     v_expectedControlWord.I_IMM_SEL := '1';
    v_expectedControlWord.A_SEL:= '1';
    v_expectedControlWord.ALU_OP := ADD_ALU_OP;
    v_expectedControlWord.REG_WRITE := '1';
    assert (s_controlword = v_expectedcontrolword)    report "Error in AUIPC-Format decoding"  severity error;
    
    
    
    s_instruction <=Asm2Std("JAL",1,2,3);-- std_logic_vector(to_signed(9, 20)) & std_logic_vector(to_unsigned(v_rd, REG_ADR_WIDTH)) & JAL_INS_OP; 
    wait for PERIOD / 2;
    v_expectedControlWord := CONTROL_WORD_INIT;
    v_expectedControlWord.I_IMM_SEL := '1';
    v_expectedControlWord.WB_SEL:= "10";
    v_expectedControlWord.ALU_OP := ADD_ALU_OP;
    v_expectedControlWord.PC_SEL:= '1';
    v_expectedControlWord.A_SEL:= '1';
    v_expectedControlWord.REG_WRITE := '1';
    assert (s_controlword = v_expectedcontrolword)    report "Error in JAL-Format decoding"  severity error;
    
    



    assert false   report "End of decoder test!!!"    severity note;

    wait; --  Wait forever; this will finish the simulation.

  end process lu;

end architecture behavior;
