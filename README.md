# Redes de Comunicação 3 - Scripts & Configs

This repository contains network protocol scripts and configurations developed as part of the Communication Networks 3 course.

## Protocol Index
- [DHCP (Dynamic Host Configuration Protocol)](#dhcp)
- [DNS (Domain Name System)](#dns)

## Prerequisites
- Linux/Unix environment
- Execution permissions for scripts
- Shell (sh) available on the system

## Repository Structure
```
.
├── DHCP
├── DNS
│   └── r0.sh
└── README.md
```

## Protocols

### DHCP
The `DHCP` directory contains configurations related to the Dynamic Host Configuration Protocol.

#### Available Scripts:
1. `r1.sh`: Run it in R1 alpine machine
2. `r0.sh`: Run it in R0 alpine machine

### DNS
The `DNS` directory contains scripts for DNS (Domain Name System) configuration and management.

#### Available Scripts:
1. `c1.sh`: Run it in C1 alpine machine
2. `r0.sh`: Run it in R0 alpine machine

### How to Execute any script
1. Clone the repository:
   ```bash
   git clone https://github.com/Fiagapcoo/RC3-Scripts-Configs.git
   ```

2. Navigate to the directory:
   ```bash
   cd RC3-Scripts-Configs/DNS/
   ```


3. Execute desired script:
   ```bash
   ./r0.sh   # For server configuration
   # or
   ./c1.sh   # For client configuration
   ```

## Usage Notes
- Scripts must be executed with appropriate privileges
- Follow the instructions displayed during script execution
- For `r0.sh`:
  - T must be between 1 and 4
  - G must be between 1 and 6

## Contributing
To contribute to this repository:
1. Fork the project
2. Create a Branch for your modification
3. Commit your changes
4. Push to the Branch
5. Open a Pull Request

## License
This project is under the MIT license.

---
Developed for RC3 course by [@Fiagapcoo](https://github.com/Fiagapcoo)