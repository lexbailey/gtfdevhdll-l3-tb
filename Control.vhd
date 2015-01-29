
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

begin

	--put magic here!

end Behavioral;

