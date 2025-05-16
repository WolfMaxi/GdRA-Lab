-- Laboratory RA solutions/versuch2
-- Sommersemester 25
-- Group Details
-- Lab Date: 06.05.25
-- 1. Participant First and  Last Name: Maximilian Wolf
-- 2. Participant First and Last Name: Esad-Muhammed Cekmeci

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.constant_package.all;
use work.types.all;

entity register_file is
    generic (
        word_width : integer := WORD_WIDTH;
        adr_width : integer := REG_ADR_WIDTH
    );
    port (
        pi_clk, pi_rst : in std_logic := '0';
        pi_readRegAddr1 : in std_logic_vector(adr_width - 1 downto 0) := (others => '0');
        pi_readRegAddr2 : in std_logic_vector(adr_width - 1 downto 0) := (others => '0');
        pi_writeRegAddr : in std_logic_vector(adr_width - 1 downto 0) := (others => '0');
        pi_writeRegData : in std_logic_vector(word_width - 1 downto 0) := (others => '0');
        pi_writeEnable : in std_logic := '0';
        po_readRegData1 : out std_logic_vector(word_width - 1 downto 0) := (others => '0');
        po_readRegData2 : out std_logic_vector(word_width - 1 downto 0) := (others => '0');
        po_registerOut : out registermemory := (
            0 => (others => '0'),
            1 => std_logic_vector(to_unsigned(9, word_width)),
            2 => std_logic_vector(to_unsigned(8, word_width)),
            others => (others => '0')
        )
    );
end entity register_file;

architecture behavior of register_file is
    signal s_array : registermemory := (others => (others => '0')); --0te register wird beim start auf 0 gesetzt                 
begin
    process
    begin
        s_array <= (
            0 => (others => '0'),
            1 => std_logic_vector(to_unsigned(9, word_width)),
            2 => std_logic_vector(to_unsigned(8, word_width)),
            others => (others => '0')
        );
        wait for 5 ns;
        report "Inhalt von Register x01: "& INTEGER'image(to_integer(unsigned(s_array(1))));
        report "Inhalt von Register x02: "& INTEGER'image(to_integer(unsigned(s_array(2))));
        wait;
    end process;
    process (pi_clk)
    begin
        if pi_rst = '1' then -- Reset signal
            s_array <= (
                0 => (others => '0'),
                1 => std_logic_vector(to_unsigned(9, word_width)),
                2 => std_logic_vector(to_unsigned(8, word_width)),
                others => (others => '0')
            );
            po_readRegData1 <= (others => '0');
            po_readRegData2 <= (others => '0');
        elsif rising_edge(pi_clk) then --Lesen und Schreiben bei steigender Flanke
            po_readRegData1 <= s_array(to_integer(unsigned(pi_readRegAddr1)));
            po_readRegData2 <= s_array(to_integer(unsigned(pi_readRegAddr2)));
            if pi_writeEnable = '1' and to_integer(unsigned(pi_writeRegAddr)) /= 0 then --Schreib nur wenn pi_writeEnable = 1 und pi_writeRegAddr != 0
                s_array(to_integer(unsigned(pi_writeRegAddr))) <= pi_writeRegData;
            end if;
        end if;
        po_registerOut <= s_array;
    end process;
end architecture behavior;