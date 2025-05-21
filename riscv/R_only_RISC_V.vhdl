-- Laboratory RA solutions/versuch4
-- Sommersemester 25
-- Group Details
-- Lab Date: 20.05.2025
-- 1. Participant First and Last Name: Maximilan Wolf
-- 2. Participant First and Last Name: Esad-Muhammed Cekmeci

-- ========================================================================
-- Author:       Marcel Rieß
-- Last updated: 14.05.2025
-- Description:  RUI-Only-RISC-V for an incomplete RV32I implementation, 
--               support only R/I/U-Instructions. 
-- ========================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constant_package.all;
use work.types.all;

use work.my_gen_n_bit_full_adder;
use work.PipelineRegister;
use work.instruction_cache;
use work.ControlWordRegister;
use work.decoder;
use work.my_alu;

entity r_only_RISC_V is
  port (
    pi_rst : in std_logic := '0';
    pi_clk : in std_logic := '0';
    pi_instruction : in memory := (others => (others => '0'));
    po_registersOut : out registerMemory := (others => (others => '0'))
  );
end entity r_only_RISC_V;

architecture structure of r_only_RISC_V is

  constant PERIOD : time := 10 ns;
  constant ADD_FOUR_TO_ADDRESS : std_logic_vector(WORD_WIDTH - 1 downto 0) := std_logic_vector(to_signed((4), WORD_WIDTH));

  -- signals
  -- begin solution:
  -- =============== PC ===============
  signal s_pc_currentAddr, s_pc_newAddr : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0'); -- Current and new adress instruction in pc
  signal s_currentInst, s_newInst : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0'); -- Current and new instruction in IF phase
  -- ============ Pipeline ============
  signal s_id_controlword, s_ex_controlword, s_mem_controlword, s_wb_controlword : controlword := control_word_init;
  signal s_ex_dAddr, s_mem_dAddr, s_wb_dAddr : std_logic_vector(REG_ADR_WIDTH - 1 downto 0) := (others => '0');
  -- ============ Execute =============
  signal s_of_aluOP1, s_of_aluOP2, s_ex_aluOP1, s_ex_aluOP2 : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
  signal s_ex_aluOut, s_mem_aluOut, s_wb_aluOut : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
  -- end solution!!
begin

  ---********************************************************************
  ---* program counter adder and pc-register
  ---********************************************************************

  -- begin solution:  
  PC_ADDER : entity work.my_gen_n_bit_full_adder(structure)
    generic map(
      G_DATA_WIDTH => WORD_WIDTH
    )
    port map(
      pi_a => ADD_FOUR_TO_ADDRESS,
      pi_b => s_pc_currentAddr,
      pi_carryIn => '0',
      po_sum => s_pc_newAddr,
      po_carryOut => open
    );

  PC : entity work.PipelineRegister(behavior)
    generic map(
      registerWidth => WORD_WIDTH
    )
    port map(
      pi_clk => pi_clk,
      pi_rst => pi_rst,
      pi_data => s_pc_newAddr,
      po_data => s_pc_currentAddr
    );
  -- end solution!!

  ---********************************************************************
  ---* instruction fetch 
  ---********************************************************************

  -- begin solution:  
  INSTRUCTION_CACHE : entity work.instruction_cache(behavior)
    generic map(
      adr_width => ADR_WIDTH,
      mem_size => 2 ** 10
    )
    port map(
      pi_adr => s_pc_currentAddr,
      pi_clk => not pi_clk,
      pi_rst => pi_rst,
      pi_instructionCache => pi_instruction,
      po_instruction => s_newInst
    );
  -- end solution!!

  ---********************************************************************
  ---* Pipeline-Register (IF -> ID) start
  ---********************************************************************

  -- begin solution:
  IR : entity work.PipelineRegister(behavior)
    generic map(
      registerWidth => WORD_WIDTH
    )
    port map(
      pi_clk => pi_clk,
      pi_rst => pi_rst,
      pi_data => s_newInst,
      po_data => s_currentInst
    );
  -- end solution!!

  ---********************************************************************
  ---* decode phase
  ---********************************************************************

  -- begin solution:
  INSTRUCTION_DECODER : entity work.decoder(arc)
    generic map(
      word_width => WORD_WIDTH
    )
    port map(
      pi_instruction => s_currentInst,
      po_controlWord => s_id_controlword
    );
  -- end solution!!

  ---********************************************************************
  ---* Pipeline-Register (ID -> EX) 
  ---********************************************************************

  -- begin solution: 
  ID_EX_CONTROLWORD : entity work.ControlWordRegister(arc1)
    port map(
      pi_rst => pi_rst,
      pi_clk => pi_clk,
      pi_controlWord => s_id_controlword,
      po_controlWord => s_ex_controlword
    );
  ID_EX_PIPELINE : entity work.PipelineRegister(behavior)
    generic map(
      registerWidth => REG_ADR_WIDTH
    )
    port map(
      pi_clk => pi_clk,
      pi_rst => pi_rst,
      pi_data => s_currentInst(11 downto 7), -- Extract dst address from instruction
      po_data => s_ex_dAddr
    );

  -- end solution!!

  ---********************************************************************
  ---* execute phase
  ---********************************************************************

  -- begin solution:
  OP1_REGISTER : entity work.PipelineRegister(behavior)
    generic map(
      registerWidth => WORD_WIDTH
    )
    port map(
      pi_clk => pi_clk,
      pi_rst => pi_rst,
      pi_data => s_of_aluOP1,
      po_data => s_ex_aluOP1
    );

  OP2_REGISTER : entity work.PipelineRegister(behavior)
    generic map(
      registerWidth => WORD_WIDTH
    )
    port map(
      pi_clk => pi_clk,
      pi_rst => pi_rst,
      pi_data => s_of_aluOP2,
      po_data => s_ex_aluOP2
    );

  ALU : entity work.my_alu(behavior)
    generic map(
      G_DATA_WIDTH => WORD_WIDTH,
      G_OP_WIDTH => ALU_OPCODE_WIDTH
    )
    port map(
      pi_OP1 => s_ex_aluOP1,
      pi_OP2 => s_ex_aluOP2,
      pi_aluOP => s_ex_controlword.ALU_OP,
      po_aluOut => s_ex_aluOut,
      po_carryOut => open
    );
  -- end solution!!

  ---********************************************************************
  ---* Pipeline-Register (EX -> MEM) 
  ---********************************************************************

  -- begin solution:
  EX_MEM_CONTROLWORD : entity work.ControlWordRegister(arc1)
    port map(
      pi_rst => pi_rst,
      pi_clk => pi_clk,
      pi_controlWord => s_ex_controlword,
      po_controlWord => s_mem_controlword
    );
  EX_MEM_PIPELINE : entity work.PipelineRegister(behavior)
    generic map(
      registerWidth => REG_ADR_WIDTH
    )
    port map(
      pi_clk => pi_clk,
      pi_rst => pi_rst,
      pi_data => s_ex_dAddr,
      po_data => s_mem_dAddr
    );

  -- end solution!!

  ---********************************************************************
  ---* memory phase
  ---********************************************************************
  -- begin solution:
  -- end solution!!

  ---********************************************************************
  ---* Pipeline-Register (MEM -> WB) 
  ---********************************************************************
  -- begin solution:
  MEM_WB_CONTROLWORD : entity work.ControlWordRegister
    port map(
      pi_rst => pi_rst,
      pi_clk => pi_clk,
      pi_controlWord => s_mem_controlword,
      po_controlWord => s_wb_controlword
    );
  MEM_WB_PIPELINE : entity work.PipelineRegister(behavior)
    generic map(
      registerWidth => REG_ADR_WIDTH
    )
    port map(
      pi_clk => pi_clk,
      pi_rst => pi_rst,
      pi_data => s_mem_dAddr,
      po_data => s_wb_dAddr
    );

  -- end solution!!

  ---********************************************************************
  ---* write back phase
  ---********************************************************************
  -- begin solution:

  EX_MEM_ALU_PIPELINE : entity work.PipelineRegister(behavior)
    generic map(
      registerWidth => WORD_WIDTH
    )
    port map(
      pi_clk => pi_clk,
      pi_rst => pi_rst,
      pi_data => s_ex_aluOut,
      po_data => s_mem_aluOut
    );

  MEM_WB_ALU_PIPELINE : entity work.PipelineRegister(behavior)
    generic map(
      registerWidth => WORD_WIDTH
    )
    port map(
      pi_clk => pi_clk,
      pi_rst => pi_rst,
      pi_data => s_mem_aluOut,
      po_data => s_wb_aluOut
    );

  -- end solution!!

  ---********************************************************************
  ---* register file (negative clock)
  ---********************************************************************
  -- begin solution:

  REGISTER_FILE : entity work.register_file(behavior)
    generic map(
      word_width => WORD_WIDTH,
      adr_width => REG_ADR_WIDTH
    )
    port map(
      pi_clk => not pi_clk,
      pi_rst => pi_rst,
      pi_readRegAddr1 => s_currentInst(19 downto 15),
      pi_readRegAddr2 => s_currentInst(24 downto 20),
      pi_writeRegAddr => s_wb_dAddr,
      pi_writeRegData => s_wb_aluOut,
      pi_writeEnable => s_wb_controlword.REG_WRITE,
      po_readRegData1 => s_of_aluOP1,
      po_readRegData2 => s_of_aluOP2,
      po_registerOut => po_registersOut
    );
  -- end solution!!
  ---********************************************************************
  ---********************************************************************    

end architecture;