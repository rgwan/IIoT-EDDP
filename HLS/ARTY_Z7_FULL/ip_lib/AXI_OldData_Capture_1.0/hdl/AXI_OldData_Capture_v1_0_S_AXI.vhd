library ieee;
use ieee.STD_LOGIC_1164.all;
use ieee.STD_LOGIC_arith.all;
use ieee.STD_LOGIC_unsigned.all;

entity AXI_OldData_Capture_v1_0_S_AXI is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line

		-- Width of S_AXI data bus
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		-- Width of S_AXI address bus
		C_S_AXI_ADDR_WIDTH	: integer	:= 6
	);
	port (
		-- Users to add ports here
		do_read				: out STD_LOGIC;
		Core_Status_0		: in  STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH-1 downto 0);
		Core_Control_1		: out STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH-1 downto 0);
		Common_Control		: out STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH-1 downto 0);
		Common_Status		: in  STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH-1 downto 0);

        base_address 		: out STD_LOGIC_VECTOR(31 downto 0);
        transfer_size 		: out STD_LOGIC_VECTOR(31 downto 0);
        pretrigger_length	: out STD_LOGIC_VECTOR(31 downto 0);         
		command_tvalid		: out STD_LOGIC;
		command_tdata		: out STD_LOGIC_VECTOR(31 downto 0);
		trigger_out			: out STD_LOGIC;
		core_debug			: in  STD_LOGIC_VECTOR(31 downto 0);
        trigger_delay 		: out STD_LOGIC_VECTOR(31 downto 0);

		manual_fetch		: out STD_LOGIC;
		fetch_data			: in  STD_LOGIC_VECTOR(63 downto 0);
		timestamp			: in  STD_LOGIC_VECTOR(63 downto 0);
		
		-- User ports ends
		-- Do not modify the ports beyond this line

		-- Global Clock Signal
		S_AXI_ACLK	: in STD_LOGIC;
		-- Global Reset Signal. This Signal is Active LOW
		S_AXI_ARESETN	: in STD_LOGIC;
		-- Write address (issued by master, acceped by Slave)
		S_AXI_AWADDR	: in STD_LOGIC_VECTOR(C_S_AXI_ADDR_WIDTH-1 downto 0);
		-- Write channel Protection type. This signal indicates the
    		-- privilege and security level of the transaction, and whether
    		-- the transaction is a data access or an instruction access.
		S_AXI_AWPROT	: in STD_LOGIC_VECTOR(2 downto 0);
		-- Write address valid. This signal indicates that the master signaling
    		-- valid write address and control information.
		S_AXI_AWVALID	: in STD_LOGIC;
		-- Write address ready. This signal indicates that the slave is ready
    		-- to accept an address and associated control signals.
		S_AXI_AWREADY	: out STD_LOGIC;
		-- Write data (issued by master, acceped by Slave) 
		S_AXI_WDATA	: in STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH-1 downto 0);
		-- Write strobes. This signal indicates which byte lanes hold
    		-- valid data. There is one write strobe bit for each eight
    		-- bits of the write data bus.    
		S_AXI_WSTRB	: in STD_LOGIC_VECTOR((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		-- Write valid. This signal indicates that valid write
    		-- data and strobes are available.
		S_AXI_WVALID	: in STD_LOGIC;
		-- Write ready. This signal indicates that the slave
    		-- can accept the write data.
		S_AXI_WREADY	: out STD_LOGIC;
		-- Write response. This signal indicates the status
    		-- of the write transaction.
		S_AXI_BRESP	: out STD_LOGIC_VECTOR(1 downto 0);
		-- Write response valid. This signal indicates that the channel
    		-- is signaling a valid write response.
		S_AXI_BVALID	: out STD_LOGIC;
		-- Response ready. This signal indicates that the master
    		-- can accept a write response.
		S_AXI_BREADY	: in STD_LOGIC;
		-- Read address (issued by master, acceped by Slave)
		S_AXI_ARADDR	: in STD_LOGIC_VECTOR(C_S_AXI_ADDR_WIDTH-1 downto 0);
		-- Protection type. This signal indicates the privilege
    		-- and security level of the transaction, and whether the
    		-- transaction is a data access or an instruction access.
		S_AXI_ARPROT	: in STD_LOGIC_VECTOR(2 downto 0);
		-- Read address valid. This signal indicates that the channel
    		-- is signaling valid read address and control information.
		S_AXI_ARVALID	: in STD_LOGIC;
		-- Read address ready. This signal indicates that the slave is
    		-- ready to accept an address and associated control signals.
		S_AXI_ARREADY	: out STD_LOGIC;
		-- Read data (issued by slave)
		S_AXI_RDATA	: out STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH-1 downto 0);
		-- Read response. This signal indicates the status of the
    		-- read transfer.
		S_AXI_RRESP	: out STD_LOGIC_VECTOR(1 downto 0);
		-- Read valid. This signal indicates that the channel is
    		-- signaling the required read data.
		S_AXI_RVALID	: out STD_LOGIC;
		-- Read ready. This signal indicates that the master can
    		-- accept the read data and response information.
		S_AXI_RREADY	: in STD_LOGIC
	);
end AXI_OldData_Capture_v1_0_S_AXI;
--------------------------------------------------------------------------------
architecture arch_imp of AXI_OldData_Capture_v1_0_S_AXI is
--------------------------------------------------------------------------------
-- Constants
constant Low  		: STD_LOGIC	:= '0';
constant High 		: STD_LOGIC	:= '1';
-- AXI4LITE signals
signal axi_awaddr	: STD_LOGIC_VECTOR(C_S_AXI_ADDR_WIDTH-1 downto 0);
signal axi_awready	: STD_LOGIC;
signal axi_wready	: STD_LOGIC;
signal axi_bresp	: STD_LOGIC_VECTOR(1 downto 0);
signal axi_bvalid	: STD_LOGIC;
signal axi_araddr	: STD_LOGIC_VECTOR(C_S_AXI_ADDR_WIDTH-1 downto 0);
signal axi_arready	: STD_LOGIC;
signal axi_rdata	: STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH-1 downto 0);
signal axi_rresp	: STD_LOGIC_VECTOR(1 downto 0);
signal axi_rvalid	: STD_LOGIC;
-- Example-specific design signals
-- local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
-- ADDR_LSB is used for addressing 32/64 bit registers/memories
-- ADDR_LSB = 2 for 32 bits (n downto 2)
-- ADDR_LSB = 3 for 64 bits (n downto 3)
constant ADDR_LSB  : integer := (C_S_AXI_DATA_WIDTH/32)+ 1;
constant OPT_MEM_ADDR_BITS : integer := 3;
------------------------------------------------
---- Signals for user logic register space example
--------------------------------------------------
---- Number of Slave Registers 16
signal slv_reg0			: STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH-1 downto 0);
signal slv_reg1			: STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH-1 downto 0);
signal slv_reg2			: STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH-1 downto 0);
signal slv_reg3			: STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH-1 downto 0);
signal slv_reg4			: STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH-1 downto 0);
signal slv_reg5			: STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH-1 downto 0);
signal slv_reg6			: STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH-1 downto 0);
signal slv_reg7			: STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH-1 downto 0);
signal slv_reg8			: STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH-1 downto 0);
signal slv_reg9			: STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH-1 downto 0);
signal slv_reg10		: STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH-1 downto 0);
signal slv_reg11		: STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH-1 downto 0);
signal slv_reg12		: STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH-1 downto 0);
signal slv_reg13		: STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH-1 downto 0);
signal slv_reg14		: STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH-1 downto 0);
signal slv_reg15		: STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH-1 downto 0);
signal slv_reg_rden		: STD_LOGIC;
signal slv_reg_wren		: STD_LOGIC;
signal reg_data_out		: STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH-1 downto 0);
signal byte_index		: integer;
signal reg9_wr			: STD_LOGIC;
signal trigger_out_sr	: STD_LOGIC_VECTOR(7 downto 0);
signal control_reg		: STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH-1 downto 0);
--------------------------------------------------------------------------------
begin
--------------------------------------------------------------------------------
-- I/O Connections assignments
S_AXI_AWREADY	<= axi_awready;
S_AXI_WREADY	<= axi_wready;
S_AXI_BRESP		<= axi_bresp;
S_AXI_BVALID	<= axi_bvalid;
S_AXI_ARREADY	<= axi_arready;
S_AXI_RDATA		<= axi_rdata;
S_AXI_RRESP		<= axi_rresp;
S_AXI_RVALID	<= axi_rvalid;
-- Implement axi_awready generation
-- axi_awready is asserted for one S_AXI_ACLK clock cycle when both
-- S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is
-- de-asserted when reset is low.

	process (S_AXI_ACLK)
	begin
		if rising_edge(S_AXI_ACLK) then 
			if S_AXI_ARESETN = '0' then
				axi_awready <= '0';
			else
				if (axi_awready = '0' and S_AXI_AWVALID = '1' and S_AXI_WVALID = '1') then
					-- slave is ready to accept write address when
					-- there is a valid write address and write data
					-- on the write address and data bus. This design 
					-- expects no outstanding transactions. 
					axi_awready <= '1';
				else
					axi_awready <= '0';
				end if;
			end if;
		end if;
	end process;

	-- Implement axi_awaddr latching
	-- This process is used to latch the address when both 
	-- S_AXI_AWVALID and S_AXI_WVALID are valid. 

	process (S_AXI_ACLK)
	begin
		if rising_edge(S_AXI_ACLK) then 
			if S_AXI_ARESETN = '0' then
				axi_awaddr <= (others => '0');
			else
				if (axi_awready = '0' and S_AXI_AWVALID = '1' and S_AXI_WVALID = '1') then
					-- Write Address latching
					axi_awaddr <= S_AXI_AWADDR;
				end if;
			end if;
		end if;                   
	end process; 

	-- Implement axi_wready generation
	-- axi_wready is asserted for one S_AXI_ACLK clock cycle when both
	-- S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_wready is 
	-- de-asserted when reset is low. 

	process (S_AXI_ACLK)
	begin
		if rising_edge(S_AXI_ACLK) then 
			if S_AXI_ARESETN = '0' then
				axi_wready <= '0';
			else
				if (axi_wready = '0' and S_AXI_WVALID = '1' and S_AXI_AWVALID = '1') then
						-- slave is ready to accept write data when 
						-- there is a valid write address and write data
						-- on the write address and data bus. This design 
						-- expects no outstanding transactions.           
						axi_wready <= '1';
				else
					axi_wready <= '0';
				end if;
			end if;
		end if;
	end process; 

	-- Implement memory mapped register select and write logic generation
	-- The write data is accepted and written to memory mapped registers when
	-- axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
	-- select byte enables of slave registers while writing.
	-- These registers are cleared when reset (active low) is applied.
	-- Slave register write enable is asserted when valid address and data are available
	-- and the slave is ready to accept the write address and write data.
	slv_reg_wren <= axi_wready and S_AXI_WVALID and axi_awready and S_AXI_AWVALID ;

	process (S_AXI_ACLK)
	variable loc_addr : STD_LOGIC_VECTOR(OPT_MEM_ADDR_BITS downto 0); 
	begin
		if rising_edge(S_AXI_ACLK) then 
			if S_AXI_ARESETN = '0' then
				--slv_reg0 <= (others => '0');
				slv_reg1 <= (others => '0');
				slv_reg2 <= (others => '0');
				slv_reg3 <= (others => '0');
				slv_reg4 <= (others => '0');
				slv_reg5 <= (others => '0');
				slv_reg6 <= (others => '0');
				slv_reg7 <= (others => '0');
				slv_reg8 <= (others => '0');
				slv_reg9 <= (others => '0');
				slv_reg10 <= (others => '0');
				slv_reg11 <= (others => '0');
				slv_reg12 <= (others => '0');
				slv_reg13 <= (others => '0');
				slv_reg14 <= (others => '0');
				slv_reg15 <= (others => '0');
				reg9_wr	<= '0';
				trigger_out_sr	<= (others => '0');
			else
				loc_addr := axi_awaddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB);
				if (slv_reg_wren = '1') then
					case loc_addr is
						
--						when b"0000" =>
--							for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
--								if ( S_AXI_WSTRB(byte_index) = '1' ) then
--									-- Respective byte enables are asserted as per write strobes                   
--									-- slave registor 0
--									slv_reg0(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
--								end if;
--							end loop;
							
						when b"0001" =>
							for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
								if ( S_AXI_WSTRB(byte_index) = '1' ) then
									-- Respective byte enables are asserted as per write strobes                   
									-- slave registor 1
									slv_reg1(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
									trigger_out_sr	<= (others => S_AXI_WDATA(0));
								end if;
							end loop;
						when b"0010" =>
							for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
								if ( S_AXI_WSTRB(byte_index) = '1' ) then
									-- Respective byte enables are asserted as per write strobes                   
									-- slave registor 2
									slv_reg2(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
								end if;
							end loop;
						when b"0011" =>
							for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
								if ( S_AXI_WSTRB(byte_index) = '1' ) then
									-- Respective byte enables are asserted as per write strobes                   
									-- slave registor 3
									slv_reg3(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
								end if;
							end loop;
						when b"0100" =>
							for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
								if ( S_AXI_WSTRB(byte_index) = '1' ) then
									-- Respective byte enables are asserted as per write strobes                   
									-- slave registor 4
									slv_reg4(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
								end if;
							end loop;
						when b"0101" =>
							for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
								if ( S_AXI_WSTRB(byte_index) = '1' ) then
									-- Respective byte enables are asserted as per write strobes                   
									-- slave registor 5
									slv_reg5(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
								end if;
							end loop;
						when b"0110" =>
							for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
								if ( S_AXI_WSTRB(byte_index) = '1' ) then
									-- Respective byte enables are asserted as per write strobes                   
									-- slave registor 6
									slv_reg6(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
								end if;
							end loop;
						when b"0111" =>
							for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
								if ( S_AXI_WSTRB(byte_index) = '1' ) then
									-- Respective byte enables are asserted as per write strobes                   
									-- slave registor 7
									slv_reg7(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
								end if;
							end loop;
						when b"1000" =>
							for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
								if ( S_AXI_WSTRB(byte_index) = '1' ) then
									-- Respective byte enables are asserted as per write strobes                   
									-- slave registor 8
									slv_reg8(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
								end if;
							end loop;
						when b"1001" =>
							for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
								if ( S_AXI_WSTRB(byte_index) = '1' ) then
									-- Respective byte enables are asserted as per write strobes                   
									-- slave registor 9
									slv_reg9(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
									reg9_wr		<= '1';
								end if;
							end loop;
						when b"1010" =>
							for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
								if ( S_AXI_WSTRB(byte_index) = '1' ) then
									-- Respective byte enables are asserted as per write strobes                   
									-- slave registor 10
									slv_reg10(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
								end if;
							end loop;
						when b"1011" =>
							for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
								if ( S_AXI_WSTRB(byte_index) = '1' ) then
									-- Respective byte enables are asserted as per write strobes                   
									-- slave registor 11
									slv_reg11(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
								end if;
							end loop;
						when b"1100" =>
							for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
								if ( S_AXI_WSTRB(byte_index) = '1' ) then
									-- Respective byte enables are asserted as per write strobes                   
									-- slave registor 12
									slv_reg12(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
								end if;
							end loop;
						when b"1101" =>
							for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
								if ( S_AXI_WSTRB(byte_index) = '1' ) then
									-- Respective byte enables are asserted as per write strobes                   
									-- slave registor 13
									slv_reg13(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
								end if;
							end loop;
						when b"1110" =>
							for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
								if ( S_AXI_WSTRB(byte_index) = '1' ) then
									-- Respective byte enables are asserted as per write strobes                   
									-- slave registor 14
									slv_reg14(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
								end if;
							end loop;
						when b"1111" =>
							for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
								if ( S_AXI_WSTRB(byte_index) = '1' ) then
									-- Respective byte enables are asserted as per write strobes                   
									-- slave registor 15
									slv_reg15(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
								end if;
							end loop;
						when others =>
							--slv_reg0 <= slv_reg0;
							slv_reg1 <= slv_reg1;
							slv_reg2 <= slv_reg2;
							slv_reg3 <= slv_reg3;
							slv_reg4 <= slv_reg4;
							slv_reg5 <= slv_reg5;
							slv_reg6 <= slv_reg6;
							slv_reg7 <= slv_reg7;
							slv_reg8 <= slv_reg8;
							slv_reg9 <= slv_reg9;
							slv_reg10 <= slv_reg10;
							slv_reg11 <= slv_reg11;
							slv_reg12 <= slv_reg12;
							slv_reg13 <= slv_reg13;
							slv_reg14 <= slv_reg14;
							slv_reg15 <= slv_reg15;
							reg9_wr		<= '0';
							trigger_out_sr	<= trigger_out_sr(6 downto 0) & '0';
					end case;
				else
					reg9_wr			<= '0';
					trigger_out_sr	<= trigger_out_sr(6 downto 0) & '0';
				end if;
			end if;
		end if;                   
	end process; 

process (S_AXI_ACLK)
variable loc_addr : STD_LOGIC_VECTOR(OPT_MEM_ADDR_BITS downto 0); 
begin
	if rising_edge(S_AXI_ACLK) then 
		if S_AXI_ARESETN = '0' then
			control_reg		<= (others => '0');
		else
			if((slv_reg_wren = '1') and (axi_awaddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB) = "0001"))then
				control_reg		<= S_AXI_WDATA;
			elsif(Core_Status_0(6) = '1')then
				control_reg(1)	<= '0';		-- Disable transfer
			end if;
		end if;
	end if;
end process;
	
	trigger_out	<= trigger_out_sr(7);
	-- Implement write response logic generation
	-- The write response and response valid signals are asserted by the slave 
	-- when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.  
	-- This marks the acceptance of address and indicates the status of 
	-- write transaction.

	process (S_AXI_ACLK)
	begin
		if rising_edge(S_AXI_ACLK) then 
			if S_AXI_ARESETN = '0' then
				axi_bvalid  <= '0';
				axi_bresp   <= "00"; --need to work more on the responses
			else
				if (axi_awready = '1' and S_AXI_AWVALID = '1' and axi_wready = '1' and S_AXI_WVALID = '1' and axi_bvalid = '0'  ) then
					axi_bvalid <= '1';
					axi_bresp  <= "00"; 
				elsif (S_AXI_BREADY = '1' and axi_bvalid = '1') then   --check if bready is asserted while bvalid is high)
					axi_bvalid <= '0';                                 -- (there is a possibility that bready is always asserted high)
				end if;
			end if;
		end if;                   
	end process; 

	-- Implement axi_arready generation
	-- axi_arready is asserted for one S_AXI_ACLK clock cycle when
	-- S_AXI_ARVALID is asserted. axi_awready is 
	-- de-asserted when reset (active low) is asserted. 
	-- The read address is also latched when S_AXI_ARVALID is 
	-- asserted. axi_araddr is reset to zero on reset assertion.

	process (S_AXI_ACLK)
	begin
		if rising_edge(S_AXI_ACLK) then 
			if S_AXI_ARESETN = '0' then
				axi_arready <= '0';
				axi_araddr  <= (others => '1');
			else
				if (axi_arready = '0' and S_AXI_ARVALID = '1') then
					-- indicates that the slave has acceped the valid read address
					axi_arready <= '1';
					-- Read Address latching 
					axi_araddr  <= S_AXI_ARADDR;           
				else
					axi_arready <= '0';
				end if;
			end if;
		end if;                   
	end process; 

	-- Implement axi_arvalid generation
	-- axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both 
	-- S_AXI_ARVALID and axi_arready are asserted. The slave registers 
	-- data are available on the axi_rdata bus at this instance. The 
	-- assertion of axi_rvalid marks the validity of read data on the 
	-- bus and axi_rresp indicates the status of read transaction.axi_rvalid 
	-- is deasserted on reset (active low). axi_rresp and axi_rdata are 
	-- cleared to zero on reset (active low).  
	process (S_AXI_ACLK)
	begin
		if rising_edge(S_AXI_ACLK) then
			if S_AXI_ARESETN = '0' then
				axi_rvalid <= '0';
				axi_rresp  <= "00";
			else
				if (axi_arready = '1' and S_AXI_ARVALID = '1' and axi_rvalid = '0') then
					-- Valid read data is available at the read data bus
					axi_rvalid <= '1';
					axi_rresp  <= "00"; -- 'OKAY' response
				elsif (axi_rvalid = '1' and S_AXI_RREADY = '1') then
					-- Read data is accepted by the master
					axi_rvalid <= '0';
				end if;            
			end if;
		end if;
	end process;

	-- Implement memory mapped register select and read logic generation
	-- Slave register read enable is asserted when valid address is available
	-- and the slave is ready to accept the read address.
	slv_reg_rden <= axi_arready and S_AXI_ARVALID and (not axi_rvalid) ;

	process (Core_Status_0, control_reg, fetch_data, Common_Status, slv_reg5, slv_reg6, slv_reg7, slv_reg8, slv_reg9, core_debug, slv_reg11, timestamp, slv_reg14, slv_reg15, axi_araddr, S_AXI_ARESETN, slv_reg_rden)
	variable loc_addr : STD_LOGIC_VECTOR(OPT_MEM_ADDR_BITS downto 0);
	begin
		if S_AXI_ARESETN = '0' then
			reg_data_out  <= (others => '1');
		else
			-- Address decoding for reading registers
			loc_addr := axi_araddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB);
			case loc_addr is
				when b"0000" =>
					reg_data_out <= Core_Status_0;	--status; --x"00000001"; --slv_reg0;
					
				when b"0001" =>
					reg_data_out <= control_reg;
				when b"0010" =>
					reg_data_out <= fetch_data(31 downto 0);
				when b"0011" =>
					reg_data_out <= fetch_data(63 downto 32);
				when b"0100" =>
					reg_data_out <= Common_Status;
				when b"0101" =>
					reg_data_out <= slv_reg5;
				when b"0110" =>
					reg_data_out <= slv_reg6;
				when b"0111" =>
					reg_data_out <= slv_reg7;
				when b"1000" =>
					reg_data_out <= slv_reg8;
				when b"1001" =>
					reg_data_out <= slv_reg9;
				when b"1010" =>
					reg_data_out <= core_debug;
				when b"1011" =>
					reg_data_out <= slv_reg11;
				when b"1100" =>
					reg_data_out <= timestamp(63 downto 32);
				when b"1101" =>
					reg_data_out <= timestamp(31 downto 0);
				when b"1110" =>
					reg_data_out <= slv_reg14;
				when b"1111" =>
					reg_data_out <= slv_reg15;
				when others =>
					reg_data_out  <= (others => '0');
			end case;
		end if;
	end process; 

--------------------------------------------------------------------------------
-- Output register or memory read data
process( S_AXI_ACLK ) is
begin
	if (rising_edge (S_AXI_ACLK)) then
		if ( S_AXI_ARESETN = '0' ) then
			axi_rdata	<= (others => '0');
		else
			if (slv_reg_rden = '1') then
				-- When there is a valid read address (S_AXI_ARVALID) with 
				-- acceptance of read address by the slave (axi_arready), 
				-- output the read dada 
				-- Read address mux
				axi_rdata <= reg_data_out;	 -- register read data
				if(axi_araddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB) = b"0010")then
					manual_fetch	<= High;
				end if;
				do_read <= High; --
			else
				do_read 		<= Low;	
				manual_fetch	<= Low;
			end if;	 
		end if;
	end if;
end process;

-- Add user logic here
Core_Control_1		<= control_reg;
Common_Control		<= slv_reg5;
base_address    	<= slv_reg6; 
transfer_size		<= slv_reg7;
pretrigger_length	<= slv_reg8;
trigger_delay		<= slv_reg11;

process(S_AXI_ACLK)
begin
	if(S_AXI_ACLK = '1' and S_AXI_ACLK'event)then
		command_tvalid		<= reg9_wr;
	end if;
end process;
command_tdata		<= slv_reg9;
--------------------------------------------------------------------------------
end arch_imp;
