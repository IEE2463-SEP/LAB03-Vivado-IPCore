----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity LED_Controller is
  generic (
          NUM_LEDS	      : integer	:= 4;         
          NUM_ACTIVE_LEDS	: integer	:= 4; 
          -- Reset value that LEDs are set to and reset value of counter
          LED_RESET_VAL	  : integer	:= 16#0#; -- valor 57, en sistema numerico de base 16 (es decir hexa). Ver p.180 https://edg.uchicago.edu/~tang/VHDLref.pdf
          -- Counter prescale value so counting can be visible in hardware
          CNT_PRESCALE_VAL: integer	:= 125_000_000 -- assuming 125MHz, one second count
       );
  Port (  clk      : in  std_logic;
          rst      : in  std_logic;         
          cnt_disp : in  std_logic;
          data_in  : in  std_logic_vector (31 downto 0);
          leds     : out std_logic_vector (NUM_LEDS-1 downto 0)
       );
end LED_Controller;

architecture Behavioral of LED_Controller is
	signal count	    : integer;
	signal cnt_pre	  : integer;
	signal cnt_pre_en	: std_logic;

begin
  -- Simple LED controller
  -- Based on the input signal cnt_dips, the LEDs display
  -- cnt_dips == '1' - A hardware counter output.
  -- cnt_dips == '0' - The value of the data_in siganl.

  LED_CTRL:	process (clk)

	begin
	  if (rising_edge(clk)) then 
	    if (rst = '0') then
	    --to_unsigned(A,B) converts integer A into std_logic and the result has length B.
	      leds(NUM_ACTIVE_LEDS-1 downto 0) <= std_logic_vector(to_unsigned(LED_RESET_VAL, NUM_ACTIVE_LEDS));
	    else
	      if (cnt_disp = '1') then
          -- display current count
	        leds(NUM_ACTIVE_LEDS-1 downto 0) <= std_logic_vector(to_unsigned(count, NUM_ACTIVE_LEDS)); 
	      else
	        -- display value on datain
          leds(NUM_ACTIVE_LEDS-1 downto 0) <= data_in(NUM_ACTIVE_LEDS-1 downto 0);
	      end if;
	    end if;

      -- Determine how many LEDs are active as LSB's.
      -- Inactive MSB's are forced to all '1's.
      -- if the number of active LEDs is the same as the number of LEDs,
      -- then none of them need to be forced on.
	    if (NUM_LEDS /= NUM_ACTIVE_LEDS) then
	      leds(NUM_LEDS-1 downto NUM_ACTIVE_LEDS) <= (others => '1');
	    end if;

	  end if;
	end process; 

  -- Prescale the counting clock so you can see the LEDs blink.
  -- The signal cnt_pre_en drives the counter process.
  PRESCALE:	process (clk)
	begin
	  if (rising_edge(clk)) then 
	    if (rst = '0') then
	      cnt_pre     <= 0;
	      cnt_pre_en  <= '0';
	    else
	      if (cnt_pre = CNT_PRESCALE_VAL) then
	          cnt_pre <= 0;
            cnt_pre_en  <= '1';
	      else
	          cnt_pre <= cnt_pre + 1;
            cnt_pre_en  <= '0';
	      end if;
	    end if;
	  end if;
	end process; 

  -- Simple counter that counts on the prescaler ouput signal, cnt_pre_en.
  -- Counter counts from LED_RESET_VAL to NUM_ACTIVE_LEDS, the width of active LEDs
  COUNTER:	process (clk)
	begin
	  if (rising_edge(clk)) then 
	    if (rst = '0') then
	      count <= 0;
	    else
	      if (count = (2 ** NUM_ACTIVE_LEDS) - 1) then
	          count <= LED_RESET_VAL;
	      elsif (cnt_pre_en = '1') then
	          count <= count + 1;
	      end if;
	    end if;
	  end if;
	end process; 

end Behavioral;