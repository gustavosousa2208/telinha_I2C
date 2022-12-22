library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller is 
    Port ( clk : in std_logic;
           reset : in std_logic;
           i_start : in std_logic;
           o_scl, saida_pulso_dados, saida_hab_transmissao : out std_logic;
           o_sda : inout std_logic;
           o_address_nack, o_data_nack, o_busy : out std_logic);
end controller;

architecture rtl of controller is
    component top is
        generic (SYSTEM_CLOCK_IN : integer := 27e6;
                I2C_CLOCK_OUT : integer := 100e3);
        port(clk_in : in std_logic;
             scl : out std_logic;
             sda : inout std_logic;
             start_transmission, send_data : in std_logic;
             busy : out std_logic;
             address : in std_logic_vector(7 downto 0);
             i_data : in std_logic_vector(7 downto 0);
             address_nack, data_nack : out std_logic);
    end component;

    signal top_clk_in : std_logic;
    signal top_start_transmission : std_logic := '0';
    signal top_send_data : std_logic := '0';
    signal top_busy : std_logic;
    signal top_address : std_logic_vector(7 downto 0);
    signal top_i_data : std_logic_vector(7 downto 0);
    signal top_address_nack : std_logic;
    signal top_data_nack : std_logic;

    signal GO : std_logic := '0';

    constant s_address : std_logic_vector(7 downto 0) := "01111000";
    type t_sequence is array (integer range <>) of std_logic_vector(7 downto 0);
    -- GOWIN IDE: nao sei o motivo, precisamos comeÃƒÆ’Ã‚Â§ar com 00h e terminar com 00h, assim da pra enviar tudo q tem entre
--    constant sequencia_teste : t_sequence (6 downto 0) := (x"00", x"00", x"A6", x"02", x"4A",ss x"AF", x"00");
    constant sequencia_teste : t_sequence (10 downto 0) := (x"00", x"40", x"0F", x"0F", x"00", x"FF", x"00", x"FF", x"00", x"FF",x"00");

    type t_state is (idle, start, addressing, dating, stop);
    signal estado : t_state := idle;
    signal lock : boolean := false;

begin
    top0 : top
    generic map (SYSTEM_CLOCK_IN => 27e6, I2C_CLOCK_OUT => 400e3)
    port map (
    clk_in => top_clk_in, 
    scl => o_scl, 
    sda => o_sda, 
    start_transmission => top_start_transmission, 
    send_data => top_send_data, 
    busy => top_busy, 
    address => top_address, 
    i_data => top_i_data, 
    address_nack => top_address_nack, 
    data_nack => top_data_nack
    );

    saida_pulso_dados <= top_send_data;
    saida_hab_transmissao <= top_start_transmission;

    top_clk_in <= clk;
    o_busy <= top_busy;
    o_address_nack <= top_address_nack;
    o_data_nack <= top_data_nack;

    start_button : process (GO, clk, reset, i_start,estado)
    begin
        if estado = stop then
            GO <= '0';
        elsif rising_edge(i_start) then
            GO <= '1';
        else 
            GO <= GO;
        end if;
    end process;

    process (clk, reset, i_start, top_busy, GO,estado)
        variable conta : integer range sequencia_teste'length downto 0:= sequencia_teste'length;
        variable conta_lock : boolean := false;
    begin
        if rising_edge(clk) then
            case estado is
            when idle =>
                if top_busy = '1' then
                    top_start_transmission <= '1';
                else
                    top_start_transmission <= '0';
                end if;

                top_send_data <= '0';
                top_address <= s_address;

                if GO = '1' then
                    estado <= start;
                else
                    estado <= idle;
                end if;
            when start =>
                top_start_transmission <= '1';
                top_send_data <= '0';
                estado <= addressing;
            when addressing =>
				top_start_transmission <= '1';
                top_send_data <= '0';
                if top_busy = '1' then
                    estado <= addressing;
                else
                    if top_address_nack = '1' then
                        estado <= stop;
                    else
                        estado <= dating;
                    end if;
                end if;
            when dating =>
                if top_busy = '1' then
                    estado <= dating;
                    top_send_data <= '0';
                    conta_lock := false;
                else 
                    if conta = 0 then
                        conta := sequencia_teste'length;
                        estado <= stop;
                    else
                        top_i_data <= sequencia_teste(conta - 1);
                        top_send_data <= '1';
                        if conta_lock = false then
                            conta := conta - 1;
                            conta_lock := true;
                        end if;
                        
                        estado <= dating;
                    end if;
                end if;
            when stop =>
                estado <= idle;
            when others =>
                null;
            end case;
        end if;
    end process;
end architecture;