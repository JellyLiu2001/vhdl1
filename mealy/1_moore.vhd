LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY recog1 IS--Create an entity called moore. 
PORT(--Define four ports by STD_ULOGIC
  x: in STD_ULOGIC;
  clk: in STD_ULOGIC;
  reset: in STD_ULOGIC;
  y: out STD_ULOGIC);
end;

ARCHITECTURE arch_moore OF recog1 IS
  -- State declaration
  TYPE state_type IS (INIT, FIRST, SECOND, THIRD, FORTH);  -- List your states here 	
  SIGNAL curState, nextState: state_type;
BEGIN
  -----------------------------------------------------
  combi_nextState: PROCESS(curState, x)
  BEGIN
    CASE curState IS-- by fsm diagram

      WHEN INIT =>--if x=0 then maintain in s0
        IF x='0' THEN 
          nextState <= INIT;
        ELSIF x='1' THEN-- if x=1 then go to next state.
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
          nextState <= FORTH;
        ELSIF x='1' THEN
	  nextState <= FIRST;
        END IF;

	WHEN FORTH=>
	 IF x='0' THEN
	   nextState<=INIT;
	 ELSIF x='1' THEN
	   nextState<=FIRST;
	 END IF;

    END CASE;

  END PROCESS; -- combi_nextState
  -----------------------------------------------------
  combi_out: PROCESS(curState, x)
  BEGIN
    y <= '0'; -- assign default value
    IF curState = FORTH THEN
      y <= '1';
    END IF;
  END PROCESS; -- combi_output
  -----------------------------------------------------
  seq_state: PROCESS (clk, reset)
  BEGIN
    IF reset = '0' THEN
      curState <= INIT;
    ELSIF clk'EVENT AND clk='1' THEN
      curState <= nextState;
    END IF;
  END PROCESS; -- seq
  -----------------------------------------------------
END; -- arch_mealy