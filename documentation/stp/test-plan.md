# PACE Test Plan

## Overview

Testing of Horace covers areas:

- return correct data for specific (small) inputs
- handle edge cases correctly
- handle error cases correctly
- behave identically running on one or more thread (shared memory)
- behave identically running on one or mode nodes
- high-level functions behave identically when executed with realistic data sizes
- performance as a function of both file size and hardware

## Development and System Test Plan

Tests will be written for every story as it is implemented.

Full unit and software component integration testing will be automatically executed for regression purposes when code is merged and committed into the main development branch in the code repository. This will be complemented by manual testing as necessary.

The completion of all testing activities is a part of the Definition of Done. 

For each story and for every Sprint the following test strategy will be followed:

-	Automated unit tests will be written by the developers for all code that is developed except where impractical.
-	Automated integration tests will be written (using the unit test framework) by the developers where practical for collections of integrated software components (e.g. Matlab calling compiled C++ implementations).

In addition:

-	Automated system tests will be written by the developers to script the execution of a number of standard end-to-end workflows to measure performance on representative data sets and hardware.

### Unit Testing

All (new) code will be tested at UNIT level

- Where code is parallelized tests must be extended to cover execution on 1 and N (>1) threads to verify behaviour is unchanged
- C++ code will be unit tested with WHICH-TEST-FRAMEWORK
- Matlab will be tested with Matlab class-based unittest Framework
- Unit tests will be executed as part of the CI build

### System Testing

Automated system-level tests will be created to process test data files through a number of scripted workflows with KNOWN results 

- expected results derived from the current Horace release
	- WHAT workflows
- System tests will be executed on 1 core and multiple cores
	- WHAT systems
- Tests will record execution times

### Stress / Performance Testing

- Process of Small and Large data sets executed on range of environment sizes
	- WHAT systems
	- WHAT is small data
	- WHAT is large data
	- WHAT process -- can we create a single script which tests all key functions
- Run time / Performance measured and recorded
- Run regularly to track performance changes
	- Weekly?


