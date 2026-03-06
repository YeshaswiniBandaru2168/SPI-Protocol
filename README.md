# SPI-Protocol
The Serial Peripheral Interface (SPI) is a high-speed, synchronous communication standard used extensively in embedded systems for short-distance data exchange. It operates on a master-slave architecture, allowing an FPGA or SoC to act as a central controller for various peripherals such as ADCs, DACs, and flash memory.

The protocol relies on four primary signals:

SCLK (Serial Clock): Provides the timing synchronization.
MOSI (Master Out Slave In): The data path from the controller to the peripheral.
MISO (Master In Slave Out): The data path from the peripheral back to the controller.
CS (Chip Select): An active-low signal used to initiate communication and address specific slave devices.

#Technical Design & Methodology
This implementation features a robust, synthesizable SPI Master core written in Verilog. Unlike simplified models, this design prioritizes timing accuracy and hardware reliability through a state-machine-driven architecture.

1. Finite State Machine (FSM) Control
The core logic is governed by a 5-state FSM that manages the lifecycle of a transaction. By partitioning the logic into IDLE, CS_SETUP, TRANSFER, CS_HOLD, and WAIT states, the controller ensures that the physical signals meet the setup and hold requirements of the target peripheral. This approach prevents data corruption that often occurs when a clock begins too early or a chip-select line is released too abruptly.

2. Parameterized Timing & Reusability
The design is highly flexible. It utilizes parameters for CS-to-Clock (c2t_d) and Clock-to-CS (t2c_d) delays. This allows the user to adapt the controller to different hardware speeds without modifying the underlying RTL code, making it an ideal "drop-in" module for larger digital systems.

3. Logic Configuration: SPI Mode 0
The controller is configured for SPI Mode 0 operation (CPOL=0, CPHA=0). In this mode:

The serial clock remains at logic low during idle states.
Data is captured on the rising edge of SCLK.
Data is shifted onto the bus on the falling edge of SCLK.
This is the industry-standard configuration, ensuring compatibility with the vast majority of commercial SPI-enabled sensors.
