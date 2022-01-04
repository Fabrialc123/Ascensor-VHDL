----------------------------------------------------------------------------------
-- Company: Universidad Complutense de Madrid, Facultad de Informática
-- Engineer: Fabrizio Alcaraz Escobar
-- 
-- Create Date: 10.04.2021 18:20:23
-- Design Name: 
-- Module Name: AscensorFSM - Behavioral
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity AscensorFSM is
  Port ( clkFPGA: in STD_LOGIC;
         reset: in STD_LOGIC;
         piso: in STD_LOGIC_VECTOR (3 downto 0);
         mover: in STD_LOGIC;
         led: out STD_LOGIC_VECTOR (3 downto 0) );
end AscensorFSM;

architecture Behavioral of AscensorFSM is

    component divisorFrec is
        Port ( clkFPGA: in STD_LOGIC;
              reset: in STD_LOGIC;
              clkOUT: out STD_LOGIC );
    end component divisorFrec;
    
    component conv_7seg is
        Port ( x : in  STD_LOGIC_VECTOR (3 downto 0);
               display : out  STD_LOGIC_VECTOR (6 downto 0));
    end component conv_7seg;
    
    type ESTADOS is (S0,S1,S2,S3);
    signal ESTADO, SIG_ESTADO: ESTADOS;
    signal retardo: STD_LOGIC;
    signal piso_elegido_binario, piso_destino: STD_LOGIC_VECTOR (2 downto 0);
begin
div: divisorFrec port map (clkFPGA => clkFPGA, reset => '0', clkOUT => retardo); -- Genera una señal de reloj cada 2 segundos.

-- TRADUCTOR DE SWITCHES A BINARIO
piso_elegido_binario <= "100" when piso(3)='1' else
                        "011" when piso(2)='1' else
                        "010" when piso(1)='1' else
                        "001" when piso(0)='1' else
                        "000";
                        
-------- REGISTRO PARA GUARDAR EL PISO DESTINO --------
p_r_piso_destino:process (reset,mover)
begin 
    if reset = '1' then
        piso_destino <= (others => '0');
    elsif rising_edge(mover) then
        piso_destino <= piso_elegido_binario;
    end if;
end process p_r_piso_destino;
-------------------------------------------------------

p_estado_siguiente: process (reset,retardo)	-- Registro que almacena el estado de la FSM
begin 
    if reset = '1' then
        ESTADO <= S0;
    elsif rising_edge(retardo) then
        ESTADO <= SIG_ESTADO;
    end if;
end process p_estado_siguiente; 

p_ascensor: process (ESTADO, mover)	-- Process combinacional que genera los cambios de estado
begin
	case ESTADO is 
		when S0 =>	-- Se encuentra en la planta baja
			if (piso_destino > 1) then SIG_ESTADO <= S1;          
			else SIG_ESTADO <= S0;
			end if;
		when S1 =>	-- Se encuentra en el primer piso
			if (piso_destino > 2) then SIG_ESTADO <= S2;
			elsif (piso_destino = 2 )then SIG_ESTADO <= S1;
			else SIG_ESTADO <= S0;
			end if;
		when S2 => 	-- Se encuentra en el segundo piso
			if (piso_destino > 3) then SIG_ESTADO <= S3;
			elsif (piso_destino = 3 )then SIG_ESTADO <= S2;
			else SIG_ESTADO <= S1;
			end if;
		when S3 =>	-- Se encuentra en el tercer piso
			if (piso_destino = 4 )then SIG_ESTADO <= S3;
			else SIG_ESTADO <= S2;
			end if;
	   when others =>
			SIG_ESTADO <= S0;
	end case;
end process p_ascensor;

p_salidas_FSM: process(ESTADO)	-- Process que genera la salida de la FSM
begin
	case ESTADO is 
		when S0 =>
			led <= "0001";
		when S1 =>
			led <= "0010";
		when S2 => 
			led <= "0100";
		when S3 =>
			led <= "1000";
		when others =>
			led <= (others => '1');
	end case;
end process p_salidas_FSM;



end Behavioral;
