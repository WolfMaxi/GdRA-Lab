-- Laboratory RA solutions/versuch71
-- Sommersemester 25
-- Group Details
-- Lab Date:
-- 1. Participant First and Last Name: 
-- 2. Participant First and Last Name:

-- ========================================================================
-- Author:       Marcel Rieß
-- Last updated: 23.05.2025
-- Description:  RIU-Only-RISC-V (incomplete RV32I implementation)
--               Supports only R-, I- and U-Instructions.
-- ========================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constant_package.all;
use work.types.all;
use work.util_asm_package.all;

entity riub_only_RISC_V_tb is
end entity;

architecture structure of riub_only_RISC_V_tb is

  constant PERIOD : time := 10 ns;
  constant WITH_FLUSH : std_logic := '1';
  signal s_clk : std_logic := '0';
  signal s_rst : std_logic;
  signal cycle : integer := 0;
  signal test : integer := 0;

  signal s_registersOut : registerMemory := (others => (others => '0'));
  signal s_instructions : memory := (others => (others => '0'));

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
  end procedure;

begin

  -- DUT
  riub_only_riscv : entity work.riub_only_RISC_V
    port map(
      pi_rst => s_rst,
      pi_clk => s_clk,
      pi_instruction => s_instructions,
      po_registersOut => s_registersOut
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
      if (cycle = 6) then
        check_register(9, 1, "ADDI");
      end if;
      if (cycle = 7) then
        check_register(8, 2, "ADDI");
      end if;
      if (cycle = 11) then
        check_register(9, 10, "OR");
      end if;
      if (cycle = 12) then
        check_register(17, 8, "ADD");
      end if;
      if (cycle = 13) then
        check_register(1, 11, "SUB");
      end if;
      if (cycle = 14) then
        check_register(-1, 12, "SUB");
      end if;
      if (cycle = 16) then
        check_register(25, 12, "ADD");
      end if;
      if (cycle = 17) then
        check_register(-1, 12, "SUB");
      end if;
      if (cycle = 18) then
        check_register(8, 1, "AND");
      end if;
      if (cycle = 19) then
        check_register(1, 12, "XOR");
      end if;
      if (cycle = 20) then
        check_register(8 * 2 ** 12, 13, "LUI");
      end if;
      if (cycle = 21) then
        check_register(29 * 2 ** 12, 13, "LUI");
      end if;
    end if;
    if test >= 2 and test <= 4 then
      -- Prüflogik für AUIPC
      --REPORT "Register " & INTEGER'image(14) &
      --       " enthaelt " & INTEGER'image(to_integer(signed(s_registersOut(14)))) 
      --        ;
      if (cycle = 22) then
        check_register(4164, 14, "AUIPC");
      end if;
      if (cycle = 23) then
        check_register(4168, 14, "AUIPC");
      end if;
    end if;
    if test = 3 then
      -- Prüflogik für JAL
      --REPORT "Register " & INTEGER'image(1) &
      --      " enthaelt " & INTEGER'image(to_integer(signed(s_registersOut(1))));

      if (cycle = 24) then
        check_register(80, 15, "JAL");
      end if;
      if (cycle = 28) then
        check_register(9, 1, "ADDI");
      end if;
      if (cycle = 29) then
        check_register(8, 2, "ADDI");
      end if;
      if (cycle = 30) then
        check_register(9, 10, "OR");
      end if;
      if (cycle = 31) then
        check_register(17, 8, "ADD");
      end if;
      if (cycle = 32) then
        check_register(1, 11, "SUB");
      end if;
      if (cycle = 36) then
        check_register(-1, 12, "SUB");
      end if;
      if (cycle = 38) then
        check_register(25, 12, "ADD");
      end if;
      if (cycle = 39) then
        check_register(-1, 12, "SUB");
      end if;
      if (cycle = 40) then
        check_register(8, 2, "AND");
      end if;
      if (cycle = 41) then
        check_register(1, 12, "XOR");
      end if;
      if (cycle = 42) then
        check_register(8 * 2 ** 12, 13, "LUI");
      end if;
      if (cycle = 43) then
        check_register(29 * 2 ** 12, 13, "LUI");
      end if;
      if (cycle = 44) then
        check_register(4164, 14, "AUIPC");
      end if;
      if (cycle = 45) then
        check_register(4168, 14, "AUIPC");
      end if;
    end if;
    if test = 4 then
      -- Prüflogik für JALR
      --  REPORT "Register " & INTEGER'image(10) &
      --  " enthaelt " & INTEGER'image(to_integer(signed(s_registersOut(10))));
      if (cycle = 24) then
        check_register(80, 15, "JAL");
      end if;
      if (cycle = 28) then
        check_register(220, 15, "JALR");
      end if;
      if (cycle = 33) then
        check_register(8, 10, "OR");
      end if;
      if (cycle = 34) then
        check_register(16, 8, "ADD");
      end if;
      if (cycle = 35) then
        check_register(0, 11, "SUB");
      end if;
      if (cycle = 36) then
        check_register(0, 12, "SUB");
      end if;
      if (cycle = 37) then
        check_register(24, 12, "ADD");
      end if;
      if (cycle = 38) then
        check_register(0, 12, "SUB");
      end if;
      if (cycle = 39) then
        check_register(8, 1, "AND");
      end if;
    end if;
    if test >= 5 and test <= 6 then
      -- Prüflogik für BRANCHES
      -- REPORT "Register " & INTEGER'image(1) &
      -- " enthaelt " & INTEGER'image(to_integer(signed(s_registersOut(1))));
      if (cycle = 6) then
        check_register(9, 1, "ADDI");
      end if;
      if (cycle = 7) then
        check_register(9, 2, "ADDI");
      end if;
      if (cycle = 12) and (test = 6) then
        check_register(9, 1, "Flush (EX->MEM)");
      end if;
      if (cycle = 13) and (test = 6) then
        check_register(9, 1, "Flush (ID->EX)");
      end if;
      if (cycle = 14) and (test = 6) then
        check_register(9, 1, "Flush (IF->ID)");
      end if;
      if (cycle = 15) then
        check_register(0, 1, "BEQ");
      end if;
      if (cycle = 22) and (test = 6) then
        check_register(16, 1, "Flush");
      end if;
      if (cycle = 25) then
        check_register(1, 1, "BNE");
      end if;
      if (cycle = 32) and (test = 6) then
        check_register(6, 1, "Flush");
      end if;
      if (cycle = 35) then
        check_register(2, 1, "BLT");
      end if;
      if (cycle = 42) and (test = 6) then
        check_register(9, 1, "Flush");
      end if;
      if (cycle = 45) then
        check_register(3, 1, "BGE");
      end if;
      if (cycle = 52) and (test = 6) then
        check_register(11, 1, "Flush");
      end if;
      if (cycle = 55) then
        check_register(4, 1, "BLTU");
      end if;
      if (cycle = 62) and (test = 6) then
        check_register(15, 1, "Flush");
      end if;
      if (cycle = 65) then
        check_register(5, 1, "BGEU");
      end if;

      if (cycle = 66) then
        check_register(9, 1, "ADDI");
      end if;
      if (cycle = 67) then
        check_register(8, 2, "ADDI");
      end if;
      if (cycle = 72) then
        check_register(666, 1, "BEQ");
      end if;
      if (cycle = 73) then
        check_register(0, 1, "BEQ");
      end if;
      if (cycle = 80) then
        check_register(669, 1, "BNE");
      end if;
      if (cycle = 81) then
        check_register(1, 1, "BNE");
      end if;
      if (cycle = 82) then
        check_register(6, 1, "BNE");
      end if;
      if (cycle = 88) then
        check_register(699, 1, "BLT");
      end if;
      if (cycle = 89) then
        check_register(2, 1, "BLT");
      end if;
      if (cycle = 90) then
        check_register(9, 1, "BLT");
      end if;
      if (cycle = 96) then
        check_register(999, 1, "BGE");
      end if;
      if (cycle = 97) then
        check_register(3, 1, "BGE");
      end if;
      if (cycle = 98) then
        check_register(11, 1, "BGE");
      end if;
      if (cycle = 104) then
        check_register(996, 1, "BLTU");
      end if;
      if (cycle = 105) then
        check_register(4, 1, "BLTU");
      end if;
      if (cycle = 106) then
        check_register(15, 1, "BLTU");
      end if;
      if (cycle = 112) then
        check_register(966, 1, "BGEU");
      end if;
      if (cycle = 113) then
        check_register(5, 1, "BGEU");
      end if;
      if (cycle = 48 + 49 + 35 + 1 + 4) and (test = 6) then
        check_register(5, 1, "Flush");
      end if;
      if (cycle = 48 + 49 + 35 + 1 + 5) and (test = 6) then
        check_register(5, 1, "Flush");
      end if;
      if (cycle = 48 + 49 + 35 + 1 + 6) and (test = 6) then
        check_register(5, 1, "Flush");
      end if;
    end if;
    if test = 7 then
      -- Prüflogik für JALR 
      if (cycle = 24) then
        check_register(80, 15, "JAL");
      end if;
      if (cycle = 24) then
        check_register(8, 1, "FLUSH");
      end if;
      if (cycle = 25) then
        check_register(8, 1, "FLUSH");
      end if;
      if (cycle = 26) then
        check_register(8, 1, "FLUSH");
      end if;
      if (cycle = 28) then
        check_register(220, 15, "JALR");
      end if;
      if (cycle = 29) then
        check_register(8, 1, "FLUSH");
      end if;
      if (cycle = 30) then
        check_register(8, 1, "FLUSH");
      end if;
      if (cycle = 31) then
        check_register(8, 1, "FLUSH");
      end if;
      if (cycle = 33) then
        check_register(8, 10, "OR");
      end if;
      if (cycle = 34) then
        check_register(16, 8, "ADD");
      end if;
      if (cycle = 35) then
        check_register(0, 11, "SUB");
      end if;
      if (cycle = 36) then
        check_register(0, 12, "SUB");
      end if;
      if (cycle = 37) then
        check_register(24, 12, "ADD");
      end if;
      if (cycle = 38) then
        check_register(0, 12, "SUB");
      end if;
      if (cycle = 39) then
        check_register(8, 1, "AND");
      end if;
    end if;
  end process;

end architecture;