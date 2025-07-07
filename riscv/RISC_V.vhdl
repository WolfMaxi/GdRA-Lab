library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constant_package.all;
use work.util_asm_package.all;
use work.types.all;

entity riscv is
  port (
    KEY : in std_logic_vector (1 downto 0);
    SW : in std_logic_vector (9 downto 0);
    LEDR : out std_logic_vector (7 downto 0);
    HEX0, HEX1 : out std_logic_vector (6 downto 0);
    HEX2, HEX3 : out std_logic_vector (6 downto 0);
    HEX4, HEX5 : out std_logic_vector (6 downto 0)
  );
end entity riscv;

architecture structure of riscv is
  signal s_rst : std_logic := '0';
  signal s_clk : std_logic := '0';
  signal s_instruction : std_logic_vector(WORD_WIDTH - 1 downto 0) := (others => '0');
  signal s_instructions : memory := (others => (others => '0'));
  signal s_registersOut : registerMemory := (others => (others => '0'));
  signal s_datamemoryOut : memory := (others => (others => '0'));

  type segment_array is array(0 to 5) of std_logic_vector(6 downto 0);
  signal seg_patterns : segment_array := (others => (others => '0'));

begin
  processor : entity work.riubs_bp_only_RISC_V
    port map(
      pi_clk => s_clk,
      pi_rst => s_rst,
      pi_instruction => s_instructions,
      po_registersOut => s_registersOut,
      po_debugdatamemory => s_datamemoryOut
    );

  s_rst <= not KEY(0);
  s_clk <= KEY(1);
  s_instruction <= s_instructions(to_integer(unsigned(SW(9 downto 5))));
  LEDR(7 downto 0) <= s_registersOut(to_integer(unsigned(SW(4 downto 0))))(7 downto 0);

  -- Generate - Schleife f ü r 6 Decoderinstanzen
  gen_decoder : for i in 0 to 5 generate
    decoder_inst : entity work.hex_7seg_decoder
      port map(
        bin_in => s_instruction((i * 4 + 3) downto i * 4),
        seg_out => seg_patterns(i)
      );
  end generate;

  -- Zuweisung zu den HEX - Anzeigen
  HEX0 <= seg_patterns(0);
  HEX1 <= seg_patterns(1);
  HEX2 <= seg_patterns(2);
  HEX3 <= seg_patterns(3);
  HEX4 <= seg_patterns(4);
  HEX5 <= seg_patterns(5);

  -- Instruktionen
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
end architecture;
