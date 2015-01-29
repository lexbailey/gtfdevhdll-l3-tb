
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity Control is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           nxt : in  STD_LOGIC;
           mem_wr : out  STD_LOGIC;
           Mem_Addr : out  UNSIGNED (4 downto 0);
           r1_en : out  STD_LOGIC;
           r2_en : out  STD_LOGIC;
           out_en : out  STD_LOGIC;
           Mux_Sel : out  STD_LOGIC_VECTOR (1 downto 0));
end Control;

architecture Behavioral of Control is

	type fsm_states is (STORE_0, STORE_1, LOAD_R1, LOAD_R2, STORE_N, WAIT_S);
	signal state: fsm_states;
	signal next_state: fsm_states;
	signal done : STD_LOGIC;
	signal cnt_en : STD_LOGIC;
	signal count : UNSIGNED(4 downto 0);

begin

	counter: process (clk) is
	begin
		if rising_edge(clk) then
			if rst = '1' then
				count <= "00000";
			else
				if cnt_en = '1' then
					count <= count +1;
				end if;
			end if;
		end if;
	end process counter;

	state_reg : process (clk) is
	begin
		if rising_edge(clk) then
			if (rst = '1') then
				state <= STORE_0;
			else
				state <= next_state;
			end if;
		end if;
	end process state_reg;
	
	next_states: process(state,rst,nxt,done) is
	begin
		case state is
			when STORE_0 =>
				if nxt = '1' then
					next_state <= STORE_1;
				else
					next_state <= state;
				end if;
			when STORE_1 =>
				if nxt = '1' then
					next_state <= LOAD_R1;
				else
					next_state <= state;
				end if;
			when LOAD_R1 =>
				next_state <= LOAD_R2;
			when LOAD_R2 =>
				next_state <= STORE_N;
			when STORE_N =>
				next_state <= WAIT_S;
			when WAIT_S =>
				if nxt ='1' and done = '0' then
					next_state <= LOAD_R1;
				else
					next_state <= state;
				end if;
			when others =>
				next_state <= state;
		end case;
	end process next_states;
		
	done <= '1' when (count = "11000") else '0';
	
	cnt_en <= nxt when (state = STORE_0) or (state = STORE_1)
				else (nxt and (not done)) when state = WAIT_S
				else '0';
				
	mem_wr <= '1' when (state = STORE_0) 
						 or (state = STORE_1)
						 or (state = STORE_N) 
						 else '0';
	
	Mem_Addr <= count when (state = STORE_0) 
						     or (state = STORE_1)
						     or (state = STORE_N)
			else (count - 1) when (state = LOAD_R2)
			else (count - 2) when (state = LOAD_R1)
			else "00000";
			
	r1_en <= '1' when (state = LOAD_R1)
				else '0';
				
	r2_en <= '1' when (state = LOAD_R2)
				else '0';
				
	out_en <= '1' when (state = STORE_0) 
						     or (state = STORE_1)
						     or (state = STORE_N)
						else '0';
						
	Mux_Sel <= "10" when (state = STORE_0)
			else "11" when (state = STORE_1)
			else "00" when (state = STORE_N)
			else "00";

end Behavioral;

