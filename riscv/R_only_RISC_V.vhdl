-- Laboratory RA solutions/versuch4
-- Sommersemester 25
-- Group Details
-- Lab Date:
-- 1. Participant First and Last Name: 
-- 2. Participant First and Last Name:

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

entity r_only_RISC_V is
  port (
    pi_rst : in std_logic;
    pi_clk : in std_logic;
    pi_instruction : in memory := (others => (others => '0'));
    po_registersOut : out registerMemory := (others => (others => '0'))
  );
end entity r_only_RISC_V;

architecture structure of r_only_RISC_V is

  constant PERIOD : time := 10 ns;
  constant ADD_FOUR_TO_ADDRESS : std_logic_vector(WORD_WIDTH - 1 downto 0) := std_logic_vector(to_signed((4), WORD_WIDTH));
  -- signals
  -- begin solution:
  signal s_pc_currentAddr: std_logic_vector(WORD_WIDTH - 1 downto 0); -- Current adress instruction in pc
  signal s_pc_newAddr: std_logic_vector(WORD_WIDTH - 1 downto 0); -- New address for next instruction in pc
  signal s_instruction: std_logic_vector(WORD_WIDTH - 1 downto 0);
  signal s_id_controlword, s_ex_controlword, s_mem_controlword, s_wb_controlword: controlword;
  signal s_id_regAddr, s_ex_regAddr, s_mem_regAddr, s_wb_regAddr: std_logic_vector(REG_ADR_WIDTH - 1 downto 0);
  -- end solution!!
begin

  ---********************************************************************
  ---* program counter adder and pc-register
  ---********************************************************************
  -- begin solution:  
  PC_ADDER: entity work.my_gen_n_bit_full_adder(structure)
    generic map (
      G_DATA_WIDTH => WORD_WIDTH
    )
    port map (
      P_A => ADD_FOUR_TO_ADDRESS,
      P_B => s_pc_currentAddr,
      P_CARRY_IN => '0',
      P_SUM => s_pc_newAddr,
      P_CARRY_OUT => open
    );

  PC: entity work.PipelineRegister(behavior)
    generic map (
      registerWidth => WORD_WIDTH
    )
    port map (
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
  INSTRUCTION_CACHE: entity work.instruction_cache(behavior)
  generic map (
    adr_width => ADR_WIDTH,
    mem_size => 2 ** 10
  )
  port map (
    pi_adr => s_pc_currentAddr,
    pi_clk => pi_clk,
    pi_instructionCache => pi_instruction,
    po_instruction => s_instruction
  );
  -- end solution!!

  ---********************************************************************
  ---* Pipeline-Register (IF -> ID) start
  ---********************************************************************

  -- begin solution:
  -- end solution!!

  ---********************************************************************
  ---* decode phase
  ---********************************************************************
  -- begin solution:
  INSTRUCTION_DECODER: entity work.decoder
    generic map (
      word_width => WORD_WIDTH
    )
    port map (
      pi_clk => pi_clk,
      pi_instruction => s_instruction,
      po_controlWord => s_id_controlword
    );
  -- end solution!!

  ---********************************************************************
  ---* Pipeline-Register (ID -> EX) 
  ---********************************************************************
  -- begin solution: 
  -- end solution!!

  ---********************************************************************
  ---* execute phase
  ---********************************************************************
  -- begin solution:
  -- end solution!!

  ---********************************************************************
  ---* Pipeline-Register (EX -> MEM) 
  ---********************************************************************
  -- begin solution:
  -- end solution!!

  ---********************************************************************
  ---* memory phase
  ---********************************************************************

  ---********************************************************************
  ---* Pipeline-Register (MEM -> WB) 
  ---********************************************************************
  -- begin solution:
  -- end solution!!

  ---********************************************************************
  ---* write back phase
  ---********************************************************************

  ---********************************************************************
  ---* register file (negative clock)
  ---********************************************************************
  -- begin solution:
  REGISTER_FILE: entity work.register_file(behavior)
    generic map (
      word_width => WORD_WIDTH,
      adr_width => REG_ADR_WIDTH
    )
    port map (
      pi_clk => pi_clk,
      pi_rst => pi_rst,
      pi_readRegAddr1 => s_instruction(19 downto 15),
      pi_readRegAddr2 => s_instruction(24 downto 20),
      pi_writeRegAddr => s_wb_regAddr,
      pi_writeRegData => open,
      pi_writeEnable => s_wb_controlword.REG_WRITE,
      po_readRegData1 => open,
      po_readRegData2 => open
    );
  -- end solution!!
  ---********************************************************************
  ---********************************************************************    

end architecture;