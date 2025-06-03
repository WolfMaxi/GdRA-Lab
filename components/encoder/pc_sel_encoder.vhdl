library ieee;
use ieee.std_logic_1164.all;

use work.constant_package.all;
use work.types.all;

entity pc_sel_encoder is
    port (
        pi_controlWord: in controlWord := control_word_init;
        pi_zero: in std_logic := '0';
        po_pc_sel: out std_logic_vector(1 downto 0) := (others => '0')
    );
end entity;

architecture behavior of pc_sel_encoder is
begin
    process (pi_controlWord, pi_zero)
        variable branch: std_logic := '0';
    begin
        branch := pi_controlWord.IS_BRANCH and (pi_zero xor pi_controlWord.CMP_RESULT);
        if pi_controlWord.PC_SEL then
            po_pc_sel <= "01"; -- Jump
        elsif pi_controlWord.IS_BRANCH then
            if branch = '1' then
                po_pc_sel <= "10"; -- Branch taken
            else
                po_pc_sel <= "00"; -- Branch not taken
            end if;
        else
            po_pc_sel <= "00"; -- PC+4
        end if;
    end process;
end architecture;
