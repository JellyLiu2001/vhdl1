USE work.ALL;
ENTITY tb_mux IS END tb_mux;

ARCHITECTURE testMux OF tb_mux IS

  COMPONENT mux
    PORT (
      a:IN BIT;
      b:IN BIT;
      address:IN BIT;   
      q:OUT BIT
    );
  END COMPONENT;
  
  SIGNAL testvector:BIT_VECTOR(2 DOWNTO 0);
  SIGNAL gateResult,dfResult,seqResult,boolResult:BIT;
  
  FOR c1:mux USE ENTITY work.mux(dataflow);
  FOR c2:mux USE ENTITY work.mux(gates);  
  FOR c3:mux USE ENTITY work.mux(sequential);  
  FOR c4:mux USE ENTITY work.mux(bool);  
BEGIN

 
  C1:mux PORT MAP(testvector(2), testvector(1),testvector(0),dfResult);
  C2:mux PORT MAP(testvector(2), testvector(1),testvector(0),gateResult);
  C3:mux PORT MAP(testvector(2), testvector(1),testvector(0),seqResult);
  C4:mux PORT MAP(testvector(2), testvector(1),testvector(0),boolResult);

	testvector<=
		"000",
		"100" AFTER 10 ns,
		"110" AFTER 15 ns,
		"111" AFTER 20 ns,
		"110" AFTER 25 ns,
		"010" AFTER 27 ns,
		"101" AFTER 30 ns,
		"111" AFTER 35 ns,
		"011" AFTER 38 ns,
    "010" AFTER 40 ns;
 
END testMux;