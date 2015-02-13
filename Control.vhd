library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity Control is
    Port ( clk : in  STD_LOGIC;										--clock
           rst : in  STD_LOGIC;										--reset
           nxt : in  STD_LOGIC;										--advance to next number
           mem_wr : out  STD_LOGIC;									--enable RAM write
           Mem_Addr : out  UNSIGNED (4 downto 0);				--RAM address to read or write
           r1_en : out  STD_LOGIC;									--register 1 enable
           r2_en : out  STD_LOGIC;									--register 2 enable
           out_en : out  STD_LOGIC;									--fibonacci output enable
           Mux_Sel : out  STD_LOGIC_VECTOR (1 downto 0));	--select source (0, 1, adder)
end Control;

architecture Behavioral of Control is
	--type for FSM states
	type fsm_states is (STORE_0, STORE_1, LOAD_R1, LOAD_R2, STORE_N, WAIT_S);
	
	--signal that represents the current state
	signal state: fsm_states;
	
	--signal that represents the next state
	signal next_state: fsm_states;
	
	--signal for indicating that the end has been reached
	signal done : STD_LOGIC;
	
	
	--counter enable signal, this is high when the FSM should advance and can advance
	signal cnt_en : STD_LOGIC;
	
	--the current counter value
	signal count : UNSIGNED(4 downto 0);

begin

	--counter process for generating an address
	counter: process (clk) is
	begin
		--on rising clock edge
		if rising_edge(clk) then			
			if rst = '1' then
				--if reset is high then set to 0
				count <= "00000";
			else
				if cnt_en = '1' then
					--if counter enable is high then add one to the count
					count <= count +1;
				end if;
			end if;
		end if;
	end process counter;

	--process for current state register
	state_reg : process (clk) is
	begin
		--on rising clock edge
		if rising_edge(clk) then
			if (rst = '1') then
				--if reset it high, go to state STORE_0 (the start state)
				state <= STORE_0;
			else
				--otherwise, advance to the next state (this may be equal to the current state)
				state <= next_state;
			end if;
		end if;
	end process state_reg;
	
	--process for selecting the next state
	next_states: process(state,nxt,done) is
	begin
		case state is
			when STORE_0 =>
				if nxt = '1' then
					--next state after STORE_0 is STORE_1
					next_state <= STORE_1;
				else
					--keep same state if next is low
					next_state <= state;
				end if;
			when STORE_1 =>
				if nxt = '1' then
					--next state after STORE_1 is LOAD_R1
					next_state <= LOAD_R1;
				else
					--keep same state if next is low
					next_state <= state;
				end if;
			when LOAD_R1 =>
				--LOAD_R2 allways comes immediately after LOAD_R1 regardless of nxt signal
				next_state <= LOAD_R2;
			when LOAD_R2 =>
				--STORE_N allways comes immediately after LOAD_R2
				next_state <= STORE_N;
			when STORE_N =>
				--WAIT_S allways comes immediately after STORE_N
				next_state <= WAIT_S;
			when WAIT_S =>
				if nxt ='1' and done = '0' then
					--when the users presses next and there is a next number, next state is LOAD_R1
					next_state <= LOAD_R1;
				else
					--else keep same state
					next_state <= state;
				end if;
			when others =>
				--catch all other cases, keep same state
				next_state <= state;
		end case;
	end process next_states;
		
	--the last valid address is 11000. done is 1 when this count is reached
	done <= '1' when (count = "11000") else '0';
	
	--the counter should advance when in states STORE_0, STORE_1 or WAIT_S if the button is pressed (nxt) and count is not at end (done)
	cnt_en <= nxt when (state = STORE_0) or (state = STORE_1)
				else (nxt and (not done)) when state = WAIT_S
				else '0';
				
	--The memory should be writable in any of the store states, unwritable otherwise
	mem_wr <= '1' when (state = STORE_0) 
						 or (state = STORE_1)
						 or (state = STORE_N) 
						 else '0';
	
	--the address to select
	Mem_Addr <= count when (state = STORE_0) 	--store states select current count
						     or (state = STORE_1)
						     or (state = STORE_N)
			else (count - 1) when (state = LOAD_R2)	--read states select a previously written value
			else (count - 2) when (state = LOAD_R1)
			else "00000";	--dont care when WAIT_S or other
			
	--register 1 enablled in LOAD_R1 state
	r1_en <= '1' when (state = LOAD_R1)
				else '0';
	
	--register 2 enablled in LOAD_R2 state	
	r2_en <= '1' when (state = LOAD_R2)
				else '0';
				
	--enable the output register only when there is a number to store
	out_en <= '1' when (state = STORE_0) 
						     or (state = STORE_1)
						     or (state = STORE_N)
						else '0';
						
	--output selection multpliexer
	Mux_Sel <= "10" when (state = STORE_0)	--select 0 in STORE_0 state
			else "11" when (state = STORE_1)	--select 1 in STORE_1 state
			else "00" when (state = STORE_N)	--select adder output in STORE_N state
			else "00";	--cath all others

end Behavioral;

