-- Laboratory RA solutions/versuch5
-- Sommersemester 25
-- Group Details
-- Lab Date: 10.06.2025
-- 1. Participant First and Last Name: Esad-Muhammed Cekmeci
-- 2. Participant First and Last Name: Maximilian Wolf 

-- ========================================================================
-- Author:       Marcel Rieß
-- Last updated: 22.05.2024
-- Description:  RUI-Only-RISC-V for an incomplete RV32I implementation, 
--               support only R/I/U-Instructions. 
-- ========================================================================

-- Flushing Konzept
-- 
-- Das Flushing unserer RISCV Implementierung erfolgt dadurch, dass bei einem Jump oder Branch
-- Befehl s_ex_pc_sel auf 1 gesetzt wird, und dieses Signal durch einen process zu s_mem_pc_sel
-- gepipelined wird. Alle Pipeline Register bis EX (IF->ID, OF->EX & ID->EX) werden dann in der
-- MEM-Phase mithilfe des Reset Signals geflushed, da diese aufgrund der neuen Adresse noch alte
-- und ungültige Instruktionen enthalten.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constant_package.all;
use work.util_asm_package.all;
use work.types.all;

entity DE10_RISC_V is
  port (
    KEY : in std_logic_vector (1 downto 0);
    SW : in std_logic_vector (9 downto 0);
    LEDR : out std_logic_vector (7 downto 0);
    HEX0, HEX1 : out std_logic_vector (6 downto 0);
    HEX2, HEX3 : out std_logic_vector (6 downto 0);
    HEX4, HEX5 : out std_logic_vector (6 downto 0)
  );
end entity DE10_RISC_V;

architecture structure of DE10_RISC_V is
  constant CONST_FOUR : std_logic_vector(WORD_WIDTH - 1 downto 0) := std_logic_vector(to_signed((4), WORD_WIDTH));

  -- signals
  -- begin solution:

  -- Port signals
  signal s_rst : std_logic := '0';
  signal s_clk : std_logic := '0';
  signal s_instructions : memory := (others => (others => '0'));
  signal s_registersOut : registerMemory := (others => (others => '0'));
  signal s_datamemoryOut : memory := (others => (others => '0'));

  type segment_array is array(0 to 5) of std_logic_vector(6 downto 0);
  signal seg_patterns : segment_array := (others => (others => '0'));

  -- =============== PC ===============
  signal s_pc_currentAddr, s_pc_newAddr : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0'); -- Current and new adress instruction in pc
  signal s_currentInst, s_newInst : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0'); -- Current and new instruction in IF phase
  signal s_id_pc, s_ex_pc : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0'); -- PC+4 for ID and EX phase
  signal s_ex_pcPlus4, s_mem_pcPlus4, s_wb_pcPlus4, s_pc_newAddr_sel : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0'); -- PC+4 for ID, EX, MEM and WB phase
  -- ============ Pipeline ============
  signal s_id_controlword, s_ex_controlword, s_mem_controlword, s_wb_controlword : controlword := control_word_init;
  signal s_id_rs1Addr, s_id_rs2Addr : std_logic_vector(REG_ADR_WIDTH - 1 downto 0) := (others => '0');
  signal s_id_dAddr, s_ex_dAddr, s_mem_dAddr, s_wb_dAddr : std_logic_vector(REG_ADR_WIDTH - 1 downto 0) := (others => '0');
  -- ============ Immediate ===========
  signal s_id_immediate, s_ex_immediate, s_mem_immediate, s_wb_immediate : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
  -- ============ Execute =============
  signal s_of_rs1, s_of_rs2, s_ex_rs1, s_ex_rs2 : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
  signal s_ex_rs1_sel, s_ex_rs2_sel : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
  signal s_ex_aluOut, s_mem_aluOut, s_wb_aluOut : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
  -- ============ Branch =============
  signal s_ex_pc_sel, s_mem_pc_sel, s_ex_zero : std_logic := '0';
  signal s_pc_branch_sel : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
  signal s_ex_branchAddr, s_mem_branchAddr : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
  signal s_flush : std_logic := '0';
  -- ============ Memory =============
  signal s_mem_rs2, s_memory_out : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
  -- ============ Write Back ==========
  signal s_wb_writeData : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
  -- ============ Forwarding ==========
  signal s_id_bp_rs1_sel, s_id_bp_rs2_sel : std_logic_vector(1 downto 0) := (others => '0');
  signal s_of_bp_rs1, s_of_bp_rs2, s_mem_bp_rs1, s_mem_bp_rs2 : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
  -- ============ Stalling ==========
  signal s_stall : std_logic := '0';

  -- end solution!!
begin
  ---********************************************************************
  ---* Cyclone V Board implementation
  ---********************************************************************
  s_rst <= not KEY(0);
  s_clk <= KEY(1);
  LEDR(7 downto 0) <= s_registersOut (to_integer (unsigned (SW (4 downto 0)))) (7 downto 0);

  gen_decoder : for i in 0 to 5 generate
    decoder_inst : entity work.hex_7seg_decoder
      port map(
        bin_in => s_currentInst ((i * 4 + 3) downto i * 4),
        seg_out => seg_patterns (i)
      );
  end generate;

  HEX0 <= seg_patterns (0);
  HEX1 <= seg_patterns (1);
  HEX2 <= seg_patterns (2);
  HEX3 <= seg_patterns (3);
  HEX4 <= seg_patterns (4);
  HEX5 <= seg_patterns (5);

  --1 s_instructions (1) <= x "00900093"; -- ADDI x1 , x0 , 9
  --2 s_instructions (2) <= x "00800113"; -- ADDI x2 , x0 , 8
  --3 s_instructions (3) <= x " "; -- OR x10 , x1 , x2
  --4 s_instructions (4) <= x " "; -- ADD x8 , x1 , x2
  --5 s_instructions (5) <= x " "; -- SUB x11 , x1 , x2
  --6 s_instructions (6) <= x " "; -- SUB x12 , x2 , x1
  --7 s_instructions (7) <= x " "; -- ADD x12 , x2 , x8
  --8 s_instructions (8) <= x " "; -- SUB x12 , x2 , x1
  --9 s_instructions (9) <= x " "; -- AND x1 , x2 , x1
  --10 s_instructions (10) <= x " "; -- XOR x12 , x1 , x2
  --11 s_instructions (11) <= x " "; -- LUI x13 , 8
  --12 s_instructions (12) <= x " "; -- LUI x13 , 29
  --13 s_instructions (13) <= x " "; -- AUIPC x14 , 1
  --14 s_instructions (14) <= x " "; -- AUIPC x14 , 1

  s_instructions(1) <= Asm2Std("ADDI", 1, 0, 9);
  s_instructions(2) <= Asm2Std("ADDI", 2, 0, 8);
  s_instructions(3) <= Asm2Std("OR", 10, 1, 2);
  s_instructions(4) <= Asm2Std("ADD", 8, 1, 2);
  s_instructions(5) <= Asm2Std("SUB", 11, 1, 2);
  s_instructions(6) <= Asm2Std("SUB", 12, 2, 1);
  s_instructions(7) <= Asm2Std("ADD", 12, 2, 8);
  s_instructions(8) <= Asm2Std("SUB", 12, 2, 1);
  s_instructions(9) <= Asm2Std("AND", 1, 2, 1);
  s_instructions(10) <= Asm2Std("XOR", 12, 1, 2);
  s_instructions(11) <= Asm2Std("LUI", 13, 8, 0);
  s_instructions(12) <= Asm2Std("LUI", 13, 29, 0);
  s_instructions(13) <= Asm2Std("AUIPC", 14, 1, 0);
  s_instructions(14) <= Asm2Std("AUIPC", 14, 1, 0);

  ---********************************************************************
  ---* program counter adder and pc-register
  ---********************************************************************
  -- begin solution:

  -- Program Counter Adder
  PC_ADDER : entity work.my_gen_n_bit_full_adder(structure)
    generic map(
      G_DATA_WIDTH => WORD_WIDTH
    )
    port map(
      pi_a => CONST_FOUR,
      pi_b => s_pc_currentAddr,
      pi_carryIn => '0',
      po_sum => s_pc_newAddr,
      po_carryOut => open
    );

  -- PC multiplexer for (PC Adder / Branch) instructions
  PC_SEL : entity work.gen_mux2to1(behavior)
    generic map(
      dataWidth => WORD_WIDTH
    )
    port map(
      pi_first => s_pc_branch_sel,
      pi_second => s_mem_aluOut,
      pi_sel => s_mem_controlword.PC_SEL,
      pOut => s_pc_newAddr_sel
    );

  -- PC multiplexer for PC Adder / Branch instructions
  PC_BRANCH_SEL : entity work.gen_mux2to1(behavior)
    generic map(
      dataWidth => WORD_WIDTH
    )
    port map(
      pi_first => s_pc_newAddr,
      pi_second => s_mem_branchAddr,
      pi_sel => s_mem_pc_sel,
      pOut => s_pc_branch_sel
    );

  -- Program counter
  PC : entity work.PipelineRegister(behavior)
    generic map(
      registerWidth => WORD_WIDTH
    )
    port map(
      pi_clk => s_clk,
      pi_rst => s_rst,
      pi_enable => not s_stall,
      pi_data => s_pc_newAddr_sel,
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
      pi_clk => not s_clk,
      pi_rst => s_rst,
      pi_instructionCache => s_instructions,
      po_instruction => s_newInst
    );

  -- end solution!!
  ---********************************************************************
  ---* Pipeline-Register (IF -> ID) start
  ---********************************************************************
  -- begin solution:

  -- Instruction register
  IR : entity work.PipelineRegister(behavior)
    generic map(
      registerWidth => WORD_WIDTH
    )
    port map(
      pi_clk => s_clk,
      pi_rst => s_rst or s_flush,
      pi_enable => not s_stall,
      pi_data => s_newInst,
      po_data => s_currentInst
    );

  -- PC IF->ID pipeline
  PC_IF_ID : entity work.PipelineRegister(behavior)
    generic map(
      registerWidth => WORD_WIDTH
    )
    port map(
      pi_clk => s_clk,
      pi_rst => s_rst or s_flush,
      pi_data => s_pc_currentAddr,
      po_data => s_id_pc
    );

  -- end solution!!
  ---********************************************************************
  ---* decode phase
  ---********************************************************************
  -- begin solution:

  -- Extract src / dst adresses from Instruction
  s_id_dAddr <= s_currentInst(11 downto 7);
  s_id_rs1Addr <= s_currentInst(19 downto 15);
  s_id_rs2Addr <= s_currentInst(24 downto 20);

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
      po_immediateImm => open,
      po_storeImm => open,
      po_selectedImm => s_id_immediate
    );

  -- end solution!!
  ---********************************************************************
  ---* Pipeline-Register (ID -> EX) 
  ---********************************************************************
  -- begin solution: 

  -- Controlword ID->EX pipelining
  ID_EX_CONTROLWORD : entity work.ControlWordRegister(arc1)
    port map(
      pi_rst => s_rst,
      pi_clk => s_clk,
      pi_controlWord => s_id_controlword,
      po_controlWord => s_ex_controlword
    );

  -- Dst address ID->EX pipelining
  ID_EX_PIPELINE : entity work.PipelineRegister(behavior)
    generic map(
      registerWidth => REG_ADR_WIDTH
    )
    port map(
      pi_clk => s_clk,
      pi_rst => s_rst,
      pi_flush => s_flush or s_stall,
      pi_data => s_id_dAddr,
      po_data => s_ex_dAddr
    );

  -- Immediate ID->EX pipelining
  ID_EX_IMMEDIATE : entity work.PipelineRegister(behavior)
    generic map(
      registerWidth => WORD_WIDTH
    )
    port map(
      pi_clk => s_clk,
      pi_rst => s_rst,
      pi_flush => s_flush or s_stall,
      pi_data => s_id_immediate,
      po_data => s_ex_immediate
    );

  -- PC ID->EX pipelining
  PC_ID_EX : entity work.PipelineRegister(behavior)
    generic map(
      registerWidth => WORD_WIDTH
    )
    port map(
      pi_clk => s_clk,
      pi_rst => s_rst,
      pi_flush => s_flush or s_stall,
      pi_data => s_id_pc,
      po_data => s_ex_pc
    );

  -- PC EX-Phase Adder (adds 4 to PC in EX-Phase)
  PC_EX_ADDER : entity work.my_gen_n_bit_full_adder(structure)
    generic map(
      G_DATA_WIDTH => WORD_WIDTH
    )
    port map(
      pi_a => CONST_FOUR,
      pi_b => s_ex_pc,
      pi_carryIn => '0',
      po_sum => s_ex_pcPlus4,
      po_carryOut => open
    );

  -- ALU OP1 OF->EX pipelining
  OP1_REGISTER : entity work.PipelineRegister(behavior)
    generic map(
      registerWidth => WORD_WIDTH
    )
    port map(
      pi_clk => s_clk,
      pi_rst => s_rst,
      pi_flush => s_flush or s_stall,
      pi_data => s_of_bp_rs1,
      po_data => s_ex_rs1
    );

  -- ALU OP2 OF->EX pipelining
  OP2_REGISTER : entity work.PipelineRegister(behavior)
    generic map(
      registerWidth => WORD_WIDTH
    )
    port map(
      pi_clk => s_clk,
      pi_rst => s_rst,
      pi_flush => s_flush or s_stall,
      pi_data => s_of_bp_rs2,
      po_data => s_ex_rs2
    );

  -- end solution!!
  ---********************************************************************
  ---* Forwarding
  ---********************************************************************

  -- Prioritization
  s_id_bp_rs1_sel <= "01" when (s_id_rs1Addr = s_ex_dAddr) and (s_stall = '0') else
                     "10" when (s_id_rs1Addr = s_mem_dAddr) else
                     "11" when (s_id_rs1Addr = s_wb_dAddr) else
                     "00";

  s_id_bp_rs2_sel <= "01" when (s_id_rs2Addr = s_ex_dAddr) and (s_stall = '0') else
                     "10" when (s_id_rs2Addr = s_mem_dAddr) else
                     "11" when (s_id_rs2Addr = s_wb_dAddr) else
                     "00";

  -- Forwarding for data memory
  s_mem_bp_rs1 <= s_memory_out when (s_id_rs1Addr = s_mem_dAddr) and (s_mem_controlword.MEM_READ = '1') else
                  s_mem_aluOut;

  s_mem_bp_rs2 <= s_memory_out when (s_id_rs2Addr = s_mem_dAddr) and (s_mem_controlword.MEM_READ = '1') else
                  s_mem_aluOut;

  -- Stall logic
  s_stall <= '1' when
             (s_ex_controlword.MEM_READ = '1') and
             ((s_ex_dAddr /= "00000") and
             ((s_ex_dAddr = s_id_rs1Addr) or
             (s_ex_dAddr = s_id_rs2Addr)))
             else
             '0';

  ---********************************************************************
  ---* execute phase
  ---********************************************************************
  -- begin solution:

  -- ==== ALU OP1 ====

  BP_RS1_MUX_OF : entity work.gen_mux(behavior)
    generic map(
      dataWidth => WORD_WIDTH
    )
    port map(
      pi_in0 => s_of_rs1,
      pi_in1 => s_ex_aluOut,
      pi_in2 => s_mem_bp_rs1,
      pi_in3 => s_wb_writeData,
      pi_sel => s_id_bp_rs1_sel,
      pOut => s_of_bp_rs1
    );

  -- ALU OP1 Register / PC multiplexer
  OP1_SEL : entity work.gen_mux2to1(behavior)
    generic map(
      dataWidth => WORD_WIDTH
    )
    port map(
      pi_first => s_ex_rs1, -- Register
      pi_second => s_ex_pc, -- Program counter
      pi_sel => s_ex_controlword.A_SEL, -- Select between Register / PC
      pOut => s_ex_rs1_sel
    );

  -- ==== ALU OP2 ====

  BP_RS2_MUX_OF : entity work.gen_mux(behavior)
    generic map(
      dataWidth => WORD_WIDTH
    )
    port map(
      pi_in0 => s_of_rs2,
      pi_in1 => s_ex_aluOut,
      pi_in2 => s_mem_bp_rs2,
      pi_in3 => s_wb_writeData,
      pi_sel => s_id_bp_rs2_sel,
      pOut => s_of_bp_rs2
    );

  -- ALU OP2 Register / Immediate multiplexer  
  OP2_SEL : entity work.gen_mux2to1(behavior)
    generic map(
      dataWidth => WORD_WIDTH
    )
    port map(
      pi_first => s_ex_rs2, -- Register value
      pi_second => s_ex_immediate, -- Immediate value
      pi_sel => s_ex_controlword.I_IMM_SEL, -- Select between register or immediate
      pOut => s_ex_rs2_sel
    );

  ALU : entity work.my_alu(behavior)
    generic map(
      G_DATA_WIDTH => WORD_WIDTH,
      G_OP_WIDTH => ALU_OPCODE_WIDTH
    )
    port map(
      pi_OP1 => s_ex_rs1_sel,
      pi_OP2 => s_ex_rs2_sel,
      pi_aluOP => s_ex_controlword.ALU_OP,
      po_aluOut => s_ex_aluOut,
      po_carryOut => open,
      po_zero => s_ex_zero
    );

  -- end solution!!
  ---********************************************************************
  ---* PC branch selection
  ---********************************************************************

  BRANCH_ADDER : entity work.my_gen_n_bit_full_adder(structure)
    generic map(
      G_DATA_WIDTH => WORD_WIDTH
    )
    port map(
      pi_a => s_ex_pc,
      pi_b => s_ex_immediate,
      pi_carryIn => '0',
      po_sum => s_ex_branchAddr,
      po_carryOut => open
    );

  s_ex_pc_sel <= s_ex_controlword.IS_BRANCH and (s_ex_zero xor s_ex_controlword.CMP_RESULT);

  -- Pipeline Branch Selection
  process (s_clk, s_rst)
  begin
    if (s_rst) then
      s_mem_pc_sel <= '0';
    elsif rising_edge (s_clk) then --bei Sprung Register reset
      s_mem_pc_sel <= s_ex_pc_sel;
    end if;
  end process;

  s_flush <= s_mem_pc_sel or s_mem_controlword.PC_SEL;

  ---********************************************************************
  ---* Pipeline-Register (EX -> MEM) 
  ---********************************************************************
  -- begin solution:

  -- Controlword EX->MEM pipelining
  EX_MEM_CONTROLWORD : entity work.ControlWordRegister(arc1)
    port map(
      pi_rst => s_rst,
      pi_clk => s_clk,
      pi_flush => s_flush,
      pi_controlWord => s_ex_controlword,
      po_controlWord => s_mem_controlword
    );

  -- Dst adress EX->MEM pipelining
  EX_MEM_PIPELINE : entity work.PipelineRegister(behavior)
    generic map(
      registerWidth => REG_ADR_WIDTH
    )
    port map(
      pi_clk => s_clk,
      pi_rst => s_rst,
      pi_flush => s_flush,
      pi_data => s_ex_dAddr,
      po_data => s_mem_dAddr
    );

  -- Immediate EX->MEM pipelining
  EX_MEM_IMMEDIATE : entity work.PipelineRegister(behavior)
    generic map(
      registerWidth => WORD_WIDTH
    )
    port map(
      pi_clk => s_clk,
      pi_rst => s_rst,
      pi_flush => s_flush,
      pi_data => s_ex_immediate,
      po_data => s_mem_immediate
    );

  -- PC+4 EX->MEM pipelining
  PC_PLUS4_EX_MEM : entity work.PipelineRegister(behavior)
    generic map(
      registerWidth => WORD_WIDTH
    )
    port map(
      pi_clk => s_clk,
      pi_rst => s_rst,
      pi_flush => s_flush,
      pi_data => s_ex_pcPlus4,
      po_data => s_mem_pcPlus4
    );

  EX_MEM_BRANCH : entity work.PipelineRegister(behavior)
    generic map(
      registerWidth => WORD_WIDTH
    )
    port map(
      pi_clk => s_clk,
      pi_rst => s_rst,
      pi_flush => s_flush,
      pi_data => s_ex_branchAddr,
      po_data => s_mem_branchAddr
    );

  -- ALU out EX->MEM pipelining
  EX_MEM_ALU_PIPELINE : entity work.PipelineRegister(behavior)
    generic map(
      registerWidth => WORD_WIDTH
    )
    port map(
      pi_clk => s_clk,
      pi_rst => s_rst,
      pi_flush => s_flush,
      pi_data => s_ex_aluOut,
      po_data => s_mem_aluOut
    );

  -- Pipeline register for Memory data
  EX_MEM_OP2 : entity work.PipelineRegister(behavior)
    generic map(
      registerWidth => WORD_WIDTH
    )
    port map(
      pi_clk => s_clk,
      pi_rst => s_rst,
      pi_flush => s_flush,
      pi_data => s_ex_rs2,
      po_data => s_mem_rs2
    );

  -- end solution!!
  ---********************************************************************
  ---* memory phase
  ---********************************************************************
  -- begin solution:

  DATA_MEMORY : entity work.data_memory(behavior)
    generic map(
      adr_width => ADR_WIDTH
    )
    port map(
      pi_adr => s_mem_aluOut,
      pi_clk => not s_clk,
      pi_rst => s_rst,
      pi_ctrmem => s_mem_controlword.MEM_CTR,
      pi_write => s_mem_controlword.MEM_WRITE,
      pi_read => s_mem_controlword.MEM_READ,
      pi_writedata => s_mem_rs2,
      po_readdata => s_memory_out,
      po_debugdatamemory => s_datamemoryOut
    );

  -- end solution!!
  ---********************************************************************
  ---* Pipeline-Register (MEM -> WB) 
  ---********************************************************************
  -- begin solution:

  -- Controlword MEM->WB pipelining
  MEM_WB_CONTROLWORD : entity work.ControlWordRegister(arc1)
    port map(
      pi_rst => s_rst,
      pi_clk => s_clk,
      pi_controlWord => s_mem_controlword,
      po_controlWord => s_wb_controlword
    );

  -- Dst adress MEM->WB pipelining
  MEM_WB_PIPELINE : entity work.PipelineRegister(behavior)
    generic map(
      registerWidth => REG_ADR_WIDTH
    )
    port map(
      pi_clk => s_clk,
      pi_rst => s_rst,
      pi_data => s_mem_dAddr,
      po_data => s_wb_dAddr
    );

  -- Immediate MEM->WB pipelining
  MEM_WB_IMMEDIATE : entity work.PipelineRegister(behavior)
    generic map(
      registerWidth => WORD_WIDTH
    )
    port map(
      pi_clk => s_clk,
      pi_rst => s_rst,
      pi_data => s_mem_immediate,
      po_data => s_wb_immediate
    );

  -- PC+4 MEM->WB pipelining
  PC_PLUS4_MEM_WB : entity work.PipelineRegister(behavior)
    generic map(
      registerWidth => WORD_WIDTH
    )
    port map(
      pi_clk => s_clk,
      pi_rst => s_rst,
      pi_data => s_mem_pcPlus4, -- PC+4 for MEM phase
      po_data => s_wb_pcPlus4
    );

  -- ALU out MEM->WB pipelining
  MEM_WB_ALU_PIPELINE : entity work.PipelineRegister(behavior)
    generic map(
      registerWidth => WORD_WIDTH
    )
    port map(
      pi_clk => s_clk,
      pi_rst => s_rst,
      pi_data => s_mem_aluOut,
      po_data => s_wb_aluOut
    );

  -- end solution!!
  ---********************************************************************
  ---* write back phase
  ---********************************************************************
  -- begin solution:

  -- Write back multiplexer for Registerfile
  WB_SEL_MUX : entity work.gen_mux(behavior)
    generic map(
      dataWidth => WORD_WIDTH
    )
    port map(
      pi_in0 => s_wb_aluOut,
      pi_in1 => s_wb_immediate,
      pi_in2 => s_wb_pcPlus4,
      pi_in3 => s_memory_out,
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
      pi_clk => not s_clk,
      pi_rst => s_rst,
      pi_readRegAddr1 => s_id_rs1Addr,
      pi_readRegAddr2 => s_id_rs2Addr,
      pi_writeRegAddr => s_wb_dAddr,
      pi_writeRegData => s_wb_writeData,
      pi_writeEnable => s_wb_controlword.REG_WRITE,
      po_readRegData1 => s_of_rs1,
      po_readRegData2 => s_of_rs2,
      po_registerOut => s_registersOut
    );

  -- end solution!!
  ---********************************************************************
end architecture;