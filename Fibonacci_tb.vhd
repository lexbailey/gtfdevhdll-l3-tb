LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY Fibonacci_tb IS
END Fibonacci_tb;
 
ARCHITECTURE behavior OF Fibonacci_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Fibonacci
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         nxt : IN  std_logic;
         Fib_Out : OUT  std_logic_vector(15 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal nxt : std_logic := '0';

 	--Outputs
   signal Fib_Out : std_logic_vector(15 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Fibonacci PORT MAP (
          clk => clk,
          rst => rst,
          nxt => nxt,
          Fib_Out => Fib_Out
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

		nxt <= '0';
		rst <= '1';
      wait for clk_period*2;
		rst <= '0';
		
		next_loop_0: for i in 0 to 4 LOOP
			nxt <= '1';
			wait for clk_period*3;
			nxt <= '0';
			wait for clk_period*3;
		END LOOP next_loop_0;

      rst <= '1';
      wait for clk_period*2;
		rst <= '0';
		
		next_loop_1: LOOP
			nxt <= '1';
			wait for clk_period*3;
			nxt <= '0';
			wait for clk_period*3;
		END LOOP next_loop_1;
		
      wait;
   end process;

END;
