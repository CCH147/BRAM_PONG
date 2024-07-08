library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use IEEE.STD_LOGIC_UNSIGNED.ALL;
  use IEEE.MATH_REAL.all;
LIBRARY blk_mem_gen_0;
  use blk_mem_gen_0.all;
  

entity VGA_Controller is
    Port (
        clk   : in STD_LOGIC;
		reset : in STD_LOGIC;
        btn1  : in STD_LOGIC;
        btn2  : in STD_LOGIC;
        btn3  : in STD_LOGIC;
        btn4  : in STD_LOGIC;
        sw    : in STD_LOGIC;
        hsync : out STD_LOGIC;
        vsync : out STD_LOGIC;
        red   : out STD_LOGIC_VECTOR (3 downto 0);
        green : out STD_LOGIC_VECTOR (3 downto 0);
        blue  : out STD_LOGIC_VECTOR (3 downto 0)
   
    );
end VGA_Controller;

architecture Behavioral of VGA_Controller is


    Type mov is ( stop,bounce,
                    left,right
                   );
    signal ballmov : mov;
    -- VGA 640x480 @ 60 Hz timing parameters
    constant hRez        : integer := 640;  -- horizontal resolution
    constant hStartSync  : integer := 656;  -- start of horizontal sync pulse
    constant hEndSync    : integer := 752;  -- end of horizontal sync pulse
    constant hMaxCount   : integer := 800;  -- total pixels per line

    constant vRez        : integer := 480;  -- vertical resolution
    constant vStartSync  : integer := 490;  -- start of vertical sync pulse
    constant vEndSync    : integer := 492;  -- end of vertical sync pulse
    constant vMaxCount   : integer := 525;  -- total lines per frame
    constant sp     : integer := 15;
    signal   rsp     : integer := 3;
    signal ini :std_logic := '0';
    signal   v_speed  : std_logic := '1';
    signal   h_speed  : std_logic := '1';
    --signal   Lwin  : std_logic;
    --signal   Rwin  : std_logic;
    signal   Lscore  : integer := 0;
    signal   Rscore  : integer := 0;
    signal   score   : std_logic_vector(7 downto 0);
    signal hCount : integer := 0;
    signal vCount : integer := 0;
    signal xpos1  : integer := 639;
    signal ypos1  : integer := 220;
    signal xpos2  : integer := 0;
    signal ypos2  : integer := 220;
	signal ballx  : integer := 270;
    signal bally  : integer := 140;
	signal div    : STD_LOGIC_VECTOR(60 downto 0);
	signal fc     : STD_LOGIC;
    signal fc1     : STD_LOGIC;
    signal re      : STD_LOGIC := '0';
    signal lfsr 	    : std_logic_vector (1 downto 0) := "01";
    signal th         : std_logic_vector(1 downto 0);
    signal feedback 	: std_logic;
    signal io         : integer range 0 to 6;   
    signal rand : std_logic;
    signal randsp : integer;
    constant ball_r : integer := 5;
    constant LEFT_BOUND : integer := 0;
    constant RIGHT_BOUND : integer := 640;
    constant UP_BOUND : integer := 0;
    constant DOWN_BOUND : integer := 479;
    signal show : STD_LOGIC;
--Signals for Block RAM
    signal wea : STD_LOGIC_VECTOR(0 DOWNTO 0):="0";
    signal addra : STD_LOGIC_VECTOR(13 DOWNTO 0);
    signal dina : STD_LOGIC_VECTOR(7 DOWNTO 0);
    signal douta : STD_LOGIC_VECTOR(7 DOWNTO 0);

    component blk_mem_gen_0 is
      PORT (
        clka : IN STD_LOGIC;
        wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        addra : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
        dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
      );
    end component;


begin

    U3: blk_mem_gen_0 Port map (clka=>fc, wea=>wea, addra=>addra, dina=>dina, douta=>douta);
    
	process(clk)
	begin
		if reset='1' then 
			div<=(others=>'0');

		elsif rising_edge(clk) then 
			div<=div+1;
		End if;
	end process;
	fc<=div(1);
    fc1<=div(20);
	
    process(fc)
    begin
        if rising_edge(fc) then
            -- Horizontal counter
            if hCount = hMaxCount - 1 then
                hCount <= 0;
                -- Vertical counter
                if vCount = vMaxCount - 1 then
                    vCount <= 0;
                else
                    vCount <= vCount + 1;
                end if;
            else
                hCount <= hCount + 1;
            end if;
        end if;
    end process;
    
    
    lfsr_pr : process (clk) 
    begin
    if (rising_edge(clk)) then
      if (reset = '0') then
        lfsr <= "00";
      else
        lfsr <= lfsr(0) & feedback;
        io <= to_integer(signed(lfsr));
      end if;
    end if;
    end process lfsr_pr;
    randsp <= io + 2;  
    
    process(fc,sw)
    begin 
        if reset = '1' then
            Lscore <= 0;
            Rscore <= 0;
            score <= "00000000";
            ballmov <= stop;
        elsif rising_edge(fc) then
            case ballmov is
                when stop =>
                    ini <= '1';
                    if (sw = '1') then    
                        ini <= '0';
                        ballmov <= bounce;
                    end if;
                when bounce =>
                    if (bally <= (UP_BOUND )) then    
                        v_speed <= '1';            
                    elsif ((bally + 99) >= (DOWN_BOUND )) then
                        v_speed <= '0'; 
                    else  
                        v_speed <= v_speed;  
                    end if;
                    if (((ballx <= (xpos2 + 15) )) and (((bally <= ypos2) and ((bally + 99) >= ypos2)) or (bally >= (ypos2 - 100) and (bally + 99) <= (ypos2 - 100)) or (bally <= (ypos2 - 100) and (bally + 99) >= (ypos2 - 100) and (bally + 99) <= ypos2))) then
                        h_speed <= '1';                             
                    elsif ((((ballx + 99) >= (xpos1 - 15) )) and (((bally <= ypos1) and ((bally + 99) >= ypos1)) or (bally >= (ypos1 - 100) and (bally + 99) <= (ypos1 - 100)) or (bally <= (ypos1 - 100) and (bally + 99) >= (ypos1 - 100) and (bally + 99) <= ypos1))) then
                        h_speed <= '0'; 
                    elsif (ballx <= (LEFT_BOUND )) then
                        ballmov <= right;
                    elsif (ballx + 99 >= (RIGHT_BOUND )) then
                        ballmov <= left;
                    else  
                        h_speed <= h_speed;   
                    end if;
                when right =>
                    if (Rscore >= 3) then
                        Lscore <= 0;
                        Rscore <= 0;
                        ballmov <= stop;
                    else
                        Rscore <= Rscore + 1;
                        ballmov <= stop;
                    --score <= Rscore(3 downto 0) & Lscore(3 downto 0);
                    end if;
                when left =>
                    if(Lscore >= 3) then
                        Lscore <= 0;
                        Rscore <= 0;
                        ballmov <= stop;
                    else
                        Lscore <= Lscore + 1;
                    --score <= Rscore(3 downto 0) & Lscore(3 downto 0);
                        ballmov <= stop;
                    end if;
            end case;    
                   
        end if; 
    end process;
    --Lwin <= '1' when (ballx >= (RIGHT_BOUND - ball_r)) else '0';
    --Rwin <= '1' when (ballx <= (LEFT_BOUND + ball_r)) else '0';
    
            --elsif ((ballx >= (xpos1 - ball_r)) and (bally >= ypos1) and (bally <= ypos1 - 100))  then
            --   Lwin <= '1';
            --elsif ((ballx >= (xpos2 + ball_r)) and (bally >= ypos2) and (bally <= ypos2 - 100))  then
            --   Rwin <= '1';            
            --if (sw = '1') then
              --  Rwin <= '0';
                --Lwin <= '0';
                --v_speed <= '1';
                --h_speed <= '1';
                --ballx <= 319;
                --bally <= 239;
            --end if;

    process(fc1)
    begin
        if rising_edge(fc1) then
             if (v_speed = '0') then
                    bally <= bally - rsp;  
             else 
                    bally <= bally + rsp;
             end if;
             if (h_speed = '1') then
                    ballx <= ballx + rsp;  
             else 
                    ballx <= ballx - rsp;  
             end if;
             if (ini = '1') then
                 ballx <= 320;
                 bally <= 240;
             end if;
        end if;
    end process; 
	
    process(fc1,btn1,btn2,btn3,btn4)
    begin
            if rising_edge(fc1) then
                if (btn1 = '1' and (ypos1 <= DOWN_BOUND - 15))then
                    ypos1 <= ypos1 + sp;
                end if;
                if (btn2 = '1' and ((ypos1) >= 100 + 15) ) then
                    ypos1 <= ypos1 - sp;
                end if;
                if (btn3 = '1' and (ypos2 <= DOWN_BOUND - 15))then
                    ypos2 <= ypos2 + sp;
                end if;
                if (btn4 = '1' and ((ypos2) >= 100 + 15) ) then
                    ypos2 <= ypos2 - sp;
                end if;
            end if;
    end process;

    -- Generate synchronization signals
    hsync <= '0' when (hCount >= hStartSync and hCount < hEndSync) else '1';
    vsync <= '0' when (vCount >= vStartSync and vCount < vEndSync) else '1';
    --show <= '1' when(hCount > 1 and hCount < 101 and vCount > 10 and vCount < 111) else '0';
    -- Generate RGB signals
    process(fc,hCount, vCount)
    begin
        if reset='1' then 
			addra<=(others=>'0');
			red <= "0000";
            green <= "0000";
            blue <= "0000";

    	elsif rising_edge(fc) then
            if (hCount <= hRez and vCount <= vRez) then
            
                if (hCount >= ballx and hCount <= (ballx + 99) and vCount >= bally and vCount <= (bally + 99)) then
                    red<="1111" - douta(7 downto 4); 
                    green<="1111" - douta(7 downto 4); 
                    blue<="1111" - douta(7 downto 4);
                    addra<=addra + 1;
                
                elsif ((hCount = (ballx + 99 + 1) and vCount = (bally + 99 + 1)))then
                    addra<=(others=>'0');
                else 
                    red <= "0000";
                    green <= "0000";
                    blue <= "0000";
                end if;
                
                if (hCount >= (xpos2) and hCount <= (xpos2 + 15) and vCount >= (ypos2 - 100) and vCount <= (ypos2) )then
                    red <= "1111";  -- Red stripe
                end if;
                if (hCount >= (xpos1 -15) and hCount <= xpos1 and vCount >= (ypos1 - 100) and vCount <= (ypos1) )then
                    green <= "1111";
                end if;
                
                if (Lscore >= 1  and hCount >= 20 and hCount <= 25 and vCount >= 425 and vCount <= 430) then
                    red <= "1111";
                end if;
                if (Lscore >= 2  and hCount >= (25 + 5 ) and hCount <= (25 + 5 + 5) and vCount >= 425 and vCount <= 430) then
                    red <= "1111";
                end if;
                if (Lscore >= 3  and hCount >= (25 + 5 + 5 + 5) and hCount <= (25 + 5 + 5 + 5 + 5) and vCount >= 425 and vCount <= 430) then
                    red <= "1111";
                end if;
                if (Rscore >= 1  and hCount >= 610 and hCount <= 615 and vCount >= 425 and vCount <= 430) then
                    green <= "1111";
                end if;
                if (Rscore >= 2  and hCount >= 600 and hCount <= 600 + 5 and vCount >= 425 and vCount <= 430) then
                    green <= "1111";
                end if;
                if (Rscore >= 3  and hCount >= 590 and hCount <= 595 and vCount >= 425 and vCount <= 430) then
                    green <= "1111";
                end if;
                
            else
                red <= "0000";
                green <= "0000";
                blue <= "0000";
                --addra<=(others=>'0');
            
            end if;
		end if;
    end process;
    
    --process(fc,reset)
    --begin
      --  if(reset = '1')then
        --    addra <= "000000000000";
        --elsif(ea = "1")then
          --  if(addra >= "100111000100")then
            --    addra <= "000000000000";
            --else
              --  addra <= addra + 1;
            --end if;
       -- end if;
    --end process;

end Behavioral;
