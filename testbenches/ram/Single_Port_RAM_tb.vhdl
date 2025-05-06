-- Laboratory RA solutions/versuch2
-- Sommersemester 25
-- Group Details
-- Lab Date:06.05.25
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
use ieee.math_real.all;

entity Single_Port_RAM_tb is
    generic (
        word_width: integer := 32;
        adr_width: integer := 10  
    );
end entity Single_Port_RAM_tb;

architecture behavior of Single_Port_RAM_tb is
    signal s_clk, s_rst, s_we: STD_LOGIC := '0';
    signal s_addr: STD_LOGIC_VECTOR(adr_width - 1 downto 0);
    signal s_inData, s_outData, s_expected: STD_LOGIC_VECTOR(word_width - 1 downto 0);

    constant clock_period: time := 10 ns;
    constant period: time := 20 ns;

    constant lowerBound: INTEGER := 0;
    constant upperBound: INTEGER := 2 ** adr_width - 1;
begin
    clock: process
    begin
        s_clk <= '0';
        wait for clock_period / 2;
        s_clk <= '1';
        wait for clock_period / 2;
    end process;

    DUT: entity work.Single_Port_RAM
        generic map (
            word_width => word_width,
            adr_width => adr_width
        )
        port map (
            pi_clk  => s_clk,
            pi_rst  => s_rst,
            pi_we   => s_we,
            pi_addr => s_addr,
            pi_data => s_inData,
            po_data => s_outData
        );

    -- Testbench
    reg : process is
    begin
        -- Write test
        s_we <= '1';
        s_inData <= (others => '1');

        s_addr <= STD_LOGIC_VECTOR(to_unsigned(lowerBound, adr_width));
        wait for period;

        s_addr <= STD_LOGIC_VECTOR(to_unsigned(upperBound, adr_width));
        wait for period;
        
        -- Read test
        s_we <= '0';
        s_expected <= (others => '1');

        s_addr <= STD_LOGIC_VECTOR(to_unsigned(lowerBound, adr_width));
        wait for period;
        assert (s_outData = s_expected) report "Read Error in Register " & integer'image(lowerBound);

        s_addr <= STD_LOGIC_VECTOR(to_unsigned(upperBound, adr_width));
        wait for period;
        assert (s_outData = s_expected) report "Read Error in Register " & integer'image(upperBound);

        -- Reset test
        s_rst <= '1';
        s_expected <= (others => '0');

        s_addr <= STD_LOGIC_VECTOR(to_unsigned(lowerBound, adr_width));
        wait for period;
        assert (s_outData = s_expected) report "Reset Error in Register " & integer'image(lowerBound);

        s_addr <= STD_LOGIC_VECTOR(to_unsigned(upperBound, adr_width));
        wait for period;
        assert (s_outData = s_expected) report "Reset Error in Register " & integer'image(upperBound);

        assert false report "End of RAM test" severity note;
        wait;
    end process;
end behavior;
