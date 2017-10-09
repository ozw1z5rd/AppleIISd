----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:44:25 10/09/2017 
-- Design Name: 
-- Module Name:    IO - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity IO is
Port (
    ADD_HIGH : in std_logic_vector(10 downto 8);
    ADD_LOW : in std_logic_vector(1 downto 0);
    B10 : out std_logic;
    B9 : out std_logic;
    B8 : out std_logic;
    CARD : in std_logic;
    DATA : inout std_logic_vector (7 downto 0);
    CLK : in std_logic;
    LED : out std_logic;
    NDEV_SEL : in std_logic;
    NG : out std_logic;
    NIO_SEL : in std_logic;
    NIO_STB : in std_logic;
    NOE : out std_logic;
    PHI0 : in std_logic;
    NRESET : in std_logic;
    RNW : in std_logic;
    MISO : in std_logic;
    MOSI : out std_logic;
    NSEL : out std_logic;
    SCLK : out std_logic;
    WP : in std_logic
    );
end IO;

architecture Behavioral of IO is

    signal data_in : std_logic_vector (7 downto 0);
    signal data_out : std_logic_vector (7 downto 0);
    signal addr_low_int : std_logic_vector (1 downto 0);
    signal wp_int : std_logic;
    signal card_int : std_logic;
    signal miso_int : std_logic;
    
    signal ndev_sel_int : std_logic;
    signal rnw_int : std_logic;
    signal data_en : std_logic;
        
component AppleIISd is
Port (
        data_in : in std_logic_vector (7 downto 0);
        data_out : out std_logic_vector (7 downto 0);
        is_read : in  std_logic;
        reset : in  std_logic;
        addr : in  std_logic_vector (1 downto 0);
        phi0 : in  std_logic;
        selected : in  std_logic;
        clk : in  std_logic;
        miso: in std_logic;
        mosi : out  std_logic;
        sclk : out  std_logic;
        nsel : out  std_logic;
        wp : in  std_logic;
        card : in  std_logic;
        led : out  std_logic
    );
end component;

component AddressDecoder
    port ( 
        A8 : in std_logic; 
        A9 : in std_logic; 
        A10 : in std_logic; 
        NDEV_SEL : in std_logic;
        NIO_SEL : in std_logic; 
        NIO_STB : in std_logic; 
        RNW : in std_logic;
        B8 : out std_logic; 
        B9 : out std_logic; 
        B10 : out std_logic; 
        NOE : out std_logic;
        NG : out std_logic;
        DATA_EN : out std_logic
    );
    end component;

begin
    spi: AppleIISd port map(
        data_in => data_in,
        data_out => data_out,
        is_read => rnw_int,
        reset => not NRESET,
        addr => addr_low_int,
        phi0 => PHI0,
        selected => not ndev_sel_int,
        clk => CLK,
        miso => miso_int,
        mosi => MOSI,
        sclk => SCLK,
        nsel => NSEL,
        wp => wp_int,
        card => card_int,
        led => LED
    );
    
    addDec: AddressDecoder port map(
        A8 => ADD_HIGH(8),
        A9 => ADD_HIGH(9),
        A10 => ADD_HIGH(10),
        NDEV_SEL => NDEV_SEL,
        NIO_SEL => NIO_SEL,
        NIO_STB => NIO_STB,
        RNW => RNW,
        B8 => B8,
        B9 => B9,
        B10 => B10,
        NOE => NOE,
        NG => NG,
        DATA_EN => data_en
    );
    
    ctrl_latch: process(CLK, NRESET)
    begin
        if(NRESET = '0') then
            ndev_sel_int <= '1';
            rnw_int <= '1';
            wp_int <= '1';
            card_int <= '1';
            miso_int <= '1';
        elsif rising_edge(CLK) then
            ndev_sel_int <= NDEV_SEL;
            rnw_int <= RNW;
            wp_int <= WP;
            card_int <= CARD;
            miso_int <= MISO;
        end if;
    end process;
    
    DATA <= data_out when (data_en = '1') else (others => 'Z');      -- data bus tristate
    
    data_latch: process(ndev_sel)
    begin
        if(rising_edge(ndev_sel) and (rnw_int = '0')) then
            data_in <= DATA;
        end if;
    end process;
    
    add_latch: process(ndev_sel)
    begin
        if falling_edge(ndev_sel) then
            addr_low_int <= ADD_LOW;
        end if;
    end process;

end Behavioral;

