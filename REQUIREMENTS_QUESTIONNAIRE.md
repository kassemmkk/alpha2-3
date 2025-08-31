# CARAVEL USER PROJECT REQUIREMENTS QUESTIONNAIRE

## Project Overview
**Project Name:** Alpha2-3 Multi-Peripheral SoC Integration
**Description:** Custom user project integrating multiple peripherals into Caravel SoC

## 1. Functional Requirements
**Primary Function:** Multi-peripheral controller with SPI, I2C, and GPIO interfaces
**Detailed Description:** Integration of 2× SPI masters, 1× I2C controller, and 2× GPIO lines with edge-detect interrupts

**Key Features Required:**
- [x] Feature A: 2× SPI Master controllers at base address 0x3000_0000
- [x] Feature B: 1× I2C Master controller at address 0x3000_1000  
- [x] Feature C: 2× GPIO lines with edge-detect interrupts at address 0x3000_2000

## 2. Technical Specifications
**Target Technology:** [x] ASIC [ ] FPGA [ ] Generic
**Clock Frequency:** 25 MHz (40ns period)
**Interface Type:** [x] Wishbone [ ] AXI [ ] APB [ ] Custom
**Data Width:** 32 bits

## 3. Memory Map
**Base Address:** 0x3000_0000
**Address Ranges:**
- SPI Master 0: 0x3000_0000 - 0x3000_0FFF (4KB)
- SPI Master 1: 0x3000_1000 - 0x3000_1FFF (4KB) 
- I2C Controller: 0x3000_2000 - 0x3000_2FFF (4KB)
- GPIO Controller: 0x3000_3000 - 0x3000_3FFF (4KB)

## 4. IO Pin Assignment
**SPI Master 0:** io_out[7:4] = {sclk0, mosi0, csb0, miso0}
**SPI Master 1:** io_out[11:8] = {sclk1, mosi1, csb1, miso1}  
**I2C Controller:** io_out[13:12] = {scl, sda}
**GPIO:** io_out[15:14] = {gpio1, gpio0}

## 5. Interrupt Configuration
**GPIO Edge Detection:** Both rising and falling edge detection
**Interrupt Lines:** user_irq[1:0] for GPIO interrupts
**SPI/I2C Interrupts:** user_irq[2] for combined peripheral interrupts

## 6. Verification Requirements
**Coverage Target:** 90%
**Number of Sprints:** 3
**Priority:** [x] Features [ ] Performance [ ] Area [ ] Power

## 7. Integration Requirements
**Pre-installed IPs to Use:**
- CF_SPI v2.0.0 (for SPI masters)
- EF_I2C v1.1.0 (for I2C controller)  
- EF_GPIO8 v1.1.0 (for GPIO with interrupts)

**Custom Integration Required:**
- Address decoder for memory map
- Interrupt aggregation logic
- Wishbone bus wrapper
- IO pin multiplexing

All sections completed - ready to proceed with implementation.