library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.constant_package.all;

entity my_comparator is
    generic (
        G_DATA_WIDTH: integer := DATA_WIDTH_GEN
    );
    port (
        pi_op1, pi_op2: in std_logic_vector(G_DATA_WIDTH - 1 downto 0) := (others => '0');
        pi_isSigned: in std_logic := '0';
        po_out: out std_logic_vector(G_DATA_WIDTH - 1 downto 0) := (others => '0')
    );
end entity;

architecture behavior of my_comparator is
begin
    process (pi_op1, pi_op2, pi_isSigned)
    begin
        if (pi_isSigned) then 
            po_out <= std_logic_vector(to_unsigned(1, G_DATA_WIDTH)) when signed(pi_op1) < signed(pi_op2) else std_logic_vector(to_unsigned(0, G_DATA_WIDTH));
        else
            po_out <= std_logic_vector(to_unsigned(1, G_DATA_WIDTH)) when unsigned(pi_op1) < unsigned(pi_op2) else std_logic_vector(to_unsigned(0, G_DATA_WIDTH));
        end if;
    end process;
end behavior;