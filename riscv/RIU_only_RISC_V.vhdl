-- Laboratory RA solutions/versuch5
-- Sommersemester 25
-- Group Details
-- Lab Date:
-- 1. Participant First and Last Name: 
-- 2. Participant First and Last Name:

-- ========================================================================
-- Author:       Marcel Rieß
-- Last updated: 22.05.2024
-- Description:  RUI-Only-RISC-V for an incomplete RV32I implementation, 
--               support only R/I/U-Instructions. 
-- ========================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constant_package.all;
use work.types.all;

entity riu_only_RISC_V is
  port (
    pi_rst : in std_logic;
    pi_clk : in std_logic;
    pi_instruction : in memory := (others => (others => '0'));
    po_registersOut : out registerMemory := (others => (others => '0'))
  );
end entity riu_only_RISC_V;

architecture structure of riu_only_RISC_V is

  constant PERIOD : time := 10 ns;
  constant ADD_FOUR_TO_ADDRESS : std_logic_vector(WORD_WIDTH - 1 downto 0) := std_logic_vector(to_signed((4), WORD_WIDTH));

  -- signals
  -- begin solution:
  -- =============== PC ===============
  signal s_pc_currentAddr, s_pc_newAddr : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0'); -- Current and new adress instruction in pc
  signal s_currentInst, s_newInst : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0'); -- Current and new instruction in IF phase
  signal s_id_pc, s_ex_pc : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0'); -- PC+4 for ID and EX phase
  -- ============ Pipeline ============
  signal s_id_controlword, s_ex_controlword, s_mem_controlword, s_wb_controlword : controlword := control_word_init;
  signal s_ex_dAddr, s_mem_dAddr, s_wb_dAddr : std_logic_vector(REG_ADR_WIDTH - 1 downto 0) := (others => '0');
  -- ============ Immediate ===========
  signal s_id_immediate, s_ex_immediate, s_ex_aluOP2_sel : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
  signal s_mem_immediate, s_wb_immediateS : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
  -- ============ Execute =============
  signal s_of_aluOP1, s_of_aluOP2, s_ex_aluOP1, s_ex_aluOP2 : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
  signal s_ex_aluOut, s_mem_aluOut, s_wb_aluOut : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
  -- ============ Write Back ==========
  signal s_wb_writeData : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
  -- ============ MUXES ============
  signal s_ex_aluOP1_sel : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0'); -- ALU OP1 MUX
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
  PC4_IF_ID : entity work.PipelineRegister(behavior)
    generic map(
      registerWidth => WORD_WIDTH
    )
    port map(
      pi_clk => pi_clk,
      pi_rst => pi_rst,
      pi_data => s_pc_currentAddr, -- PC+4 for IF phase
      po_data => s_id_pc
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
  ---* Immediate sign extension
  ---********************************************************************

  -- begin solution:
  SIGN_EXTENDER : entity work.signExtension(arc)
    generic map(
      word_width => WORD_WIDTH
    )
    port map( 
      pi_instr => s_currentInst,
      po_jumpImm => open,
      po_branchImm => open,
      po_unsignedImm => open,
      po_immediateImm => open, -- For address calculation
      po_storeImm => open,
      po_selectedImm => s_id_immediate -- For ALU operations
    );
  -- end solution!!

  ---********************************************************************
  ---* Pipeline-Register (ID -> EX) 
  ---********************************************************************

  -- begin solution: 

  -- Controlword pipelining
  ID_EX_CONTROLWORD : entity work.ControlWordRegister(arc1)
    port map(
      pi_rst => pi_rst,
      pi_clk => pi_clk,
      pi_controlWord => s_id_controlword,
      po_controlWord => s_ex_controlword
    );

  -- D address pipelining
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

  -- Immediate pipelining
  ID_EX_IMMEDIATE : entity work.PipelineRegister(behavior)
    generic map(
      registerWidth => WORD_WIDTH
    )
    port map(
      pi_clk => pi_clk,
      pi_rst => pi_rst,
      pi_data => s_id_immediate,
      po_data => s_ex_immediate
    );

  PC4_ID_EX : entity work.PipelineRegister(behavior)
    generic map(
      registerWidth => WORD_WIDTH
    )
    port map(
        pi_clk => pi_clk,
        pi_rst => pi_rst,
        pi_data => s_id_pc, -- PC+4 for ID phase
        po_data => s_ex_pc
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
    OP1_SEL : entity work.gen_mux(behavior)
    generic map(
      dataWidth => WORD_WIDTH
    )
    port map(
        pi_in0 => s_ex_aluOP1, -- Register value
        pi_in1 => s_ex_pc, -- PC+4 value
        pi_in2 => (others => '0'), 
        pi_in3 => (others => '0'), 
        pi_sel => "0" & s_ex_controlword.A_SEL, -- Select between register or immediate
        pOut => s_ex_aluOP1_sel
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

  -- Register / Immediate multiplexer  
  OP2_SEL : entity work.gen_mux(behavior)
    generic map(
      dataWidth => WORD_WIDTH
    )
    port map(
        pi_in0 => s_ex_aluOP2, -- Register value
        pi_in1 => s_ex_immediate, -- Immediate value
        pi_in2 => (others => '0'), -- Placeholder for future use
        pi_in3 => (others => '0'), -- Placeholder for future use
        pi_sel => "0" & s_ex_controlword.I_IMM_SEL, -- Select between register or immediate
        pOut => s_ex_aluOP2_sel
    );

  ALU : entity work.my_alu(behavior)
    generic map(
      G_DATA_WIDTH => WORD_WIDTH,
      G_OP_WIDTH => ALU_OPCODE_WIDTH
    )
    port map(
      pi_OP1 => s_ex_aluOP1_sel,
      pi_OP2 => s_ex_aluOP2_sel,
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
    EX_MEM_IMMEDIATE : entity work.PipelineRegister(behavior)
    generic map(
      registerWidth => WORD_WIDTH
    )
    port map(
      pi_clk => pi_clk,
      pi_rst => pi_rst,
      pi_data => s_ex_immediate,
      po_data => s_mem_immediate
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
  MEM_WB_CONTROLWORD : entity work.ControlWordRegister(arc1)
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
    MEM_WB_IMMEDIATE : entity work.PipelineRegister(behavior)
    generic map(
      registerWidth => WORD_WIDTH
    )
    port map(
      pi_clk => pi_clk,
      pi_rst => pi_rst,
      pi_data => s_mem_immediate,
      po_data => s_wb_immediateS
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
    WB_SEL_MUX : entity work.gen_mux(behavior)
    generic map(
      dataWidth => WORD_WIDTH
    )
    port map(
        pi_in0 => s_wb_aluOut,
        pi_in1 => s_wb_immediateS,
        pi_in2 => (others => '0'), -- Placeholder for future use
        pi_in3 => (others => '0'), -- Placeholder for future use
        pi_sel => s_wb_controlword.WB_SEL,
        pOut => s_wb_writeData
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
      pi_writeRegData => s_wb_writeData,
      pi_writeEnable => s_wb_controlword.REG_WRITE,
      po_readRegData1 => s_of_aluOP1,
      po_readRegData2 => s_of_aluOP2,
      po_registerOut => po_registersOut
    );
  -- end solution!!
  ---********************************************************************
end architecture;