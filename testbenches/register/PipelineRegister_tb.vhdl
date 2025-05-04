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

entity PipelineRegister_tb is
end PipelineRegister_tb;

architecture behavior of PipelineRegister_tb is
    signal s_clk, s_rst: STD_LOGIC := '0';
    signal si_data5, so_data5: STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
    signal si_data6, so_data6: STD_LOGIC_VECTOR(5 downto 0) := (others => '0');
    signal si_data8, so_data8: STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal si_data16, so_data16: STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal si_data32, so_data32: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

    signal s_expected5: STD_LOGIC_VECTOR(4 downto 0) := "11001";
    signal s_expected6: STD_LOGIC_VECTOR(5 downto 0) := "110010";
    signal s_expected8: STD_LOGIC_VECTOR(7 downto 0) := "11001100";
    signal s_expected16: STD_LOGIC_VECTOR(15 downto 0) := "1011101010100110";
    signal s_expected32: STD_LOGIC_VECTOR(31 downto 0) := "10100101000101101011011010100110";

    signal s_rst5: STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
    signal s_rst6: STD_LOGIC_VECTOR(5 downto 0) := (others => '0');
    signal s_rst8: STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal s_rst16: STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal s_rst32: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');


    constant clock_period: time := 10 ns;
    constant period: time := 20 ns;
begin
    DUT5: entity work.PipelineRegister generic map (5) port map(s_clk, s_rst, si_data5, so_data5);
    DUT6: entity work.PipelineRegister generic map (6) port map(s_clk, s_rst, si_data6, so_data6);
    DUT8: entity work.PipelineRegister generic map (8) port map(s_clk, s_rst, si_data8, so_data8);
    DUT16: entity work.PipelineRegister generic map (16) port map(s_clk, s_rst, si_data16, so_data16);
    DUT31: entity work.PipelineRegister generic map (32) port map(s_clk, s_rst, si_data32, so_data32);

    -- Clock
    clock: process
    begin
        s_clk <= '0';
        wait for clock_period / 2;
        s_clk <= '1';
        wait for clock_period / 2;
    end process;

    -- Testbench
    reg : process is
    begin
        -- Set input signals
        si_data5 <= s_expected5;
        si_data6 <= s_expected6;
        si_data8 <= s_expected8;
        si_data16 <= s_expected16;
        si_data32 <= s_expected32;

        wait for period;

        assert (so_data5 = s_expected5) report "Data Error in Register 5";
        assert (so_data6 = s_expected6) report "Data Error in Register 6";
        assert (so_data8 = s_expected8) report "Data Error in Register 8";
        assert (so_data16 = s_expected16) report "Data Error in Register 16";
        assert (so_data32 = s_expected32) report "Data Error in Register 32";

        --Set reset signal
        s_rst <= '1';

        wait for period;

        assert (so_data5 = s_rst5) report "Reset Error in Register 5";
        assert (so_data6 = s_rst6) report "Reset Error in Register 6";
        assert (so_data8 = s_rst8) report "Reset Error in Register 8";
        assert (so_data16 = s_rst16) report "Reset Error in Register 16";
        assert (so_data32 = s_rst32) report "Reset Error in Register 32";

        wait;
    end process;
end behavior;
