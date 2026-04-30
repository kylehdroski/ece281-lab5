--+----------------------------------------------------------------------------
--|
--| NAMING CONVENSIONS :
--|
--|    xb_<port name>           = off-chip bidirectional port ( _pads file )
--|    xi_<port name>           = off-chip input port         ( _pads file )
--|    xo_<port name>           = off-chip output port        ( _pads file )
--|    b_<port name>            = on-chip bidirectional port
--|    i_<port name>            = on-chip input port
--|    o_<port name>            = on-chip output port
--|    c_<signal name>          = combinatorial signal
--|    f_<signal name>          = synchronous signal
--|    ff_<signal name>         = pipeline stage (ff_, fff_, etc.)
--|    <signal name>_n          = active low signal
--|    w_<signal name>          = top level wiring signal
--|    g_<generic name>         = generic
--|    k_<constant name>        = constant
--|    v_<variable name>        = variable
--|    sm_<state machine type>  = state machine type definition
--|    s_<signal name>          = state name
--|
--+----------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;


entity top_basys3 is
    port(
        -- inputs
        clk     :   in std_logic; -- native 100MHz FPGA clock
        sw      :   in std_logic_vector(7 downto 0); -- operands and opcode
        btnU    :   in std_logic; -- reset
        btnC    :   in std_logic; -- fsm cycle
        
        -- outputs
        led :   out std_logic_vector(15 downto 0);
        -- 7-segment display segments (active-low cathodes)
        seg :   out std_logic_vector(6 downto 0);
        -- 7-segment display active-low enables (anodes)
        an  :   out std_logic_vector(3 downto 0)
    );
end top_basys3;

architecture top_basys3_arch of top_basys3 is 
  component button_debounce is
    Port ( CLK: in STD_LOGIC;
           reset: in STD_LOGIC;
           button: in STD_LOGIC;
           result: out STD_LOGIC);
  end component;
  
  component sevenseg_decoder is
     Port ( i_Hex : in STD_LOGIC_VECTOR (3 downto 0);
            o_seg_n : out STD_LOGIC_VECTOR (6 downto 0));
  end component;
  
  component clock_divider is
     generic (k_DIV : natural := 2);
     Port (i_clk : in STD_LOGIC;
           i_reset : in STD_LOGIC;
           o_clk : out STD_LOGIC);
  end component;
  
  component controller_fsm is
      Port ( i_reset : in STD_LOGIC;
             i_adv : in STD_LOGIC;
             i_clk : in STD_LOGIC;
             o_cycle : out STD_LOGIC_VECTOR (3 downto 0));
  end component;
  
  component ALU is 
       Port ( i_A : in STD_LOGIC_VECTOR (7 downto 0);
              i_B : in STD_LOGIC_VECTOR (7 downto 0);
              i_op : in STD_LOGIC_VECTOR (2 downto 0);
              o_result : out STD_LOGIC_VECTOR (7 downto 0);
              o_flags : out STD_LOGIC_VECTOR (3 downto 0));
   end component;
   
   component twos_comp is
       Port ( i_bin : in STD_LOGIC_VECTOR (7 downto 0);
              o_sign : out STD_LOGIC;
              o_hund : out STD_LOGIC_VECTOR (3 downto 0);
              o_tens : out STD_LOGIC_VECTOR (3 downto 0);
              o_ones : out STD_LOGIC_VECTOR (3 downto 0));
   end component;
   
   component TDM4 is
       generic (k_WIDTH : natural := 4);
       Port ( i_clk : in STD_LOGIC;
              i_D3 : in STD_LOGIC_VECTOR (3 downto 0);
              i_D2 : in STD_LOGIC_VECTOR (3 downto 0);
              i_D1 : in STD_LOGIC_VECTOR (3 downto 0);
              i_D0 : in STD_LOGIC_VECTOR (3 downto 0);
              o_data : out STD_LOGIC_VECTOR (3 downto 0);
              o_sel : out STD_LOGIC_VECTOR (3 downto 0));
   end component;
	-- declare components and signals
    signal w_clk_divided : STD_LOGIC;
    signal w_btnC_debounced : STD_LOGIC;
    signal w_cycle : STD_LOGIC_VECTOR (3 downto 0);
    signal w_A : STD_LOGIC_VECTOR (7 downto 0);
    signal w_B : STD_LOGIC_VECTOR (7 downto 0);
    signal w_result : STD_LOGIC_VECTOR (7 downto 0);
    signal w_flags : STD_LOGIC_VECTOR (3 downto 0);
    signal w_sign : STD_LOGIC;
    signal w_hund : STD_LOGIC_VECTOR (3 downto 0);
    signal w_tens : STD_LOGIC_VECTOR (3 downto 0);
    signal w_ones : STD_LOGIC_VECTOR (3 downto 0);
    signal w_tdm_data : STD_LOGIC_VECTOR (3 downto 0);
    signal w_tdm_sel : STD_LOGIC_VECTOR (3 downto 0);
    signal w_seg_n : STD_LOGIC_VECTOR (6 downto 0);
    signal w_bin_in : STD_LOGIC_VECTOR (7 downto 0);
    signal w_sign_digit : STD_LOGIC_VECTOR (3 downto 0);
  
begin
	-- PORT MAPS ----------------------------------------
    clkdiv_inst : clock_divider
        generic map (k_DIV => 25000000)
        port map (
            i_clk => clk,
            i_reset => btnU,
            o_clk => w_clk_divided
        );
	
	debounce_inst : button_debounce
	   port map (
	       CLK => clk,
	       reset => btnU,
	       button => btnC,
	       result => w_btnC_debounced
	   );
	   
	fsm_inst : controller_fsm
	   port map (
	       i_reset => btnU,
	       i_adv => w_btnC_debounced,
	       i_clk => clk,
	       o_cycle => w_cycle
	   );
	   
	alu_inst : ALU
	   port map (
	       i_A => w_A,
	       i_B => w_B,
	       i_op => sw(2 downto 0),
	       o_result => w_result,
	       o_flags => w_flags
	   );
	
	twos_inst : twos_comp
	   port map (
	       i_bin => w_bin_in,
	       o_sign => w_sign,
	       o_hund => w_hund,
	       o_tens => w_tens,
	       o_ones => w_ones
	   );
	   
	tdm_inst : TDM4
	   generic map ( k_WIDTH => 4)
	   port map (
	       i_clk => w_clk_divided,
	       i_D3 => w_sign_digit,
	       i_D2 => w_hund,
	       i_D1 => w_tens,
	       i_D0 => w_ones,
	       o_data => w_tdm_data,
	       o_sel => w_tdm_sel
	   );
	
	seg_inst : sevenseg_decoder
	   port map (
	       i_Hex => w_tdm_data,
	       o_seg_n => w_seg_n
	   );
	-- CONCURRENT STATEMENTS ----------------------------
	w_sign_digit <= x"F" when w_sign = '1' else x"B";
	
	reg_proc : process(clk)
	begin
	   if rising_edge(clk) then
	       if btnU = '1' then
	           w_A <= (others => '0');
	           w_B <= (others => '0');
	       elsif w_cycle(1) = '1' then
	           w_A <= sw;
	       elsif w_cycle(2) = '1' then
	           w_B <= sw;
	       end if;
	   end if;
	end process;
	
	w_bin_in <= sw when w_cycle(1) = '1' else
	            sw when w_cycle(2) = '1' else
	            w_result when w_cycle(3) = '1' else
	            (others => '0');
	
	an <= w_tdm_sel when w_cycle(0) = '0' else "1111";
	
	led(3 downto 0) <= w_cycle;
	led(15 downto 12) <= w_flags;
	led(11 downto 4) <= (others => '0');
	
	seg <= w_seg_n;
	
end top_basys3_arch;
