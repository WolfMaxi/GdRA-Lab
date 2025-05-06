-- Laboratory RA solutions/versuch2
-- Sommersemester 25
-- Group Details
-- Lab Date:06.05.25
-- 1. Participant First and  Last Name: Maximilian Wolf
-- 2. Participant First and Last Name: Esad-Muhammed Cekmeci

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.math_real.all;
  use work.constant_package.all;

entity register_file_tb is
end entity register_file_tb;

architecture behavior of register_file_tb is
    constant FIRST_INDEX: integer := 0;
    constant LAST_INDEX: integer := 2**REG_ADR_WIDTH - 1;

    signal s_clk, s_rst: STD_LOGIC := '0';

    signal si_readRegAddr1_16 : std_logic_vector(REG_ADR_WIDTH-1 downto 0)   := (others => '0');
    signal si_readRegAddr2_16 : std_logic_vector(REG_ADR_WIDTH-1 downto 0)   := (others => '0');
    signal si_writeRegAddr16 : std_logic_vector(REG_ADR_WIDTH-1 downto 0)   := (others => '0');
    signal si_writeRegData16 : std_logic_vector(15 downto 0)  := (others => '0');
    signal si_writeEnable16  : std_logic := '0';
    signal so_readRegData1_16 : std_logic_vector(15 downto 0);
    signal so_readRegData2_16 : std_logic_vector(15 downto 0);

    signal si_readRegAddr1_32 : std_logic_vector(REG_ADR_WIDTH-1 downto 0)   := (others => '0');
    signal si_readRegAddr2_32 : std_logic_vector(REG_ADR_WIDTH-1 downto 0)   := (others => '0');
    signal si_writeRegAddr32 : std_logic_vector(REG_ADR_WIDTH-1 downto 0)   := (others => '0');
    signal si_writeRegData32 : std_logic_vector(31 downto 0)  := (others => '0');
    signal si_writeEnable32  : std_logic := '0';
    signal so_readRegData1_32 : std_logic_vector(31 downto 0);
    signal so_readRegData2_32 : std_logic_vector(31 downto 0);

    signal s_expected1_16: std_logic_vector(15 downto 0) := "1011101010100110";
    --signal s_expected2_16: std_logic_vector(15 downto 0) := "1010010011001001";
    signal s_expected1_32: std_logic_vector(31 downto 0) := "10100101000101101011011010100110";
    --signal s_expected2_32: std_logic_vector(31 downto 0) := "11110101000101101011000000000110";


    signal s_rst16: STD_LOGIC_VECTOR(15 downto 0) := (others => '0'); --Für die übersichtlichkeit, an sich nicht nötig 
    signal s_rst32: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

    constant CLOCK_PERIOD : time := 10 ns;
    constant PERIOD: time := 20 ns;

begin 
    DUT16: entity work.register_file(behavior)
        generic map (
            word_width => 16,
            adr_width => REG_ADR_WIDTH
        )
        port map (
            pi_clk => s_clk,
            pi_rst => s_rst,
            pi_readRegAddr1 => si_readRegAddr1_16,
            pi_readRegAddr2 => si_readRegAddr2_16,
            pi_writeRegAddr => si_writeRegAddr16,
            pi_writeRegData => si_writeRegData16,
            pi_writeEnable => si_writeEnable16,
            po_readRegData1 => so_readRegData1_16,
            po_readRegData2 => so_readRegData2_16
        );

    DUT32: entity work.register_file(behavior)
        generic map (
            word_width => 32,
            adr_width => REG_ADR_WIDTH
        )
        port map (
            pi_clk => s_clk,
            pi_rst => s_rst,
            pi_readRegAddr1 => si_readRegAddr1_32,
            pi_readRegAddr2 => si_readRegAddr2_32,
            pi_writeRegAddr => si_writeRegAddr32,
            pi_writeRegData => si_writeRegData32,
            pi_writeEnable => si_writeEnable32,
            po_readRegData1 => so_readRegData1_32,
            po_readRegData2 => so_readRegData2_32
        );
    clock: process
    begin
        s_clk <= '0';
        wait for CLOCK_PERIOD / 2;
        s_clk <= '1';
        wait for CLOCK_PERIOD / 2;
    end process;

    stimulus: process is 
    begin 
        --Test der 16-Bits
        si_writeEnable16  <= '1';
        si_writeRegAddr16 <= std_logic_vector(to_unsigned(3, REG_ADR_WIDTH));
        si_writeRegData16 <= s_expected1_16;
        wait for PERIOD;  
        si_writeEnable16  <= '0'; 

        si_readRegAddr1_16 <= std_logic_vector(to_unsigned(3, REG_ADR_WIDTH));
        si_readRegAddr2_16 <= std_logic_vector(to_unsigned(4, REG_ADR_WIDTH));
        wait for PERIOD;
        assert so_readRegData1_16 = s_expected1_16
            report "Data1 Error with 16-Bit" severity error;
        assert so_readRegData2_16 = s_rst16
            report "Data2 Error with 16-Bit" severity error;

        --Test der 32-Bits
        si_writeEnable32  <= '1';
        si_writeRegAddr32 <= std_logic_vector(to_unsigned(5, REG_ADR_WIDTH));
        si_writeRegData32 <= s_expected1_32;
        wait for PERIOD;  
        si_writeEnable32  <= '0'; 

        si_readRegAddr1_32 <= std_logic_vector(to_unsigned(5, REG_ADR_WIDTH));
        si_readRegAddr2_32 <= std_logic_vector(to_unsigned(0, REG_ADR_WIDTH));
        wait for PERIOD;
        assert so_readRegData1_32 = s_expected1_32
            report "Data1 Error with 32-Bit" severity error;
        assert so_readRegData2_32 = s_rst32
            report "Data2 Error with 32-Bit" severity error;

        --Test ob das leztze register beschrieben wird
        si_writeEnable32  <= '1';
        si_writeRegAddr32 <= std_logic_vector(to_unsigned(LAST_INDEX, REG_ADR_WIDTH));
        si_writeRegData32 <= s_expected1_32;
        wait for PERIOD;
        si_writeEnable32  <= '0';

        si_readRegAddr1_32 <= std_logic_vector(to_unsigned(LAST_INDEX, REG_ADR_WIDTH));
        si_readRegAddr2_32 <= std_logic_vector(to_unsigned(LAST_INDEX, REG_ADR_WIDTH));
        wait for PERIOD;
        assert so_readRegData1_32 = s_expected1_32
            report "Data1 Error im letzten Register" severity error;
        assert so_readRegData2_32 = s_expected1_32
            report "Data2 Error im letzten Register" severity error;
        --Test ob das erste register beschrieben wird
        si_writeEnable32  <= '1';
        si_writeRegAddr32 <= std_logic_vector(to_unsigned(FIRST_INDEX, REG_ADR_WIDTH));
        si_writeRegData32 <= s_expected1_32;
        wait for PERIOD;
            
        --Test des Reset
        s_rst <= '1';
        wait for PERIOD;
        s_rst <= '0';
        wait for PERIOD;

        assert so_readRegData1_16 = s_rst16
            report "Reset1 Error for 16-Bit" severity error;
        assert so_readRegData2_16 = s_rst16
            report "Reset2 Error for 16-Bit" severity error;
       assert so_readRegData1_32 = s_rst32
            report "Reset1 Error for 32-Bit" severity error;
        assert so_readRegData2_32 = s_rst32
            report "Reset2 Error for 32-Bit" severity error;

        report "End of Test!!!" severity note;
        wait;  
    end process;
end architecture behavior;