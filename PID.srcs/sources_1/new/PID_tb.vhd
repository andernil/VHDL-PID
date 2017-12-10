LIBRARY work;
LIBRARY ieee;
USE ieee.std_logic_1164.all;

entity PID_tb is
end entity;

architecture testbench of PID_tb is
    signal sr_tb: INTEGER := 1000;
    signal ref_tb: INTEGER := 100;
    signal measurement_tb: INTEGER := 0;
    signal KP_tb, KI_tb, KD_tb: INTEGER := 1;
    signal out_tb: INTEGER;
    signal clk_tb: std_logic := '0';
begin
    CLKGEN : process is
    begin
        clk_tb <= '1';
        wait for 20 ms;
        clk_tb <= '0';
        wait for 20 ms;
    end process;
    sr_tb <= 10 after 80us;
    KP_tb <= 2 after 80us;
    KI_tb <= 2 after 80us;
    KD_tb <= 2 after 80us;
    measurement_tb <= 50 after 80us;
    ref_tb <=  0 after 1000ms;
    
    dut: entity work.PID_controller PORT MAP(
    sample_rate => sr_tb, 
    ref => ref_tb, 
    measure => measurement_tb, 
    KP_param => KP_tb, 
    KI_param => KI_tb, 
    KD_param => KD_tb, 
    correction => out_tb, 
    clk => clk_tb);
    
end architecture;
