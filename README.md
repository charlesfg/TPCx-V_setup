# TPCx-V Setup for Xen Hypervisor

This repository provides a set of scripts, documentation, and templates to facilitate the setup and execution of the TPCx-V benchmark on a Xen Hypervisor environment. This project is born from experimental work and aims to help the community in deploying and using the TPCx-V benchmark.

## What is TPCx-V?

TPCx-V is a benchmark from the Transaction Processing Performance Council (TPC) for measuring the performance of virtualized servers. It uses a database-centric workload to model the properties of cloud services, with multiple virtual machines running at different and fluctuating load levels. The primary metric for TPCx-V is **tpsV**, which represents the number of completed "Trade-Result" transactions per second.

## Repository Structure

The repository is organized as follows:

- **`clone_*.sh`**: A set of scripts to clone and configure the virtual machines for the benchmark.
- **`run_tier*_setup.sh`**: Scripts to set up the application (Tier A) and database (Tier B) tiers of the benchmark.
- **`xen_install/`**: Contains Xen VM configuration files.
- **`results_scripts/`**: Scripts for collecting and analyzing benchmark results.
- **`html_template/`**: HTML templates for presenting the results.
- **`vm-utils/`**: Utility scripts for managing the virtual machines.

## Requirements

Before you begin, ensure you have the following prerequisites in place:

- A machine with Xen Hypervisor installed and configured.
- A base VM image named `tpc0-centos7-disk` and `tpc0-centos7-swap` created as LVM logical volumes. These scripts use `dd` to copy this base image.
- The TPCx-V benchmark kit from the TPC website. This repository does not provide the benchmark kit itself. You should have the VDb/ folder in the /opt directory.
- Python and `pip` installed.

## Setup

The setup process is divided into three main stages:

### 1. Install Dependencies

First, install the required Python dependencies:

```bash
sudo ./install_dependencies.sh
```

### 2. Clone and Configure the Virtual Machines

The `clone_all_Xen_VMs.sh` script will create and configure the necessary virtual machines for the benchmark. This script will:

- Create LVM logical volumes for each VM.
- Copy the base VM image to the new logical volumes.
- Configure the hostname and networking for each VM.
- Create a Xen configuration file for each VM.
- Start each VM.

To run the script:

```bash
sudo ./clone_all_Xen_VMs.sh
```

### 3. Set up the Database Tier (Tier B)

The `run_tierB_setup.sh` script will set up the database tier of the benchmark. This script will:

- Format the database storage.
- Set up the database folders.
- Set up PostgreSQL.
- Create the TPCx-V database.

To run the script, you need to execute it inside each of the Tier B VMs:

```bash
./run_tierB_setup.sh
```

### 4. Set up the Application Tier (Tier A)

The `run_tierA_setup.sh` script will set up the application tier of the benchmark. This script will:

- Set up the datasource to connect to the database tier.
- Check the connectivity to the database.

To run the script, you need to execute it inside each of the Tier A VMs:

```bash
./run_tierA_setup.sh
```

## Running the Benchmark

After completing the setup, you can run the TPCx-V benchmark. While this repository does not provide a single script to run the entire benchmark, the `results_scripts/` directory contains several scripts that can be used to run the benchmark and collect the results. The `long_run.sh` and `run_and_report.sh` scripts are good starting points.

## Contributing

Contributions to this project are welcome. Please fork the repository and submit a pull request with your changes.

## License

This project is licensed under the terms of the MIT license. See the `LICENSE` file for more details.