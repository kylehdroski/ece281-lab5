----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/18/2025 02:50:18 PM
-- Design Name: 
-- Module Name: ALU - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ALU is
    Port ( i_A : in STD_LOGIC_VECTOR (7 downto 0);
           i_B : in STD_LOGIC_VECTOR (7 downto 0);
           i_op : in STD_LOGIC_VECTOR (2 downto 0);
           o_result : out STD_LOGIC_VECTOR (7 downto 0);
           o_flags : out STD_LOGIC_VECTOR (3 downto 0));
end ALU;

architecture Behavioral of ALU is
    signal w_result : STD_LOGIC_VECTOR (7 downto 0);
    signal w_sum : STD_LOGIC_VECTOR (8 downto 0);
begin

    process(i_A, i_B, i_op)
        variable v_sum : STD_LOGIC_VECTOR (8 downto 0);
    begin
        case i_op is
            when "000" =>
                v_sum := std_logic_vector(('0' & unsigned(i_A)) + ('0' & unsigned(i_B)));
                w_sum <= v_sum;
                w_result <= v_sum(7 downto 0);
            when "001" =>
                v_sum := std_logic_vector(('0' & unsigned(i_A)) - ('0' & unsigned(i_B)));
                w_sum <= v_sum;
                w_result <= v_sum(7 downto 0);
            when "010" =>
                w_result <= i_A and i_B;
                w_sum <= (others => '0');
            when "011" =>
                w_result <= i_A or i_B;
                w_sum <= (others => '0');
            when others =>
                w_result <= (others => '0');
                w_sum <= (others => '0');
          end case;
     end process;
     
     o_result <= w_result;
     
     o_flags(3) <= w_result(7);
     o_flags(2) <= '1' when w_result = "00000000" else '0';
     o_flags(1) <= w_sum(8) when i_op = "000" else not w_sum(8) when i_op = "001" else '0';
     o_flags(0) <= (not i_op(0) and (not i_A(7) and not i_B(7) and w_result(7))) or (not i_op(0) and (i_A(7) and i_B(7) and not w_result(7))) or
                   (i_op(0) and not i_A(7) and i_B(7) and w_result(7)) or (i_op(0) and i_A(7) and not i_B(7) and not w_result(7));
            

end Behavioral;
