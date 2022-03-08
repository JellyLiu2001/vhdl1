
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY recog2 IS
PORT(
  X: in BIT;
  CLK: in BIT;
  RESET: in BIT;
  Y: out BIT);
end;



ARCHITECTURE myArch OF recog2 IS

  TYPE state_type IS (INIT, FIRST, SECOND, THIRD);  
  SIGNAL curState, nextState: state_type;
  SIGNAL enable0, reset0, enable1, reset1: bit;
  SIGNAL count0, count1: integer;

BEGIN
------------------------------------------------------------------
  counter0: PROCESS(CLK,enable0,count0)         --counter0
    VARIABLE Vcount0: integer := 0;
  BEGIN
    IF rising_edge(CLK) THEN
      IF enable0 = '1' THEN
          Vcount0 := Vcount0 + 1;
      END IF;
    ELSIF reset0 = '1' THEN
      Vcount0 := 0;
    END IF;
  count0 <= Vcount0;
  END PROCESS;


--------------------------------------------------------------------
  counter1: PROCESS(CLK,enable1,count1)         --counter1
    VARIABLE Vcount1: integer := 0;
  BEGIN
    IF rising_edge(CLK) THEN
      IF enable1 = '1' THEN
          Vcount1 := Vcount1 + 1;
      END IF;
    ELSIF reset1 = '1' THEN
      Vcount1 := 0;
    END IF;
  count1 <= Vcount1;
  END PROCESS;


-------------------------------------------------------------------------
  combi_nextState: PROCESS(curState, X, count0, count1)       --combinational part
  BEGIN
    CASE curState is 

    WHEN INIT =>
      IF X = '1' THEN
        nextState <= INIT;
      ELSE
        nextState <= FIRST;
      END IF;

    WHEN FIRST =>
      IF X = '1' THEN
        IF count0 < 14 THEN
          nextState <= INIT;
        ELSE
          nextState <= SECOND;
        END IF;
      ELSIF X = '0' THEN
        nextState <= FIRST;
      END IF;

    WHEN SECOND =>
      IF X = '1' THEN
        IF count1 < 16 THEN
          nextState <= SECOND;
        ELSE
          nextState <= THIRD;
        END IF;      
      ELSE
        IF count1 < 16 THEN
          nextState <= FIRST;
        ELSE
          nextState <= THIRD;
        END IF;
      END IF;

    WHEN THIRD =>
      IF X = '1' THEN
        nextState <= INIT;
      ELSE
        nextState <= FIRST;
      END IF;

    END CASE;
  END PROCESS;


--------------------------------------------------------------------
  State_signal: PROCESS(curState, enable0, reset0, enable1, reset1)           --This is to declare counter's signals in each state
  BEGIN
    CASE curState is
    
    WHEN INIT => 
      enable0 <= '0';
      enable1 <= '0';
      reset0 <= '1';
      reset1 <= '1';    --reset two counters

    WHEN FIRST =>
      enable0 <= '1';   --activate counter0
      enable1 <= '0';
      reset0 <= '0';
      reset1 <= '0';

    WHEN SECOND =>
      enable0 <= '0';   
      enable1 <= '1';   --activate counter1
      reset0 <= '1';    --The reason to reset counter0 here is to solve the case that if counting '0' 
                       --in second state, counter0 would generate the correct value of count0 when back to first state.
      reset1 <= '0';

    WHEN THIRD =>
      enable0 <= '0';
      enable1 <= '0';
      reset0 <= '1';
      reset1 <= '1';

    END CASE;
  END PROCESS;

---------------------------------------------------------------------------
  combi_out: PROCESS(curState)
  BEGIN
    Y <= '0'; 
    IF curState = THIRD THEN
      Y <= '1';
    END IF;
  END PROCESS;


-----------------------------------------------------------------------------
  seq_state: PROCESS (CLK, RESET)
  BEGIN
    IF RESET = '0' THEN
      curState <= INIT;
    ELSIF CLK'EVENT AND CLK='1' THEN  
      curState <= nextState;
    END IF;
  END PROCESS; -- seq

------------------------------------------------------------------------------
END;