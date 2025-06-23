-- Laboratory RA solutions/versuch8
-- Sommersemester 25
-- Group Details
-- Lab Date:
-- 1. Participant First and Last Name: 
-- 2. Participant First and Last Name:

-- ========================================================================
-- Author:       Marcel Rieß
-- Last updated: 10.06.2025
-- Description:  RIUBS-Only-RISC-V (incomplete RV32I implementation)
--               Supports only R-, I-, U-, B- and S-Instructions.
-- ========================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constant_package.all;
use work.types.all;
use work.util_asm_package.all;

entity riubs_only_RISC_V_tb is
end entity;

architecture structure of riubs_only_RISC_V_tb is

  constant PERIOD : time := 10 ns;
  constant WITH_FLUSH : std_logic := '1';
  signal s_clk : std_logic := '0';
  signal s_rst : std_logic;
  signal cycle : integer := 0;
  signal test : integer := 0;

  signal s_registersOut : registerMemory := (others => (others => '0'));
  signal s_instructions : memory := (others => (others => '0'));
  signal s_debugdatamemory : memory := (others => (others => '0'));

  -- Registerprüfung
  procedure check_register(expected : integer; reg_num : integer; instr : string) is
  begin
    assert (to_integer(signed(s_registersOut(reg_num))) = expected)
    report instr & " fehlgeschlagen. Register " & integer'image(reg_num) &
      " enthaelt " & integer'image(to_integer(signed(s_registersOut(reg_num)))) &
      ", sollte aber " & integer'image(expected) & " enthalten!"
      severity error;
  end procedure;

  -- Wiederverwendbares Instruktionsset (ADDI, OR, ADD, etc.)
  procedure load_common_instructions(mem : inout memory;v_test : integer) is
  begin
    mem(1) := Asm2Std("ADDI", 1, 0, 9);
    mem(2) := Asm2Std("ADDI", 2, 0, 8);
    mem(6) := Asm2Std("OR", 10, 1, 2);
    mem(7) := Asm2Std("ADD", 8, 1, 2);
    mem(8) := Asm2Std("SUB", 11, 1, 2);
    mem(9) := Asm2Std("SUB", 12, 2, 1);
    mem(11) := Asm2Std("ADD", 12, 2, 8);
    mem(12) := Asm2Std("SUB", 12, 2, 1);
    mem(13) := Asm2Std("AND", 1, 2, 1);
    mem(14) := Asm2Std("XOR", 12, 1, 2);
    mem(15) := Asm2Std("LUI", 13, 8, 0);
    mem(16) := Asm2Std("LUI", 13, 29, 0);
    if v_test >= 2 then
      mem(17) := Asm2Std("AUIPC", 14, 1, 0);
      mem(18) := Asm2Std("AUIPC", 14, 1, 0);
    end if;

    if v_test = 3 then
      mem(19) := Asm2Std("JAL", 15, -36, 0);
    end if;

    if v_test = 7 then
      mem(19) := Asm2Std("JAL", 15, 70, 0);
      mem(20) := Asm2Std("ADDI", 1, 0, 99);
      mem(21) := Asm2Std("ADDI", 1, 0, 98);
      mem(22) := Asm2Std("ADDI", 1, 0, 97);
      mem(54) := Asm2Std("JALR", 15, 15, -56);
      mem(55) := Asm2Std("ADDI", 1, 0, 96);
      mem(56) := Asm2Std("ADDI", 1, 0, 95);
      mem(57) := Asm2Std("ADDI", 1, 0, 94);
    end if;
    if v_test = 4 then
      mem(19) := Asm2Std("JAL", 15, 70, 0);
      mem(54) := Asm2Std("JALR", 15, 15, -56);
    end if;

    if v_test >= 5 and v_test <= 6 then
      mem := (others => (others => '0'));
      mem(1) := Asm2Std("ADDI", 1, 0, 9);
      mem(2) := Asm2Std("ADDI", 2, 0, 9);
      mem(6) := Asm2Std("BEQ", 1, 2, 4);
      mem(7) := Asm2Std("ADDI", 1, 0, 666);
      mem(8) := Asm2Std("ADDI", 1, 0, 0);

      mem(9) := Asm2Std("ADDI", 1, 0, 16);
      mem(10) := Asm2Std("ADDI", 2, 0, 8);
      mem(14) := Asm2Std("BNE", 2, 1, 4);
      mem(15) := Asm2Std("ADDI", 1, 0, 999);
      mem(16) := Asm2Std("ADDI", 1, 0, 1);

      --rs1<rs2
      mem(17) := Asm2Std("ADDI", 1, 0, 6);
      mem(18) := Asm2Std("ADDI", 2, 0, 8);
      mem(22) := Asm2Std("BLT", 1, 2, 4);
      mem(23) := Asm2Std("ADDI", 1, 0, 666);
      mem(24) := Asm2Std("ADDI", 1, 0, 2);

      --rs1>rs2
      mem(25) := Asm2Std("ADDI", 1, 0, 9);
      mem(26) := Asm2Std("ADDI", 2, 0, 7);
      mem(30) := Asm2Std("BGE", 1, 2, 4);
      mem(31) := Asm2Std("ADDI", 1, 0, 999);
      mem(32) := Asm2Std("ADDI", 1, 0, 3);

      mem(33) := Asm2Std("ADDI", 1, 0, 11);
      mem(34) := Asm2Std("ADDI", 2, 0, 13);
      mem(38) := Asm2Std("BLTU", 1, 2, 4);
      mem(39) := Asm2Std("ADDI", 1, 0, 666);
      mem(40) := Asm2Std("ADDI", 1, 0, 4);

      mem(41) := Asm2Std("ADDI", 1, 0, 15);
      mem(42) := Asm2Std("ADDI", 2, 0, 14);
      mem(46) := Asm2Std("BGEU", 1, 2, 4);
      mem(47) := Asm2Std("ADDI", 1, 0, 999);
      mem(48) := Asm2Std("ADDI", 1, 0, 5);

      mem(48 + 1) := Asm2Std("ADDI", 1, 0, 9);
      mem(48 + 2) := Asm2Std("ADDI", 2, 0, 8);
      mem(48 + 6) := Asm2Std("BEQ", 2, 1, 4);
      mem(48 + 7) := Asm2Std("ADDI", 1, 0, 666);
      mem(48 + 8) := Asm2Std("ADDI", 1, 0, 0);

      mem(48 + 9) := Asm2Std("ADDI", 1, 0, 8);
      mem(48 + 10) := Asm2Std("ADDI", 2, 0, 8);
      mem(48 + 14) := Asm2Std("BNE", 1, 2, 4);
      mem(48 + 15) := Asm2Std("ADDI", 1, 0, 669);
      mem(48 + 16) := Asm2Std("ADDI", 1, 0, 1);

      --rs1<rs2
      mem(48 + 17) := Asm2Std("ADDI", 1, 0, 6);
      mem(48 + 18) := Asm2Std("ADDI", 2, 0, 8);
      mem(48 + 22) := Asm2Std("BLT", 2, 1, 4);
      mem(48 + 23) := Asm2Std("ADDI", 1, 0, 699);
      mem(48 + 24) := Asm2Std("ADDI", 1, 0, 2);

      --rs1>rs2
      mem(48 + 25) := Asm2Std("ADDI", 1, 0, 9);
      mem(48 + 26) := Asm2Std("ADDI", 2, 0, 7);
      mem(48 + 30) := Asm2Std("BGE", 2, 1, 4);
      mem(48 + 31) := Asm2Std("ADDI", 1, 0, 999);
      mem(48 + 32) := Asm2Std("ADDI", 1, 0, 3);

      mem(48 + 33) := Asm2Std("ADDI", 1, 0, 11);
      mem(48 + 34) := Asm2Std("ADDI", 2, 0, 13);
      mem(48 + 38) := Asm2Std("BLTU", 2, 1, 4);
      mem(48 + 39) := Asm2Std("ADDI", 1, 0, 996);
      mem(48 + 40) := Asm2Std("ADDI", 1, 0, 4);

      mem(48 + 41) := Asm2Std("ADDI", 1, 0, 15);
      mem(48 + 42) := Asm2Std("ADDI", 2, 0, 14);
      mem(48 + 46) := Asm2Std("BGEU", 2, 1, 4);
      mem(48 + 47) := Asm2Std("ADDI", 1, 0, 966);
      mem(48 + 48) := Asm2Std("ADDI", 1, 0, 5);
      mem(48 + 49) := Asm2Std("JAL", 15, 70, 0);
      mem(48 + 50) := Asm2Std("ADDI", 1, 0, 15);
      mem(48 + 51) := Asm2Std("ADDI", 1, 0, 14);
      mem(48 + 52) := Asm2Std("ADDI", 1, 0, 13);
      mem(48 + 49 + 35) := Asm2Std("JALR", 15, 15, -56);
      mem(48 + 49 + 35 + 1) := Asm2Std("ADDI", 1, 0, 12);
      mem(48 + 49 + 35 + 2) := Asm2Std("ADDI", 1, 0, 11);
      mem(48 + 49 + 35 + 3) := Asm2Std("ADDI", 1, 0, 10);
    end if;
    if v_test = 8 then
      -- Ausgangswert setzen
      mem(1) := Asm2Std("ADDI", 1, 0, 42); -- x1 = 42

      -- Shift-Tests
      mem(5) := Asm2Std("SLLI", 5, 1, 1); -- x5 = x1 << 1 = 84
      mem(6) := Asm2Std("SLLI", 6, 1, 4); -- x6 = x1 << 4 = 672
      mem(7) := Asm2Std("SRLI", 7, 1, 1); -- x7 = x1 >> 1 = 21 (logisch)
      mem(8) := Asm2Std("SRLI", 8, 1, 4); -- x8 = x1 >> 4 = 2
      mem(9) := Asm2Std("SRAI", 9, 1, 1); -- x9 = x1 >> 1 = 21 (arith.)
      mem(10) := Asm2Std("SRAI", 10, 1, 4); -- x10 = x1 >> 4 = 2

      -- Optional: negative Werte testen
      mem(11) := Asm2Std("ADDI", 1, 0, -8); -- x1 = -8
      mem(15) := Asm2Std("SRAI", 11, 1, 1); -- x11 = -4 (arithmetischer Shift)
    end if;

    if v_test = 9 then
      -- Initialwerte vorbereiten
      mem := (others => (others => '0'));
      mem(1) := Asm2Std("ADDI", 1, 0, 100); -- x1 = Adresse 100 (Basisadresse)
      mem(2) := Asm2Std("ADDI", 2, 0, 42); -- x2 = Datenwert 42
      mem(3) := Asm2Std("ADDI", 3, 0, -1); -- x3 = Datenwert -1 (0xFFFFFFFF)

      -- STORE WORD
      mem(7) := Asm2Std("SW", 1, 2, 0); -- Mem[100] = x2 (42)
      -- LOAD WORD
      mem(12) := Asm2Std("LW", 4, 1, 0); -- x4 = Mem[100], sollte 42 sein

      -- STORE BYTE
      mem(13) := Asm2Std("SB", 1, 3, 4); -- Mem[104] = x3 (nur LSB: 0xFF)
      -- LOAD BYTE (signed)
      mem(18) := Asm2Std("LB", 5, 1, 4); -- x5 = Mem[104], sollte -1
      -- LOAD BYTE (unsigned)
      mem(19) := Asm2Std("LBU", 6, 1, 4); -- x6 = Mem[104], sollte 255

      -- STORE HALFWORD
      mem(20) := Asm2Std("SH", 1, 3, 8); -- Mem[108..109] = x3 (nur LSB 16 Bit)
      -- LOAD HALFWORD (signed)
      mem(25) := Asm2Std("LH", 7, 1, 8); -- x7 = Mem[108..109], sollte -1
      -- LOAD HALFWORD (unsigned)
      mem(26) := Asm2Std("LHU", 8, 1, 8); -- x8 = Mem[108..109], sollte 65535
    end if;

  end procedure;

begin

  -- DUT
  riubs_only_riscv : entity work.riubs_only_RISC_V
    port map(
      pi_rst => s_rst,
      pi_clk => s_clk,
      pi_instruction => s_instructions,
      po_registersOut => s_registersOut,
      po_debugdatamemory => s_debugdatamemory
    );

  -- Taktgenerator
  process
  begin
    while now < 10000 ns loop
      wait for PERIOD / 2;
      s_clk <= not s_clk;
    end loop;
    wait; -- Prozess beenden
  end process;

  -- Testlaufprozess
  process
    variable v_instr : memory := (others => (others => '0'));
  begin
    -- === Test 1: LUI ===
    report "== TEST 1: LUI ==";
    test <= 1;
    s_rst <= '1';
    wait for PERIOD;
    s_rst <= '0';
    load_common_instructions(v_instr, test);
    s_instructions <= v_instr;
    for i in 1 to 100 loop
      wait until rising_edge(s_clk);
      cycle <= i;
    end loop;
    report "==   PASSED   ==";
    -- === Test 2: AUIPC ===
    report "== TEST 2: AUIPC ==";
    test <= 2;
    s_rst <= '1';
    wait for PERIOD/2;
    s_rst <= '0';
    wait for PERIOD/2;
    load_common_instructions(v_instr, test);
    s_instructions <= v_instr;

    for i in 1 to 100 loop
      wait until rising_edge(s_clk);
      cycle <= i;
    end loop;
    report "==   PASSED   ==";
    -- === Test 3: JAL ===
    report "== TEST 3: JAL ==";
    test <= 3;
    s_rst <= '1';
    wait for PERIOD/2;
    s_rst <= '0';
    wait for PERIOD/2;
    load_common_instructions(v_instr, test);
    s_instructions <= v_instr;

    for i in 1 to 100 loop
      wait until rising_edge(s_clk);
      cycle <= i;
    end loop;
    report "==   PASSED   ==";
    -- === Test 4: JALR ===
    report "== TEST 4: JALR ==";
    test <= 4;
    s_rst <= '1';
    wait for PERIOD/2;
    s_rst <= '0';
    wait for PERIOD/2;
    load_common_instructions(v_instr, test);
    s_instructions <= v_instr;

    for i in 1 to 100 loop
      wait until rising_edge(s_clk);
      cycle <= i;
    end loop;
    report "==   PASSED   ==";
    -- === Test 5: Branches ===
    report "== TEST 5: BRANCHES without FLUSH==";
    test <= 5;
    s_rst <= '1';
    wait for PERIOD/2;
    s_rst <= '0';
    wait for PERIOD/2;
    load_common_instructions(v_instr, test);
    s_instructions <= v_instr;

    for i in 1 to 150 loop
      wait until rising_edge(s_clk);
      cycle <= i;
    end loop;
    report "==   PASSED   ==";
    -- === Test 6: Branches ===
    if WITH_FLUSH then
      report "== TEST 5: BRANCHES with FLUSH==";
      test <= 6;
      s_rst <= '1';
      wait for PERIOD/2;
      s_rst <= '0';
      wait for PERIOD/2;
      load_common_instructions(v_instr, test);
      s_instructions <= v_instr;

      for i in 1 to 150 loop
        wait until rising_edge(s_clk);
        cycle <= i;
      end loop;
      report "==   PASSED   ==";
    end if;
    -- === Test 7: JAL ===
    if WITH_FLUSH then
      report "== TEST 7: JUMPS with FLUSH==";
      test <= 7;
      s_rst <= '1';
      wait for PERIOD/2;
      s_rst <= '0';
      wait for PERIOD/2;
      load_common_instructions(v_instr, test);
      s_instructions <= v_instr;

      for i in 1 to 150 loop
        wait until rising_edge(s_clk);
        cycle <= i;
      end loop;
      report "==   PASSED   ==";
    end if;

    report "== TEST 8: Immediate Shifts==";
    test <= 8;
    s_rst <= '1';
    wait for PERIOD/2;
    s_rst <= '0';
    wait for PERIOD/2;
    load_common_instructions(v_instr, test);
    s_instructions <= v_instr;

    for i in 1 to 35 loop
      wait until rising_edge(s_clk);
      cycle <= i;
    end loop;
    report "==   PASSED   ==";

    -- === Test 9: LOAD/STORE ===
    report "== TEST 9: LOAD/STORE ==";
    test <= 9;
    s_rst <= '1';
    wait for PERIOD/2;
    s_rst <= '0';
    wait for PERIOD/2;
    load_common_instructions(v_instr, test);
    s_instructions <= v_instr;

    for i in 1 to 60 loop
      wait until rising_edge(s_clk);
      cycle <= i;
    end loop;
    report "==   PASSED   ==";

    if WITH_FLUSH then
      report "== ALLE TESTS INKL. FLUSH ABGESCHLOSSEN ==";
    else
      report "== ALLE TESTS OHNE FLUSH ABGESCHLOSSEN ==";
    end if;
    wait;
  end process;

  -- Prüfroutine (separat lassen für Klarheit)
  process (cycle)
  begin
    if test >= 1 and test <= 4 then
      -- Prüflogik für LUI
      case cycle is
        when 6 => check_register(9, 1, "ADDI");
        when 7 => check_register(8, 2, "ADDI");
        when 11 => check_register(9, 10, "OR");
        when 12 => check_register(17, 8, "ADD");
        when 13 => check_register(1, 11, "SUB");
        when 14 => check_register(-1, 12, "SUB");
        when 16 => check_register(25, 12, "ADD");
        when 17 => check_register(-1, 12, "SUB");
        when 18 => check_register(8, 1, "AND");
        when 19 => check_register(1, 12, "XOR");
        when 20 => check_register(8 * 2 ** 12, 13, "LUI");
        when 21 => check_register(29 * 2 ** 12, 13, "LUI");
        when others => null;
      end case;
    end if;
    if test >= 2 and test <= 4 then
      -- Prüflogik für AUIPC
      --REPORT "Register " & INTEGER'image(14) &
      --       " enthaelt " & INTEGER'image(to_integer(signed(s_registersOut(14)))) 
      --        ;
      case cycle is
        when 22 => check_register(4164, 14, "AUIPC");
        when 23 => check_register(4168, 14, "AUIPC");
        when others => null;
      end case;
    end if;
    if test = 3 then
      -- Prüflogik für JAL
      --REPORT "Register " & INTEGER'image(1) &
      --      " enthaelt " & INTEGER'image(to_integer(signed(s_registersOut(1))));
      case cycle is
        when 24 => check_register(80, 15, "JAL");
        when 28 => check_register(9, 1, "ADDI");
        when 29 => check_register(8, 2, "ADDI");
        when 30 => check_register(9, 10, "OR");
        when 31 => check_register(17, 8, "ADD");
        when 32 => check_register(1, 11, "SUB");
        when 36 => check_register(-1, 12, "SUB");
        when 38 => check_register(25, 12, "ADD");
        when 39 => check_register(-1, 12, "SUB");
        when 40 => check_register(8, 2, "AND");
        when 41 => check_register(1, 12, "XOR");
        when 42 => check_register(8 * 2 ** 12, 13, "LUI");
        when 43 => check_register(29 * 2 ** 12, 13, "LUI");
        when 44 => check_register(4164, 14, "AUIPC");
        when 45 => check_register(4168, 14, "AUIPC");
        when others => null;
      end case;
    end if;
    if test = 4 then
      -- Prüflogik für JALR
      --  REPORT "Register " & INTEGER'image(10) &
      --  " enthaelt " & INTEGER'image(to_integer(signed(s_registersOut(10))));
      case cycle is
        when 24 => check_register(80, 15, "JAL");
        when 28 => check_register(220, 15, "JALR");
        when 33 => check_register(8, 10, "OR");
        when 34 => check_register(16, 8, "ADD");
        when 35 => check_register(0, 11, "SUB");
        when 36 => check_register(0, 12, "SUB");
        when 37 => check_register(24, 12, "ADD");
        when 38 => check_register(0, 12, "SUB");
        when 39 => check_register(8, 1, "AND");
        when others => null;
      end case;
    end if;
    if test >= 5 and test <= 6 then
      -- Prüflogik für BRANCHES
      -- REPORT "Register " & INTEGER'image(1) &
      -- " enthaelt " & INTEGER'image(to_integer(signed(s_registersOut(1))));
      case cycle is
        when 6 => check_register(9, 1, "ADDI");
        when 7 => check_register(9, 2, "ADDI");
        when 12 => if (test = 6) then
          check_register(9, 1, "Flush (EX->MEM)");
      end if;
      when 13 => if (test = 6) then
      check_register(9, 1, "Flush (ID->EX)");
    end if;
    when 14 => if (test = 6) then
    check_register(9, 1, "Flush (IF->ID)");
  end if;
  when 15 => check_register(0, 1, "BEQ");
  when 22 => if (test = 6) then
  check_register(16, 1, "Flush");
end if;
when 25 => check_register(1, 1, "BNE");
when 32 => if (test = 6) then
check_register(6, 1, "Flush");
end if;
when 35 => check_register(2, 1, "BLT");
when 42 => if (test = 6) then
check_register(9, 1, "Flush");
end if;
when 45 => check_register(3, 1, "BGE");
when 52 => if (test = 6) then
check_register(11, 1, "Flush");
end if;
when 55 => check_register(4, 1, "BLTU");
when 62 => if (test = 6) then
check_register(15, 1, "Flush");
end if;
when 65 => check_register(5, 1, "BGEU");

when 66 => check_register(9, 1, "ADDI");
when 67 => check_register(8, 2, "ADDI");
when 72 => check_register(666, 1, "BEQ");
when 73 => check_register(0, 1, "BEQ");
when 80 => check_register(669, 1, "BNE");
when 81 => check_register(1, 1, "BNE");
when 82 => check_register(6, 1, "BNE");
when 88 => check_register(699, 1, "BLT");
when 89 => check_register(2, 1, "BLT");
when 90 => check_register(9, 1, "BLT");
when 96 => check_register(999, 1, "BGE");
when 97 => check_register(3, 1, "BGE");
when 98 => check_register(11, 1, "BGE");
when 104 => check_register(996, 1, "BLTU");
when 105 => check_register(4, 1, "BLTU");
when 106 => check_register(15, 1, "BLTU");
when 112 => check_register(966, 1, "BGEU");
when 113 => check_register(5, 1, "BGEU");
when 48 + 49 + 35 + 1 + 4 => if (test = 6) then
check_register(5, 1, "Flush");
end if;
when 48 + 49 + 35 + 1 + 5 => if (test = 6) then
check_register(5, 1, "Flush");
end if;
when 48 + 49 + 35 + 1 + 6 => if (test = 6) then
check_register(5, 1, "Flush");
end if;
when others => null;
end case;
end if;
if test = 7 then
  -- Prüflogik für JALR 
  case cycle is
    when 24 => check_register(8, 1, "FLUSH");
      check_register(80, 15, "JAL");
    when 25 => check_register(8, 1, "FLUSH");
    when 26 => check_register(8, 1, "FLUSH");
    when 28 => check_register(220, 15, "JALR");
    when 29 => check_register(8, 1, "FLUSH");
    when 30 => check_register(8, 1, "FLUSH");
    when 31 => check_register(8, 1, "FLUSH");
    when 33 => check_register(8, 10, "OR");
    when 34 => check_register(16, 8, "ADD");
    when 35 => check_register(0, 11, "SUB");
    when 36 => check_register(0, 12, "SUB");
    when 37 => check_register(24, 12, "ADD");
    when 38 => check_register(0, 12, "SUB");
    when 39 => check_register(8, 1, "AND");
    when others => null;
  end case;
end if;

if test = 8 then
  -- Prüflogik für shift
  -- REPORT "Register " & INTEGER'image(1) &
  -- " enthaelt " & INTEGER'image(to_integer(signed(s_registersOut(1))));

  case cycle is
    when 6 => check_register(42, 1, "ADDI");
    when 11 => check_register(84, 5, "SLLI");
    when 12 => check_register(672, 6, "SLLI");
    when 13 => check_register(21, 7, "SRLI");
    when 14 => check_register(2, 8, "SRLI");
    when 15 => check_register(21, 9, "SRAI");
    when 16 => check_register(2, 10, "SRAI");
    when 17 => check_register(-8, 1, "ADDI");
    when 20 => check_register(-4, 11, "SRAI");
    when others => null;
  end case;
end if;

if test = 9 then
  --     REPORT "Register " & INTEGER'image(7) &
  -- " enthaelt " & INTEGER'image(to_integer(signed(s_registersOut(7))));

  case cycle is
      -- Prüflogik für shift
    when 6 => check_register(100, 1, "ADDI (BaseAddr)");
    when 7 => check_register(42, 2, "ADDI (Value42)");
    when 8 => check_register(-1, 3, "ADDI (Value-1)");
    when 17 => check_register(42, 4, "LW (Load 42)");
    when 23 => check_register(-1, 5, "LB (Load -1 signed)");
    when 24 => check_register(255, 6, "LBU (Load 255 unsigned)");
    when 30 => check_register(-1, 7, "LH (Load -1 signed)");
    when 31 => check_register(65535, 8, "LHU (Load 65535 unsigned)");
    when others => null;
  end case;
end if;

end process;

end architecture;