----------------------------------------------------------------------------------
-- Company: Universidad Complutense de Madrid
-- Student:     Fabrizio Alcaraz Escobar 
-- 
-- Create Date: 05.04.2021 21:48:52
-- Design Name: Divisor de Frecuencia de 100 Mhz a 1 Hz
-- Module Name: divisorFrec - Behavioral

----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity divisorFrec is
   Port ( clkFPGA: in STD_LOGIC;
          reset: in STD_LOGIC;
          clkOUT: out STD_LOGIC );
end divisorFrec;

architecture Behavioral of divisorFrec is
    signal retardo : std_logic_vector (26 downto 0);    -- Acumulamos la cuenta para retardar la salida
    signal clkRetardado : std_logic;
begin
clkOUT <= clkRetardado;

secuencia:process(clkFPGA, reset)
begin
    if (reset='1') then     -- Cuando se da al reset se reinicia el contador del retardo y la señal retardada
        retardo <= (others => '0');
        clkRetardado <= '0';
    elsif rising_edge(clkFPGA) then
        if retardo = "101111101011110000100000000" then -- Esperamos a este número porque es el equivalente de 100 Mhz a Hz
             retardo <= (others => '0');
             clkRetardado <= '1';
        else
            retardo <= retardo + 1;
            clkRetardado <= '0';
        end if;
    end if;
end process secuencia;

end Behavioral;
