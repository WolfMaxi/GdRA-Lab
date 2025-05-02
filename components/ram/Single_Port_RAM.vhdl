library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.constant_package.all;
use work.types_package.all;

entity Single_Port_RAM is
    generic (
        dataWidth: integer := WORD_WIDTH;
        addrWidth: integer := ADR_WIDTH
    );
    port (
        pi_clk, pi_rst, pi_we: in STD_LOGIC := '0';
        pi_addr: in STD_LOGIC_VECTOR(addrWidth - 1 downto 0) := (others => '0');
        pi_data: in STD_LOGIC_VECTOR(dataWidth - 1 downto 0) := (others => '0');
        po_data: out STD_LOGIC_VECTOR(dataWidth - 1 downto 0) := (others => '0')
    );
end entity Single_Port_RAM;

architecture behavior of Single_Port_RAM is
    signal regs: memory := (others => (others => '0'));
begin
    process(pi_clk, pi_rst)
    begin
        if pi_rst then
            -- Reset all words
            regs <= (others => (others => '0'));
            po_data <= (others => '0'); 
        elsif rising_edge(pi_clk) then
            -- Set output to value of current address
            po_data <= regs(to_integer(unsigned(pi_addr)));
            if pi_we then
                regs(to_integer(unsigned(pi_addr))) <= pi_data;
            end if;
        end if;
    end process;
end behavior;