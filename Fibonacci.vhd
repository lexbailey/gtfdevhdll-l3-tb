library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Top level entity for the Fibonacci number generator
-- For description of operation, see Lab 3 script

entity Fibonacci is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           nxt : in  STD_LOGIC;
           Fib_Out : out  STD_LOGIC_VECTOR (15 downto 0));
end Fibonacci;

architecture Behavioral of Fibonacci is

signal inv_rst : STD_LOGIC;  -- inverted reset signal (active low)
signal deb_rst, deb_nxt : STD_LOGIC;  -- debounced reset and "next" signals
signal mem_wr : STD_LOGIC;   -- datapath RAM write enable
signal Mem_Addr : UNSIGNED (4 downto 0); -- datapath RAM address
signal r1_en, r2_en, out_en : STD_LOGIC;  -- datapath register enable signals
signal Mux_Sel : STD_LOGIC_VECTOR (1 downto 0); -- control for datapath mux
 

begin

-- inversion of reset signal to compensate for active-low button
inv_rst <= not rst;  

-- Xilinx debouncer for reset signal
	Rst_Debouncer: entity work.Debouncer PORT MAP(
		CLK => clk,
		Sig => inv_rst,
		Deb_Sig => deb_rst
	);

-- Xilinx debouncer for "Next" signal	
	Next_Debouncer: entity work.Debouncer PORT MAP(
		CLK => clk,
		Sig => nxt,
		Deb_Sig => deb_nxt
	);
	
-- Datapath for Fibonacci number generator
	Inst_Datapath: entity work.Datapath PORT MAP(
		clk => clk,
		rst => deb_rst,
		mem_wr => mem_wr,
		Mem_Addr => Mem_Addr,
		r1_en => r1_en,
		r2_en => r2_en,
		out_en => out_en,
		Mux_Sel => Mux_Sel,
		Fib_Out => Fib_Out
	);
	
-- Datapath for Fibonacci number generator
-- For description of operation, see Lab 3 script
	Inst_Control: entity work.Control PORT MAP(
		clk => clk,
		rst => deb_rst,
		nxt => deb_nxt,
		mem_wr => mem_wr,
		Mem_Addr => Mem_Addr,
		r1_en => r1_en,
		r2_en => r2_en,
		out_en => out_en,
		Mux_Sel => Mux_Sel
	);
	


end Behavioral;

