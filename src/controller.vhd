library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller is 
    Port ( clk : in std_logic;
           reset : in std_logic;
           start : in std_logic;
           o_address_nack, o_data_nack, o_busy : out std_logic);
end controller;

architecture rtl of controller is
    component top is 
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
    end component;

    signal top_clk_in : std_logic;
    signal top_scl : std_logic;
    signal top_sda : std_logic;
    signal top_start_transmission : std_logic;
    signal top_send_data : std_logic;
    signal top_busy : std_logic;
    signal top_address : std_logic_vector(7 downto 0);
    signal top_i_data : std_logic_vector(7 downto 0);
    signal top_address_nack : std_logic;
    signal top_data_nack : std_logic;

    constant s_address : std_logic_vector(7 downto 0) := std_logic_vector(to_unsigned(0x68, 8));

begin
    top0 : top
        generic map (SYSTEM_CLOCK_IN => 27e6, I2C_CLOCK_OUT => 100e3)
        port map (
        clk_in => top_clk_in, 
        scl => top_scl, 
        sda => top_sda, 
        start_transmission => top_start_transmission, 
        send_data => top_send_data, 
        busy => top_busy, 
        address => top_address, 
        i_data => top_i_data, 
        address_nack => top_address_nack, 
        data_nack => top_data_nack
        );



end architecture;