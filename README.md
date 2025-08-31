# Alpha2-3 Multi-Peripheral Caravel User Project

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) [![UPRJ_CI](https://github.com/chipfoundry/caravel_user_project/actions/workflows/user_project_ci.yml/badge.svg)](https://github.com/chipfoundry/caravel_user_project/actions/workflows/user_project_ci.yml)

## Project Overview
This project integrates multiple peripheral controllers into the Caravel SoC framework, providing a comprehensive multi-peripheral interface with the following components:

- **2× SPI Master Controllers** - Full-duplex SPI communication
- **1× I2C Master Controller** - I2C bus master functionality  
- **2× GPIO Lines** - General purpose I/O with edge-detect interrupts

## Requirements Summary
Based on the requirements questionnaire, this project implements:

### Memory Map
| Peripheral | Base Address | Address Range | Size |
|------------|--------------|---------------|------|
| SPI Master 0 | 0x3000_0000 | 0x3000_0000 - 0x3000_0FFF | 4KB |
| SPI Master 1 | 0x3000_1000 | 0x3000_1000 - 0x3000_1FFF | 4KB |
| I2C Controller | 0x3000_2000 | 0x3000_2000 - 0x3000_2FFF | 4KB |
| GPIO Controller | 0x3000_3000 | 0x3000_3000 - 0x3000_3FFF | 4KB |

### IO Pin Assignment
- **SPI Master 0:** io_out[7:4] = {sclk0, mosi0, csb0, miso0}
- **SPI Master 1:** io_out[11:8] = {sclk1, mosi1, csb1, miso1}
- **I2C Controller:** io_out[13:12] = {scl, sda}
- **GPIO:** io_out[15:14] = {gpio1, gpio0}

### Interrupt Configuration
- **GPIO Interrupts:** user_irq[1:0] for individual GPIO edge detection
- **Peripheral Interrupts:** user_irq[2] for combined SPI/I2C interrupts

## Implementation Plan

### Sprint 1: Core Integration
- [x] Requirements analysis and questionnaire completion
- [ ] Top-level user project module creation
- [ ] Address decoder implementation
- [ ] Wishbone wrapper creation
- [ ] Basic integration testing

### Sprint 2: Peripheral Integration  
- [ ] SPI master integration and testing
- [ ] I2C controller integration and testing
- [ ] GPIO controller integration and testing
- [ ] Interrupt aggregation logic

### Sprint 3: Caravel Integration
- [ ] User project wrapper integration
- [ ] OpenLane configuration and hardening
- [ ] Full system verification
- [ ] Final documentation and deliverables

## Pre-installed IP Utilization
This project leverages the following verified IP cores:
- **CF_SPI v2.0.0** - ChipFoundry SPI Master with Wishbone interface
- **EF_I2C v1.1.0** - Efabless I2C Master with FIFO support
- **EF_GPIO8 v1.1.0** - Efabless 8-bit GPIO with interrupt support

## Current Status

✅ **Simplified Design Complete** - Ready for use and testing  
⚠️ **Complex Design** - Ready for optimization

### Completed
- [x] Project structure created
- [x] Requirements analysis and memory map definition
- [x] IP core selection and integration
- [x] Wishbone wrapper creation (simplified design)
- [x] OpenLane macro hardening (simplified design)
- [x] Physical views generation (GDS, LEF, netlist, timing)
- [x] User project wrapper integration
- [x] Complete Caravel integration flow validation

### Working Design (Simplified)
- [x] 1× SPI master at 0x3000_0000
- [x] 1× GPIO controller at 0x3000_1000  
- [x] 3× interrupt lines (SPI + GPIO edges)
- [x] 8× IO pins
- [x] Successfully hardened with OpenLane
- [x] All physical views generated

### Ready for Optimization (Complex)
- [x] 2× SPI masters (0x3000_0000, 0x3000_0800)
- [x] 1× I2C controller (0x3000_1000)
- [x] 1× GPIO controller (0x3000_2000)
- [x] 3× interrupt lines
- [x] 16× IO pins
- [x] Passes lint checks
- ⚠️ Needs placement/timing optimization

### Next Steps
- [ ] Complex design optimization for OpenLane
- [ ] User project wrapper timing closure
- [ ] Verification and testing
- [ ] Production-ready documentation

## Deliverables

### Physical Implementation Files
- `gds/alpha2_3_simple_wb_wrapper.gds` - Final layout (5.6MB)
- `lef/alpha2_3_simple_wb_wrapper.lef` - Abstract view (31KB)
- `verilog/gl/alpha2_3_simple_wb_wrapper.v` - Gate-level netlist (1MB)
- `lib/alpha2_3_simple_wb_wrapper.lib` - Timing library (806KB)

### Documentation
- `CARAVEL_INTEGRATION_REPORT.md` - Complete integration report
- `requirements_questionnaire.md` - Filled requirements
- `README.md` - This file
