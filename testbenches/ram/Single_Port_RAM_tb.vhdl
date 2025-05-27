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
use work.constant_package.all;

entity Single_Port_RAM_tb is
    generic (
        word_width : integer := WORD_WIDTH;
        adr_width : integer := REG_ADR_WIDTH
    );
end entity Single_Port_RAM_tb;

architecture behavior of Single_Port_RAM_tb is
    signal s_clk, s_rst, s_we : std_logic := '0';
    signal s_addr : std_logic_vector(adr_width - 1 downto 0);
    signal s_inData, s_outData, s_expected : std_logic_vector(word_width - 1 downto 0);

    constant CLOCK_PERIOD : time := 10 ns;
    constant PERIOD : time := 20 ns;

    constant LOWER_BOUND : integer := 0;
    constant UPPER_BOUND : integer := 2 ** adr_width - 1;
begin
    clock : process
    begin
        s_clk <= '0';
        wait for CLOCK_PERIOD / 2;
        s_clk <= '1';
        wait for CLOCK_PERIOD / 2;
    end process;

    DUT : entity work.Single_Port_RAM
        generic map(
            word_width => word_width,
            adr_width => adr_width
        )
        port map(
            pi_clk => s_clk,
            pi_rst => s_rst,
            pi_we => s_we,
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

        s_addr <= std_logic_vector(to_unsigned(LOWER_BOUND, adr_width));
        wait for PERIOD;

        s_addr <= std_logic_vector(to_unsigned(UPPER_BOUND, adr_width));
        wait for PERIOD;

        -- Read test
        s_we <= '0';
        s_expected <= (others => '1');

        s_addr <= std_logic_vector(to_unsigned(LOWER_BOUND, adr_width));
        wait for PERIOD;
        assert (s_outData = s_expected) report "Read Error in Register " & integer'image(LOWER_BOUND);

        s_addr <= std_logic_vector(to_unsigned(UPPER_BOUND, adr_width));
        wait for PERIOD;
        assert (s_outData = s_expected) report "Read Error in Register " & integer'image(UPPER_BOUND);

        -- Reset test
        s_rst <= '1';
        s_expected <= (others => '0');

        s_addr <= std_logic_vector(to_unsigned(LOWER_BOUND, adr_width));
        wait for PERIOD;
        assert (s_outData = s_expected) report "Reset Error in Register " & integer'image(LOWER_BOUND);

        s_addr <= std_logic_vector(to_unsigned(UPPER_BOUND, adr_width));
        wait for PERIOD;
        assert (s_outData = s_expected) report "Reset Error in Register " & integer'image(UPPER_BOUND);

        assert false report "End of RAM test" severity note;
        wait;
    end process;
end behavior;