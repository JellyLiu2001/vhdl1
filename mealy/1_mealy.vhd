 -- Mealy Machine (mealy.vhd)
-- Asynchronous reset, active low
------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;--library for std_ulogic

ENTITY recog1 IS--Create an entity called recog1. 
PORT(--Define four ports by STD_ULOGIC
  x: in STD_ULOGIC;
  clk: in STD_ULOGIC;
  reset: in STD_ULOGIC;
  y: out STD_ULOGIC);
end;

ARCHITECTURE arch_mealy OF recog1 IS
  -- State declaration
  TYPE state_type IS (INIT, FIRST, SECOND, THIRD);  -- list four states by fsm
  SIGNAL curState, nextState: state_type;
BEGIN
  -----------------------------------------------------

  combi_nextState: PROCESS(curState, x)
  BEGIN
    CASE curState IS-- by fsm diagram

      WHEN INIT =>--if x=0 then maintain in s0
        IF x='0' THEN 
          nextState <= INIT;
        ELSIF x='1' THEN -- if x=1 then go to next state.
           nextState <= FIRST;
        END IF;
        

      WHEN FIRST =>
        IF x='0' THEN
          nextState <= SECOND;
        ELSIF x='1'THEN
	  nextState <= FIRST;
        END IF;


      WHEN SECOND =>
        IF x='0' THEN
          nextState <= INIT;
        ELSIF x='1' THEN
	   nextState <= THIRD;
        END IF;


      WHEN THIRD =>
        IF x='0' THEN
          nextState <= INIT;
        ELSIF x='1' THEN
	  nextState <= FIRST;
        END IF;
    END CASE;

  END PROCESS; -- combi_nextState

  -----------------------------------------------------

  combi_out: PROCESS(curState, x)
  BEGIN
    y <= '0'; -- assign default value
    IF curState = THIRD AND x='1' THEN-- if the program in s3 and x=1
      y <= '1';--the program will restart
    END IF;
  END PROCESS; -- combi_output

  -----------------------------------------------------

  seq_state: PROCESS (clk, reset)
  BEGIN
    IF reset = '0' THEN--define the reset function
      curState <= INIT;
    ELSIF clk'EVENT AND clk='1' THEN
      curState <= nextState;--change the state 
    END IF;
  END PROCESS; -- seq

  -----------------------------------------------------

END; -- arch_mealy
