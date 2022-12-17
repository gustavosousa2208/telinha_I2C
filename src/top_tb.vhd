library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_tb is end top_tb;

architecture testbench of top_tb is
    component top is 
        port(clk_in : in std_logic;
         scl : out std_logic;
         sda : inout std_logic;
         start_transmission, send_data : in std_logic;
         busy : out std_logic;
         address : in std_logic_vector(7 downto 0);
         i_data : in std_logic_vector(7 downto 0);
         o_nack1, o_nack2 : out std_logic);
    end component;

    signal clk_in : std_logic;    
    signal sda : std_logic;
	signal scl : std_logic;
    signal busy : std_logic;
    signal address : std_logic_vector(7 downto 0);
	signal o_nack1, o_nack2 : std_logic;
    signal i_data : std_logic_vector(7 downto 0);
    signal start_transmission, send_data : std_logic := '0';

	
begin
    uut : top port map(clk_in => clk_in, 
        scl => scl, 
        sda => sda, 
        start_transmission => start_transmission, 
        send_data => send_data, 
        busy => busy, 
        address => address, 
        i_data => i_data, 
        o_nack1 => o_nack1, 
        o_nack2 => o_nack2);
		
	address <= std_logic_vector(to_unsigned(16#69#, 8));
	i_data <= std_logic_vector(to_unsigned(16#75#, 8));

    process
    begin
        start_transmission <= '1';
        for i in 0 to 12 loop
            clk_in <= '0';
			wait for 10 ps;
            clk_in <= '1';
            wait for 10 ps;
        end loop;
		if o_nack1 = '1' then
			report "ADDRESS ERROR";
		else
			while busy = '1' loop
				clk_in <= '0';
				wait for 10 ps;
				clk_in <= '1';
				wait for 10 ps;
			end loop;
			
			send_data <= '1';
			wait for 20 ps;
			send_data <= '0';
			
			while busy = '0' loop
				clk_in <= '0';
				wait for 10 ps;
				clk_in <= '1';
				wait for 10 ps;
			end loop;
			
			while busy = '1' loop
				clk_in <= '0';
				wait for 10 ps;
				clk_in <= '1';
				wait for 10 ps;
			end loop;
		
			wait for 10 ps;
			start_transmission <= '0';
			
			clk_in <= '0';
			wait for 10 ps;
			clk_in <= '1';
			wait for 10 ps;
			
			clk_in <= '0';
			wait for 10 ps;
			clk_in <= '1';
			wait for 10 ps;
			
			wait;
		end if;
    end process;
end architecture;