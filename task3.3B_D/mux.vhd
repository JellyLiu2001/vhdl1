ENTITY mux IS --Create an entity called mux. 
  PORT ( --Define four ports by bit
    a:IN BIT; --Input a
    b:IN BIT; --Input b
    address:IN BIT; --choose which(A & B) should be output(Q)
    q:OUT BIT --output q
);
END mux;
--I finnish four ARCHITECTURE and OUTPUT the same result
--I prefer the fourth(bool), because I think it's easy to code and identify the architecture to check the result in the wave. 
-- One entity, two separate architectures.
-- The architecture of choice can be bound to the entity 
-- At the time of instantiation in the testbench.

ARCHITECTURE dataflow OF mux IS --Create an architecture named 'dataflow', which represented by dataflow
BEGIN
  q <= a WHEN address = '0' ELSE b; --When address=0, q=a, otherwise q=b
END dataflow;


ARCHITECTURE gates OF mux IS --Create an architecture named 'gates', which represented by gate expression
  SIGNAL int1,int2,int_address: BIT; --Declare the signals in the declarative
BEGIN
  q <= int1 OR int2; --q == int1 or gate int2
  int1 <= b and address; --int1 == b AND gate address
  int_address <= NOT address; -- Convert address by not gate
  int2 <= int_address AND a; --int2 == int_address AND gate a
END gates;


ARCHITECTURE sequential OF mux IS --Create an architecture named sequential, which represented by sequential
BEGIN
  select_proc : PROCESS (a,b,address) 
  BEGIN
   IF (address = '0') THEN
       q <= a;
   ELSIF (address = '1') THEN
       q <= b;
   END IF;
 END PROCESS select_proc;
END sequential;


ARCHITECTURE bool OF mux IS --Create an architecture named bool, which represented by bool expression
BEGIN
   q <= (a AND NOT(address)) OR (b and address); 
END bool;