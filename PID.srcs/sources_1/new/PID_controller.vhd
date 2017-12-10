LIBRARY work;
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--PID-controller discretized using Tustin's method (trapezoidal rule) where s = (Ts/2)*((z-1)/(z+1)).
--The resolution (in bits) can be adjusted by increasing/decreasing RES.
--The number of decimals in the input parameters (Kp, Ki and Kd) can be adjusted by increasing/decreasing DEC.

ENTITY PID_CONTROLLER IS
      GENERIC (DEC: NATURAL := 2;          --Define the number of decimal numbers for the control parameters,
               RES: NATURAL := 8);
      PORT (clk: IN STD_LOGIC;              --assuming that the input is a decimal number (i.e. Kp=3.51).
            sample_rate: IN INTEGER;        --Input the sample rate, the same as the clock frequency.
            ref, measure: in integer range 0 to 2**RES-1 := 1;      --Get the error (e=r-y).
            KP_param, KI_param, KD_param: in integer range 0 to 2**RES-1 := 1;   --Input for the PID-parameters
            correction: OUT INTEGER range 0 to 2**RES-1 := 1);                   --Outputs the correction calculated
END ENTITY;                                                                

ARCHITECTURE PID_INTERNALS OF PID_CONTROLLER IS
    type states is (param_calc,
                    error_calc,
                    curr_calc,
                    prev_calc,
                    prev_prev_calc,
                    PID_calc,
                    control,
                    output);
    signal state,next_state : states := error_calc;
    SIGNAL Kp, Ki, Kd, Ts, e: INTEGER range 0 to 2**RES-1 := 1;
    signal error: INTEGER range 0 to 2**RES-1 := 1;
    SIGNAL temp_correction: INTEGER range 0 to (2**RES-1)*10**(DEC+DEC) := 1;                    --Temporary correction variable
    SIGNAL correction_prev, correction_prev_prev: INTEGER range 0 to (2**RES-1)*10**(DEC+DEC) := 0;    --Previous correction values
    SIGNAL error_prev, error_prev_prev: INTEGER range 0 to 2**RES-1 := 0;              --Previous error values
    SIGNAL curr_sum, prev_sum, prev_prev_sum: INTEGER range 0 to (2**RES-1)*10**(DEC+DEC) := 1;        --Sum of the current and previous
BEGIN                                                                                       --sum-parts of the correction calculation.
    PROCESS(clk, state)
    BEGIN  
        IF(clk'event AND clk ='1') THEN                         --Write the calculated correction to the output at each positive clock edge.
            state <= next_state;
        end if;        
        case state is
                when error_calc =>
                    error <= ref - measure;
                    next_state <= param_calc;
                    
                when param_calc =>
                    Kp <= KP_param*10**DEC;             --Scale all input parameters by the number of decimals
                    Ki <= KI_param*10**DEC;
                    Kd <= KD_param*10**DEC;
                    Ts <= sample_rate*10**DEC;
                    e <= error*10**DEC;
                    next_state <= curr_calc;
                
                when curr_calc =>
                    curr_sum <= (((2*Kp*Ts)+(Ki*Ts**2)+(4*Kd))*e)/(2*Ts);  --Calculate the correction based on the current error.
                    if curr_sum < 0 then
                        curr_sum <= 0;
                    end if;
                    next_state <= prev_calc;
                
                when prev_calc =>
                    prev_sum <= (((2*Ki*Ts)-(8*Kd))*error_prev)/(2*Ts);    --Calculate the correction based on the previous error. 
                    next_state <= prev_prev_calc;
                
                when prev_prev_calc =>
                    prev_prev_sum <= ((((4*Kd)+(Ki*(Ts**2))-(2*Kp*Ts))*error_prev_prev) --Calculate the correciton based on the previous previous error
                    +(2*Ts*correction_prev_prev))/(2*Ts);           --and the correction from two cycles prior.
                    next_state <= PID_calc;
                
                when PID_calc => 
                    temp_correction <= (curr_sum + prev_sum + prev_prev_sum); --Sum the different parts and divide by 2*Ts.
                    next_state <= control;
                when control =>
                    if temp_correction > (2**RES-1)*10**(DEC+DEC) then
                        temp_correction <= (2**RES-1)*10**(DEC+DEC);
                    elsif temp_correction < 0 then
                        temp_correction <= 0;
                    end if;
                    next_state <= output;
                when output =>
                    correction <= temp_correction/(10**(DEC+DEC));
                    error_prev <= e;                                    --Store the error of this cycle for next cycle.
                    error_prev_prev <= error_prev;                      --Store the previous error for the next cycle.
                    correction_prev <= temp_correction;          --Store the calculated correction for the next cycle.
                    correction_prev_prev <= correction_prev;            --Store the previously calcualted correction.
                    next_state <= error_calc;
                end case;
    END PROCESS;
END ARCHITECTURE;