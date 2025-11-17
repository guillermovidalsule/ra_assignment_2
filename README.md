# Randomized Algorithms - Assignment 2 - Balanced Allocations

This is my submission for the first assignment of the randomized algorithms (RA) subject at Universitat Politècnica de Catalunya (UPC), 
Facultat d'Informàtica de Barcelona (FIB). It simulates a balls and bins model and studies different allocation schemes
and uncertainties (batching, partial information).

### Prerequisites

You will need the following tools to use the different features of the project:

+ [Alire](https://alire.ada.dev/) (>=2.0.2) for running the SHELL script or manage the crate.
+ [GNAT Ada](https://github.com/alire-project/GNAT-FSF-builds) (>=14.2.0) for compiling the Galton board model.
+ [GPRBUILD](https://github.com/AdaCore/gprbuild) (>=22.0.0) for building the Galton board project.
+ Python3 (>=3.10.12) to run the graph generator (+pip installing the depenencies).

For those of you that are unfamiliar with Ada / Alire, you can follow this quick steps using Alire to set up the environment:

```
# Download Alire (alr) and add it to PATH
wget https://github.com/alire-project/alire/releases/download/v2.1.0/alr-2.1.0-bin-x86_64-linux.zip
unzip alr-2.1.0-bin-x86_64-linux.zip
export $PATH=$PWD/bin

# Install GNAT and GPRBUILD through Alire
alr toolchain --select gnat_native=14.2.1 gprbuild=22.0.1
```

In DockerHUB there are some available containers with Ubuntu22.04 and Alire already set up.

### Usage

In order to build the program use:

```
alr build
```

You can run it with:
```
/path/to/crate/bin/bins_and_balls
```

Or alternatively (it also builds):
```
alr run
```


**NOTE** that in this cases it would use the default preprocessor values, which are very limited so that you do not always need to input all of them.
A list of compiler preprocessor variables can be found in `bins_and_balls.gpr` and their assignments in `src/bins_and_balls.adb` and `src/allocation_schemes.ads`.
Using them can be done like so:

```
alr build -- --gnateDNAME_OF_PREP=Value --gnateDNAME_OF_PREP2=Value2
```

The directory named `scripts` includes some programs that were used to generate the datasets, but they are not very polished.
They ought to be run from the top level directory of the repository and also serve as examples on how to compile and run the code.

### Structure

The main components of the project can be found at:

+ `bins_and_balls/` the crate containing the simulation code
	- `src/bins_and_balls.adb` main source code
	- `bins_and_balls.gpr` project configuration and preprocessor
	- `alire.toml` crate configuration (includes build dependencies)
	- `src/allocation_schemes.ads` header file for the allocation schemes
	- `src/allocation_schemes.adb` body of the allocation schemes
+ `scripts` useful scripts for data generation
