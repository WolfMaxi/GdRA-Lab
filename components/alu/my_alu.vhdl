-- Laboratory RA solutions/versuch1
-- Sommer Semester 25
-- Group Details
-- Lab Date: 29.04.2025
-- 1. Participant First and  Last Name: Maximilian Wolf
-- 2. Participant First and Last Name: Esad-Muhammed Cekmeci
 
 
-- coding conventions
-- g_<name> Generics
-- p_<name> Ports
-- c_<name> Constants
-- s_<name> Signals
-- v_<name> Variables

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.Constant_Package.ALL;


entity my_alu is
  generic (
    G_DATA_WIDTH  : integer := DATA_WIDTH_GEN;
    G_OP_WIDTH    : integer := OPCODE_WIDTH
  );
  port (
    -- begin solution:
    pi_OP1 : in std_logic_vector(G_DATA_WIDTH - 1 downto 0);
    pi_OP2 : in std_logic_vector(G_DATA_WIDTH - 1 downto 0);
    pi_aluOP : in std_logic_vector(G_OP_WIDTH - 1 downto 0);
    po_aluOut : out std_logic_vector(G_DATA_WIDTH - 1 downto 0);
    po_carryOut : out std_logic := '0'
    -- end solution!!
  );

end entity my_alu;

architecture behavior of my_alu is
  signal s_res1, s_res2, s_res3, s_res4, s_res5, s_res6, s_res7, s_res8 : STD_LOGIC_VECTOR(G_DATA_WIDTH - 1 downto 0) := (others => '0');
  signal s_cIn,s_cOut,s_shift_type,s_shift_direction   : STD_LOGIC := '0';

begin
  XOR1:  entity work.my_gen_xor generic map (G_DATA_WIDTH) port map (pi_OP1, pi_op2, s_res1);
  OR1:   entity work.my_gen_or  generic map (G_DATA_WIDTH) port map (pi_op1, pi_op2, s_res2);
  AND1:  entity work.my_gen_and generic map (G_DATA_WIDTH) port map (pi_op1, pi_op2, s_res3);
  Shift: entity work.my_shifter generic map (G_DATA_WIDTH) port map (pi_op1, pi_op2,s_shift_type,s_shift_direction, s_res4);
  ADD1:  entity work.my_gen_n_bit_full_adder generic map (G_DATA_WIDTH) port map (pi_op1, pi_op2, s_cIn, s_res5, s_cOut);

-- begin solution:
s_cIn <= pi_aluOP(G_OP_WIDTH - 1);
s_shift_type <= pi_aluOP(G_OP_WIDTH - 1);

with pi_aluOP select
  s_shift_direction <= '0' when SLL_ALU_OP,
                        '1' when SRL_ALU_OP,
                        '1' when SRA_ALU_OP,
                        '0' when others;
                        
with pi_aluOP select
  po_aluOut <= s_res1 when XOR_ALU_OP,
              s_res2 when OR_ALU_OP,
              s_res3 when AND_ALU_OP,
              s_res4 when SLL_ALU_OP,
              s_res4 when SRL_ALU_OP,
              s_res4 when SRA_ALU_OP,
              s_res5 when ADD_ALU_OP,
              s_res5 when SUB_ALU_OP,
              (others => '0') when others;

po_carryOut <= s_cOut;
-- end solution!!
end architecture behavior;
