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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Constant_Package.all;

entity my_alu is
  generic (
    G_DATA_WIDTH : integer := DATA_WIDTH_GEN;
    G_OP_WIDTH : integer := OPCODE_WIDTH
  );
  port (
    -- begin solution:
    pi_op1, pi_op2 : in std_logic_vector(G_DATA_WIDTH - 1 downto 0) := (others => '0');
    pi_aluOP : in std_logic_vector(G_OP_WIDTH - 1 downto 0) := (others => '0');
    po_aluOut : out std_logic_vector(G_DATA_WIDTH - 1 downto 0) := (others => '0');
    po_carryOut, po_zero : out std_logic := '0'
    -- end solution!!
  );

end entity my_alu;

architecture behavior of my_alu is
  signal s_res1, s_res2, s_res3, s_res4, s_res5, s_res6 : std_logic_vector(G_DATA_WIDTH - 1 downto 0) := (others => '0');
  signal s_cIn, s_cOut, s_shift_type, s_shift_direction, s_isSigned : std_logic := '0';

begin
  XOR1 : entity work.my_gen_xor(behavior) generic map (G_DATA_WIDTH) port map (pi_OP1, pi_op2, s_res1);
  OR1 : entity work.my_gen_or(behavior) generic map (G_DATA_WIDTH) port map (pi_op1, pi_op2, s_res2);
  AND1 : entity work.my_gen_and(behavior) generic map (G_DATA_WIDTH) port map (pi_op1, pi_op2, s_res3);
  Shift : entity work.my_shifter(behavior) generic map (G_DATA_WIDTH) port map (pi_op1, pi_op2, s_shift_type, s_shift_direction, s_res4);
  ADD1 : entity work.my_gen_n_bit_full_adder(structure) generic map (G_DATA_WIDTH) port map (pi_op1, pi_op2, s_cIn, s_res5, s_cOut);
  COMP: entity work.my_comparator(behavior) generic map (G_DATA_WIDTH) port map (pi_op1, pi_op2, s_isSigned, s_res6);

  -- begin solution:
  s_cIn <= pi_aluOP(G_OP_WIDTH - 1);
  s_shift_type <= pi_aluOP(G_OP_WIDTH - 1);

  -- Shift direction for shifter
  with pi_aluOP select
    s_shift_direction <=  '0' when SLL_ALU_OP,
                          '1' when SRL_ALU_OP,
                          '1' when SRA_ALU_OP,
                          '0' when others;

  -- Signed / Unsigned for comparator
  with pi_aluOP select
    s_isSigned <= '0' when SLTU_ALU_OP,
                  '0' when SLTIU_ALU_OP,
                  '1' when SLT_ALU_OP,
                  '0' when others;

  with pi_aluOP select
    po_aluOut <=  s_res1 when XOR_ALU_OP,
                  s_res2 when OR_ALU_OP,
                  s_res3 when AND_ALU_OP,
                  s_res4 when SLL_ALU_OP,
                  s_res4 when SRL_ALU_OP,
                  s_res4 when SRA_ALU_OP,
                  s_res5 when ADD_ALU_OP,
                  s_res5 when SUB_ALU_OP,
                  s_res6 when SLT_ALU_OP,
                  s_res6 when SLTU_ALU_OP,
                  s_res6 when SLTIU_ALU_OP,
                  (others => '0') when others;

  po_carryOut <= s_cOut;
  po_zero <= '1' when po_aluOut = std_logic_vector(to_unsigned(0, DATA_WIDTH_GEN)) else '0';
  -- end solution!!
end architecture behavior;
