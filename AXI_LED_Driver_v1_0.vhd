library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity LED_Controller_AXI_v1_0 is
	generic (
		-- Users to add parameters here
          NUM_LEDS	      : integer	:= 4;         
          NUM_ACTIVE_LEDS	: integer	:= 4; 
          -- Reset value that LEDs are set to and reset value of counter
          LED_RESET_VAL	  : integer	:= 16#0#; -- valor 57, en sistema numerico de base 16 (es decir hexa). Ver p.180 https://edg.uchicago.edu/~tang/VHDLref.pdf
          -- Counter prescale value so counting can be visible in hardware
          CNT_PRESCALE_VAL: integer	:= 125_000_000; -- assuming 125MHz, one second count
		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface S00_AXI
		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 4
	);
	port (
		-- Users to add ports here
          cnt_disp : in  std_logic; 
                   -- Output leds to be driven. 
          leds     : out std_logic_vector (NUM_LEDS-1 downto 0); 
		-- User ports ends
		-- Do not modify the ports beyond this line


		-- Ports of Axi Slave Bus Interface S00_AXI
		s00_axi_aclk	: in std_logic;
		s00_axi_aresetn	: in std_logic;
		s00_axi_awaddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_awprot	: in std_logic_vector(2 downto 0);
		s00_axi_awvalid	: in std_logic;
		s00_axi_awready	: out std_logic;
		s00_axi_wdata	: in std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_wstrb	: in std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
		s00_axi_wvalid	: in std_logic;
		s00_axi_wready	: out std_logic;
		s00_axi_bresp	: out std_logic_vector(1 downto 0);
		s00_axi_bvalid	: out std_logic;
		s00_axi_bready	: in std_logic;
		s00_axi_araddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_arprot	: in std_logic_vector(2 downto 0);
		s00_axi_arvalid	: in std_logic;
		s00_axi_arready	: out std_logic;
		s00_axi_rdata	: out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_rresp	: out std_logic_vector(1 downto 0);
		s00_axi_rvalid	: out std_logic;
		s00_axi_rready	: in std_logic
	);
end LED_Controller_AXI_v1_0;

architecture arch_imp of LED_Controller_AXI_v1_0 is

	-- component declaration
	component LED_Controller_AXI_v1_0_S00_AXI is
		generic (
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 4
		);
		port (
		user_reg0 : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_ACLK	: in std_logic;
		S_AXI_ARESETN	: in std_logic;
		S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
		S_AXI_AWVALID	: in std_logic;
		S_AXI_AWREADY	: out std_logic;
		S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		S_AXI_WVALID	: in std_logic;
		S_AXI_WREADY	: out std_logic;
		S_AXI_BRESP	: out std_logic_vector(1 downto 0);
		S_AXI_BVALID	: out std_logic;
		S_AXI_BREADY	: in std_logic;
		S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
		S_AXI_ARVALID	: in std_logic;
		S_AXI_ARREADY	: out std_logic;
		S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_RRESP	: out std_logic_vector(1 downto 0);
		S_AXI_RVALID	: out std_logic;
		S_AXI_RREADY	: in std_logic
		);
	end component LED_Controller_AXI_v1_0_S00_AXI;

    
    component LED_Controller is
    
      generic (
              NUM_LEDS	      : integer	:= 4;         
              NUM_ACTIVE_LEDS	: integer	:= 4; 
              -- Reset value that LEDs are set to and reset value of counter
              LED_RESET_VAL	  : integer	:= 16#0#; -- valor 57, en sistema numerico de base 16 (es decir hexa). Ver p.180 https://edg.uchicago.edu/~tang/VHDLref.pdf
              -- Counter prescale value so counting can be visible in hardware
              CNT_PRESCALE_VAL: integer	:= 125_000_000 -- assuming 125MHz, one second count
           );
           
      Port (  --Input clock
                    clk      : in  std_logic; 
                    -- Input reset  
              rst      : in  std_logic; 
              -- Counter selector. This should be connected to a switch. If switch is on, leds show current count, otherwise leds show data in.      
              cnt_disp : in  std_logic; 
              -- Data given to the entity by an external source.
              data_in  : in  std_logic_vector (31 downto 0); 
              -- Output leds to be driven. 
              leds     : out std_logic_vector (NUM_LEDS-1 downto 0) 
           );
    end component LED_Controller;
    
    signal user_reg0 : std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);

begin

-- Instantiation of Axi Bus Interface S00_AXI
LED_Controller_AXI_v1_0_S00_AXI_inst : LED_Controller_AXI_v1_0_S00_AXI
	generic map (
		C_S_AXI_DATA_WIDTH	=> C_S00_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_S00_AXI_ADDR_WIDTH
	)
	port map (
	    user_reg0 => user_reg0,
		S_AXI_ACLK	=> s00_axi_aclk,
		S_AXI_ARESETN	=> s00_axi_aresetn,
		S_AXI_AWADDR	=> s00_axi_awaddr,
		S_AXI_AWPROT	=> s00_axi_awprot,
		S_AXI_AWVALID	=> s00_axi_awvalid,
		S_AXI_AWREADY	=> s00_axi_awready,
		S_AXI_WDATA	=> s00_axi_wdata,
		S_AXI_WSTRB	=> s00_axi_wstrb,
		S_AXI_WVALID	=> s00_axi_wvalid,
		S_AXI_WREADY	=> s00_axi_wready,
		S_AXI_BRESP	=> s00_axi_bresp,
		S_AXI_BVALID	=> s00_axi_bvalid,
		S_AXI_BREADY	=> s00_axi_bready,
		S_AXI_ARADDR	=> s00_axi_araddr,
		S_AXI_ARPROT	=> s00_axi_arprot,
		S_AXI_ARVALID	=> s00_axi_arvalid,
		S_AXI_ARREADY	=> s00_axi_arready,
		S_AXI_RDATA	=> s00_axi_rdata,
		S_AXI_RRESP	=> s00_axi_rresp,
		S_AXI_RVALID	=> s00_axi_rvalid,
		S_AXI_RREADY	=> s00_axi_rready
	);

	-- Add user logic here
 LED_Controller_inst : LED_Controller
      generic map (
         NUM_LEDS         => NUM_LEDS,
         NUM_ACTIVE_LEDS  => NUM_ACTIVE_LEDS,
         LED_RESET_VAL    => LED_RESET_VAL,
         CNT_PRESCALE_VAL => CNT_PRESCALE_VAL
       )
       port map (
         clk              => s00_axi_aclk,
         rst              => s00_axi_aresetn,
         cnt_disp         => cnt_disp,
         data_in          => user_reg0,
         leds             => leds
       );
	-- User logic ends

end arch_imp;