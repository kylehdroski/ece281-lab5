----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/18/2025 02:42:49 PM
-- Design Name: 
-- Module Name: controller_fsm - FSM
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity controller_fsm is
    Port ( i_reset : in STD_LOGIC;
           i_adv : in STD_LOGIC;
           i_clk : in STD_LOGIC;
           o_cycle : out STD_LOGIC_VECTOR (3 downto 0));
end controller_fsm;

architecture FSM of controller_fsm is
    type sm_cpu is (s_CLEAR, s_OP1, s_OP2, s_MATH);
    signal f_state : sm_cpu;
begin
    state_proc : process(i_clk)
    begin 
        if rising_edge(i_clk) then
            if i_reset = '1' then
                f_state <= s_CLEAR;
        else
            case f_state is
                when s_CLEAR =>
                    if i_adv = '1' then
                        f_state <= s_OP1;
                    else
                        f_state <= s_CLEAR;
                    end if;
                 when s_OP1 =>
                    if i_adv = '1' then
                        f_state <= s_OP2;
                    else 
                        f_state <= s_OP1;
                    end if;
                 when s_OP2 => 
                    if i_adv = '1' then
                        f_state <= s_MATH;
                    else
                        f_state <= s_OP2;
                    end if;
                 when s_MATH =>
                    if i_adv = '1' then
                        f_state <= s_CLEAR;
                    else
                        f_state <= s_MATH;
                    end if;
                 when others =>
                     f_state <= s_CLEAR;
               end case;
           end if;
        end if;
     end process;
     
     output_proc : process(f_state)
     begin
        case f_state is
            when s_CLEAR => o_cycle <= "0001";
            when s_OP1 => o_cycle <= "0010";
            when s_OP2 => o_cycle <= "0100";
            when s_MATH => o_cycle <= "1000";
            when others => o_cycle <= "0001";
         end case;
     end process;

end FSM;
