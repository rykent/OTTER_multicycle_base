import cocotb
from cocotb.clock import Clock
from cocotb.triggers import Timer
from cocotb.triggers import RisingEdge

@cocotb.test()
async def basic_count(dut):

    #PC to search for
    PC_END = int(cocotb.plusargs["PC"], 0)
    
    #Start Clock
    cocotb.start_soon(Clock(dut.CLK, 10, "ns").start())

    #START TEST
    dut.BTNC.value = 1
    await Timer(600, "ns")
    dut.BTNC.value = 0
    dut.SWITCHES.value = 0


    dut._log.info("Starting Program")
    while dut.CPU.pc_bus.value != PC_END:
        await RisingEdge(dut.clk_50)
    pass