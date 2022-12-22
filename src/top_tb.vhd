library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_tb is end top_tb;

architecture testbench of top_tb is
    component controller is 
		Port ( clk : in std_logic;
		reset : in std_logic;
		i_start : in std_logic;
		o_scl, saida_pulso_dados, saida_hab_transmissao : out std_logic;
		o_sda : inout std_logic;
		o_address_nack, o_data_nack, o_busy : out std_logic);
	end component;
	
	signal clk, reset, i_start : std_logic;
	signal o_sda, o_scl : std_logic;
	signal o_address_nack, o_data_nack, o_busy : std_logic;
	signal saida_pulso_dados, saida_hab_transmissao : std_logic;

begin

	ctrl : controller port map (saida_hab_transmissao=>saida_hab_transmissao, saida_pulso_dados => saida_pulso_dados, clk => clk, reset => reset, i_start => i_start, o_scl => o_scl, o_sda => o_sda, o_address_nack => o_address_nack, o_data_nack => o_data_nack, o_busy => o_busy);

	process
	begin
		i_start <= '0';
		wait for 10 ps;
		i_start <= '1';
		for i in 1 to 300 loop
			clk <= '0';
			wait for 1 ps;
			clk <= '1';
			wait for 1 ps;
		end loop;
		wait;
	end process;
    
end architecture;