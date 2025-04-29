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

entity gen_mux_tb is
end gen_mux_tb;

architecture behavior of gen_mux_tb is
    signal si_sel: STD_LOGIC := '0';
    signal si_data5_first, si_data5_second, so_data5: STD_LOGIC_VECTOR(4 downto 0) := (others => '0') ;
    signal si_data6_first, si_data6_second, so_data6: STD_LOGIC_VECTOR(5 downto 0) := (others => '0');
    signal si_data8_first, si_data8_second, so_data8: STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal si_data16_first, si_data16_second, so_data16: STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal si_data32_first, si_data32_second, so_data32: STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

    signal s_expected5_first: STD_LOGIC_VECTOR(4 downto 0) := "11001";
    signal s_expected6_first: STD_LOGIC_VECTOR(5 downto 0) := "110010";
    signal s_expected8_first: STD_LOGIC_VECTOR(7 downto 0) := "11001100";
    signal s_expected16_first: STD_LOGIC_VECTOR(15 downto 0) := "1011101010100110";
    signal s_expected32_first: STD_LOGIC_VECTOR(31 downto 0) := "10100101000101101011011010100110";

    signal s_expected5_second: STD_LOGIC_VECTOR(4 downto 0) := "01101";
    signal s_expected6_second: STD_LOGIC_VECTOR(5 downto 0) := "011001";
    signal s_expected8_second: STD_LOGIC_VECTOR(7 downto 0) := "10110110";
    signal s_expected16_second: STD_LOGIC_VECTOR(15 downto 0) := "0101101011010110";
    signal s_expected32_second: STD_LOGIC_VECTOR(31 downto 0) := "00010100101011100000101010000100";

    constant period: time := 20 ns;
begin
    DUT5: entity work.gen_mux generic map (5) port map(si_data5_first, si_data5_second, si_sel, so_data5);
    DUT6: entity work.gen_mux generic map (6) port map(si_data6_first, si_data6_second, si_sel, so_data6);
    DUT8: entity work.gen_mux generic map (8) port map(si_data8_first, si_data8_second, si_sel, so_data8);
    DUT16: entity work.gen_mux generic map (16) port map(si_data16_first, si_data16_second, si_sel, so_data16);
    DUT31: entity work.gen_mux generic map (32) port map(si_data32_first, si_data32_second, si_sel, so_data32);

    -- Testbench
    reg : process is
    begin
        -- Set first input signals
        si_data5_first <= s_expected5_first;
        si_data6_first <= s_expected6_first;
        si_data8_first <= s_expected8_first;
        si_data16_first <= s_expected16_first;
        si_data32_first <= s_expected32_first;

        -- Set select
        si_sel <= '0';
        wait for period;

        assert (so_data5 = s_expected5_first) report "Error in First Input 5";
        assert (so_data6 = s_expected6_first) report "Error in First Input 6";
        assert (so_data8 = s_expected8_first) report "Error in First Input 8";
        assert (so_data16 = s_expected16_first) report "Error in First Input 16";
        assert (so_data32 = s_expected32_first) report "Error in First Input 32";

        -- Set second input signals
        si_data5_second <= s_expected5_second;
        si_data6_second <= s_expected6_second;
        si_data8_second <= s_expected8_second;
        si_data16_second <= s_expected16_second;
        si_data32_second <= s_expected32_second;

        -- Set select
        si_sel <= '1';
        wait for period;

        assert (so_data5 = s_expected5_second) report "Error in Second Input 5";
        assert (so_data6 = s_expected6_second) report "Error in Second Input 6";
        assert (so_data8 = s_expected8_second) report "Error in Second Input 8";
        assert (so_data16 = s_expected16_second) report "Error in Second Input 16";
        assert (so_data32 = s_expected32_second) report "Error in Second Input 32";

        wait;
    end process;
end behavior;
