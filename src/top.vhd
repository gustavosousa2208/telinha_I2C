library ieee;
use ieee.std_logic_1164.all;

-- para evitar problemas, remova o 'Z' lÃ¡ na hora de selecionar o pre_data ou nao

entity top is 
    generic (SYSTEM_CLOCK_IN : 27e6;
            I2C_CLOCK_OUT : 100e3);
    port(clk_in : in std_logic;
         scl : out std_logic;
         sda : inout std_logic;
         start_transmission, send_data : in std_logic;
         busy : out std_logic;
         address : in std_logic_vector(7 downto 0);
         i_data : in std_logic_vector(7 downto 0);
         address_nack, data_nack : out std_logic);
end entity;

architecture rtl of top is
    type t_estados is (idle, start, stop1, stop2, addressing, data, ack1, terminado, ack2,pre_data);
    signal estado : t_estados := idle;

    signal o_i2c_clk : std_logic := '0';
    signal i2c_clk_en: std_logic := '0';

    signal s_sda, s_scl : std_logic := '1';
    signal GO : std_logic := '0';

    signal s_address : std_logic_vector(7 downto 0) := "01111000";
    signal scl_buffer_en : std_logic := '0';

    signal s_nack1 : std_logic := '1';
    signal s_nack2 : std_logic := '1';
	signal lock : std_logic := '0';
	signal s_full : std_logic := '0';
	signal s_transmission_started : std_logic := '0';
	
	signal s_data : std_logic_vector(7 downto 0) := "10110101";

begin
    o_i2c_clk <= clk_in;
    divisor : process(clk_in)
        variable conta : integer range 0 to (SYSTEM_CLOCK_IN / I2C_CLOCK_OUT) := 1;
    begin
        if rising_edge(clk_in) then
            if conta = (SYSTEM_CLOCK_IN / I2C_CLOCK_OUT) then
                conta := 1;
                i2c_clk_en <= '1';
                o_i2c_clk <= not o_i2c_clk;
            else
                i2c_clk_en <= '0';
                conta := conta + 1;
            end if;
        end if;
    end process;

    start_reg : process(clk_in, start_transmission, estado,GO)
    begin
		if estado = terminado then
			GO <= '0';
		elsif rising_edge(start_transmission) then
            s_address <= address;
            GO <= '1';
			lock <= '1';
		else
			GO <= GO;
		end if;
		
    end process;


    process(clk_in, sda, GO, estado, o_i2c_clk, scl_buffer_en, s_sda, s_scl, s_address,s_nack1)
        variable conta : integer range 8 downto 0 := 8;
        variable conta_dado : integer range 8 downto 0 := 8;
    begin
        if falling_edge(o_i2c_clk) then
            case estado is 
            when idle =>
                if GO = '1' then
                    estado <= start;
                else
                    estado <= idle;
                end if;
				
                s_sda <= '1';
                s_scl <= '1';
				
            when start =>
                s_sda <= '0';
                s_scl <= '1';
                estado <= addressing;
            when addressing =>
				scl_buffer_en <= '1';
                if conta = 0 then
                    estado <= ack1;
                    conta := 8;
                else
                    s_sda <= s_address(conta - 1);
                    conta := conta - 1;
                end if;
            when ack1 =>
				estado <= pre_data;
				scl_buffer_en <= '0';
            when pre_data =>
			
				if s_nack1 = '1' then
                    estado <= stop1;
                elsif s_nack1 = 'Z' or s_nack1 = '0' then
					if start_transmission = '1' then
						if s_full = '1' then
							estado <= data;
							conta_dado := 8;
						else
							estado <= pre_data;
						end if;
					else
						estado <= stop1;
					end if;
                end if;
				
            when data =>
				scl_buffer_en <= '1';
                if conta_dado = 0 then
                    estado <= ack2;
                    conta := 8;
                else
                    s_sda <= s_data(conta_dado - 1);
                    conta_dado := conta_dado - 1;
                end if;
				
			when ack2 =>
				if start_transmission = '1' then
					s_sda <= '0';
					scl_buffer_en <= '0';
					estado <= pre_data;
				else
					estado <= stop1;
					s_sda <= '0';
					scl_buffer_en <= '0';
				end if;
			when stop1 =>
				estado <= terminado;
            when others =>
                estado <= idle;
            end case;
        end if;
    end process;

    data_reg : process(clk_in, send_data, estado, s_data, GO)
    begin
        if estado = data then
            s_full <= '0';
        elsif rising_edge(send_data) then
            if estado = pre_data then
                s_data <= i_data;
                s_full <= '1';
            end if;
        end if;
    end process;

    ack_reg1 : process(clk_in, sda, estado, s_nack1,o_i2c_clk,s_transmission_started)
    begin
        if o_i2c_clk = '1' then
            if estado = ack1 then
                s_nack1 <= sda;
            end if;
        end if;
    end process;
    
    ack_reg2 : process(clk_in, sda, estado, s_nack2,o_i2c_clk)
    begin
        if o_i2c_clk = '1' then
            if estado = ack2 then
                s_nack2 <= sda;
            end if;
        end if;
    end process;

    address_nack <= s_nack1;
    data_nack <= s_nack2;

    scl <= '1' when estado = idle or (estado = stop1 and o_i2c_clk = '1')else 
            o_i2c_clk when scl_buffer_en = '1';

    sda <= '1' when estado = idle or estado = terminado else 
            '0' when ((estado = start) and (s_scl = '0')) else
--            s_sda when ((estado /= ack1) and (estado /= ack2)) else 
			'Z' when ((estado = ack1) or (estado = ack2)) else s_sda;

    busy <= '0' when (estado = idle or estado = pre_data) else '1';


end architecture;