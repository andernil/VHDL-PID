----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10.12.2017 11:16:41
-- Design Name: 
-- Module Name: main - Behavioral
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

library work;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity main is
    GENERIC (RES: NATURAL := 8); 
    port(
        sample_rate: in integer;
        ref,measurement: in integer range 0 to 2**RES-1;
        KP_param, KI_param, KD_param: IN INTEGER RANGE 0 to 2**RES-1;
        output: out integer range 0 to 2**RES-1;
        clk: in std_logic
        );
end main;

architecture Behavioral of main is
    signal error: integer range 0 to 2**RES-1 := 1;
begin
    process(clk) begin
        if (clk'event AND clk='1') then
            error <= ref-measurement; 
        end if;
    end process;

PID_controller: entity work.PID_CONTROLLER port map(
    clk => clk,
    sample_rate => sample_rate,
    KP_param => KP_param,
    KI_param => KI_param,
    KD_param => KD_param,
    error => error,
    correction => output);
end Behavioral;
