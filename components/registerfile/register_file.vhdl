-- Laboratory RA solutions/versuch2
-- Sommersemester 25
-- Group Details
-- Lab Date:
-- 1. Participant First and Last Name: 
-- 2. Participant First and Last Name:

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.math_real.all;
  use work.constant_package.all;
  use work.types_package.all;

entity register_file is
    generic(
        word_width  : integer := WORD_WIDTH;
        adr_width   : integer := REG_ADR_WIDTH;
        reg_amount  : integer := 2**REG_ADR_WIDTH
    );
    port(
        pi_clk, pi_rst  : in STD_LOGIC;
        pi_readRegAddr1 : in std_logic_vector(adr_width-1 downto 0);
        pi_readRegAddr2 : in std_logic_vector(adr_width-1 downto 0);
        pi_writeRegAddr : in std_logic_vector(adr_width-1 downto 0);
        pi_writeRegData : in std_logic_vector(word_width-1 downto 0);
        pi_writeEnable  : in std_logic;
        po_readRegData1 : out std_logic_vector(word_width-1 downto 0);
        po_readRegData2 : out std_logic_vector(word_width-1 downto 0)
    );  
end entity register_file;

architecture behavior of register_file is
--type reg_array is array (0 to reg_amount-1) of std_logic_vector(word_width-1 downto 0);
signal s_array : registermemory := (others => (others => '0'));

begin
    process(pi_clk, pi_rst)
    begin
        if pi_rst = '1' then
            s_array <= (others =>(others => '0'));
            po_readRegData1 <= (others => '0'); 
        po_readRegData2 <= (others => '0');
    elsif rising_edge(pi_clk) then
        if (pi_writeEnable = '1' and to_integer(unsigned(pi_writeRegAddr)) /= 0) then
            s_array(to_integer(unsigned(pi_writeRegAddr))) <= pi_writeRegData;
        end if;
        po_readRegData1 <= s_array(to_integer(unsigned(pi_readRegAddr1)));
        po_readRegData2 <= s_array(to_integer(unsigned(pi_readRegAddr2)));
        end if;
    end process;
end architecture behavior;