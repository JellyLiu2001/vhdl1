-- Data Sampler (dataSampler.vhd)
-- Asynchronous reset, active high
------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.ALL;

ENTITY dataSampler IS --Create an entity called datasampler. 
  PORT (
    clk: in STD_ULOGIC;--set clock as input
    reset: in STD_ULOGIC;--set reset as input
    outValid: out STD_ULOGIC;--set outvalid as output
    A_in: in STD_ULOGIC_VECTOR(7 DOWNTO 0);--set A as input in 8 bit.
    B_in: in STD_ULOGIC_VECTOR(7 DOWNTO 0);
    C_in: in STD_ULOGIC_VECTOR(7 DOWNTO 0);
    D_in: in STD_ULOGIC_VECTOR(7 DOWNTO 0);
    E_in: in STD_ULOGIC_VECTOR(7 DOWNTO 0);
    F_out: out STD_ULOGIC_VECTOR(15 DOWNTO 0);--set F as output in 16 bit.
    G_out: out STD_ULOGIC_VECTOR(15 DOWNTO 0)
  );
END;

ARCHITECTURE oneAdd_oneMult OF dataSampler IS --Create an architecture named oneAdd_oneMult
  TYPE MUXSEL is (LEFT, RIGHT);--define the mux
  TYPE STATE_TYPE is (INIT, FIRST, SECOND, THIRD, FORTH);--define the STATE, in this program, there are five states.
  SIGNAL curState, nextState : STATE_TYPE;--Declare the signals in the declarative
  -- control signals
  SIGNAL M1_sel, M2_sel, M3_sel : MUXSEL;
  SIGNAL R1_en, R2_en, R3_en, R4_en, R5_en, R6_en : BOOLEAN;--Declare the signals by boolean in the declarative
  -- data signals
  SIGNAL reg1_in, reg2_in, reg3_in: SIGNED(7 DOWNTO 0);
  SIGNAL reg1, reg2, reg3, reg4, addOut: SIGNED(7 DOWNTO 0);
  SIGNAL reg5, reg6, multOut : SIGNED(15 DOWNTO 0);
BEGIN
  
  M1: PROCESS(M1_sel,A_in,C_in)--define the Mux1
  BEGIN
    IF M1_sel = LEFT THEN--if s1=LEFT, then choosing data(a)
      reg1_in <= signed(A_in);
    ELSE -- RIGHT
      reg1_in <= signed(C_in);
    END IF;
  END PROCESS;
  
  M2: PROCESS(M2_sel,B_in,D_in)--define the Mux2
  BEGIN
    IF M2_sel = LEFT THEN--if s2=LEFT, then choosing data(b)
      reg2_in <= signed(B_in);
    ELSE -- RIGHT
      reg2_in <= signed(D_in);
    END IF;
  END PROCESS;
  
  M3: PROCESS(M3_sel,E_in,addOut)--define the Mux3
  BEGIN
    IF M3_sel = LEFT THEN--if s3=LEFT, then choosing data(e)
      reg3_in <= signed(E_in);
    ELSE -- RIGHT
      reg3_in <= signed(addOut);--if s3=RIGHT, then choosing data(addout), which is the data output from adder.
    END IF;
  END PROCESS;  
  
  R1: PROCESS(reset,clk)--define reg r1's clock and reset.
  BEGIN
    IF reset = '1' THEN --if reset is working
      reg1 <= TO_SIGNED(0,8);--reg1=0 and 8bit
    ELSIF clk'event AND clk='1' THEN --when clock is raising edge
      IF R1_en = TRUE THEN--r1 enable is on.
        reg1 <= reg1_in;--reg1= data that from input.
      END IF;
    END IF;
  END PROCESS;      
        
  R2: PROCESS(reset,clk)--same as r1's process
  BEGIN
    IF reset = '1' THEN
      reg2 <= TO_SIGNED(0,8);
    ELSIF clk'event AND clk='1' THEN
      IF R2_en = TRUE THEN
        reg2 <= reg2_in;
      END IF;
    END IF;
  END PROCESS;      
  
  R3: PROCESS(reset,clk)--same as r1's process
  BEGIN
    IF reset = '1' THEN
      reg3 <= TO_SIGNED(0,8);
    ELSIF clk'event AND clk='1' THEN
      IF R3_en = TRUE THEN--
        reg3 <= reg3_in;
      END IF;
    END IF;
  END PROCESS;      
        
  R4: PROCESS(reset,clk)--same as r1's process
  BEGIN
    IF reset = '1' THEN
      reg4 <= TO_SIGNED(0,8);
    ELSIF clk'event AND clk='1' THEN
      IF R4_en = TRUE THEN
        reg4 <= addOut;
      END IF;
    END IF;
  END PROCESS;

  add: PROCESS(reg1, reg2)--define adder's process
  BEGIN
    addOut <= reg1 + reg2;--addout = r1+r2
  END PROCESS;        

  mult: PROCESS(reg3, reg4)--define multiplication
  BEGIN
    multOut <= reg3 * reg4;--multout= r3*r4
  END PROCESS;        
  
  R5: PROCESS(reset,clk)--same as r1's process
  BEGIN
    IF reset = '1' THEN
      reg5 <= TO_SIGNED(0,16);
    ELSIF clk'event and clk='1' THEN
      IF R5_en = TRUE THEN
        reg5 <= multOut;
      END IF;
    END IF;
  END PROCESS;
  
  R6: PROCESS(reset,clk)--same as r1's process
  BEGIN
    IF reset = '1' THEN
      reg6 <= TO_SIGNED(0,16);
    ELSIF clk'event AND clk='1' THEN
      IF R6_en = TRUE THEN
        reg6 <= multOut;
      END IF;
    END IF;
  END PROCESS;

  F_out <= STD_ULOGIC_VECTOR(reg5); -- type casting
  G_out <= STD_ULOGIC_VECTOR(reg6);  
  
  stateReg: PROCESS(reset,clk)
  BEGIN
    IF reset = '1'  THEN
      curState <= INIT;
    ELSIF clk'event AND clk = '1' THEN
      curState <= nextState;
    END IF;
  END PROCESS;
  
  nextStateLogic: PROCESS(curState)--define the case of state
  BEGIN
    CASE curState IS--state is from 0 to 4 and loop
      WHEN INIT =>
        nextState <= FIRST;
      WHEN FIRST =>
        nextState <= SECOND;
      WHEN SECOND =>
        nextState <= THIRD;
      WHEN THIRD =>
        nextState <= FORTH;
      WHEN FORTH =>
        nextState <= INIT;
      
    -- Depending on the number of STATEs you have, and the minimum required 
    -- number of bits, unused states may result.
    -- If due to some noise or malfunction the FSM should end up in one of 
    -- these undefined states, it may languish in that state for ever, 
    -- until a system reset. Adding the following clause allows the circuit
    -- to enter into a defined state in the next cycle.
    WHEN OTHERS => 
      nextState <= INIT;
    END CASE;
  END PROCESS;
  
  ctrlOut: PROCESS(curState)
  BEGIN
    -- assign default values
    M1_sel <= LEFT;
    M2_sel <= LEFT;--all LEFT(default)
    M3_sel <= LEFT;
      ------------------------------------
    outValid <= '0';
    CASE curState IS

      WHEN INIT =>
        M1_sel <= LEFT;
        M2_sel <= LEFT;
        R1_en <= TRUE;
        R2_en <= TRUE;
      ------------------------------------
      WHEN FIRST =>
        M1_sel <= RIGHT;
        M2_sel <= RIGHT;
        M3_sel <= LEFT;
        R1_en <= TRUE;
        R2_en <= TRUE;
        R3_en <= TRUE;
        R4_en <= TRUE;
        
      ------------------------------------
      WHEN SECOND =>
        M3_sel <= RIGHT;
        R3_en <= TRUE;
        R5_en <= TRUE;
        
      -------------------------------------
      WHEN THIRD =>
      R6_en<=TRUE;

      ------------------------------------
      WHEN FORTH =>        
        outValid <= '1';
    END CASE;
END PROCESS;
  
END; -- nextStateLogic
      
      