# Generic MPI Framework

A generic parallelization framework has been created in Horace to improve performance of computationally-expensive operations benefiting from parallel execution.

A standard message parsing interface consists of a communicator part, controlling parallel processes and an information exchange media, responsible for point-to-point or collective interaction between these processes.
To accommodate different demands of different users on different systems, 
we provide three different **message transfer media**, namely: 1) message files stored/read from a HDD, 2) Matlab parallel computing toolbox MPI implementation (based on toolbox lab`**` operations) and 3) standard MPI framework. Currently used implementations are Microsoft MPI for Windows and MPICH for Linux. The **communicator/controller**[1](https://en.wikipedia.org/wiki/Message_Passing_Interface#Communicator) parts for these media, are correspondingly: 1) Matlab sessions or compiled Matlab sessions, launched by Matlab's Java launcher, 2) Matlab Parallel computing toolbox job control mechanism and 3) mpiexec launcher, directly controlling standard MPI processes.

The option 1) suits to users who do not want to compile C++ code on a Unix system and do not have Matlab parallel computing toolbox installed, option 2) best for people, who has Matlab parallel computing toolbox and 3) -- for experienced users who can compile C++ code and set up MPI framework. 

To provide transparent interchange between these frameworks, the common wrappers were written around used message transfer media and controllers, to provide common interface to the job. The Horace parallel job communicate with each other using this interface, which allows simple and transparent switching between frameworks. 

Normally users interact with the parallel jobs the same way as they would work with Horace analysing their data, implicitly launching parallel jobs for time-consuming operations. Horace is currently written in Matlab which is commercial software, but for the cases the licensing requests (*) are not satisfied, we provide compiled version of this code, which requests only one Matlab license for the headnode and [Matlab Redistributable](https://uk.mathworks.com/products/compiler/matlab-runtime.html) installed on the cluster. 


The chunking of jobs into "pieces"is done in the MATLAB layer. The File-based framework has been written with the assumption that *chunks may be processed independently*, but limited number of interprocess communications is occurring. This restricts the use of file-based framework to only part of Horace algorithms. In addition to that, current implementation allows to use this framework on single multiprocessor node only. Matlab MPI and standard MPI frameworks do not have such restrictions.

Generic Horace job managment interaction is presented on the Fig 1: 
![MPI Framework](../diagrams/mpi-framework.png)
**Fig 1:**  Horace parallel job framework


(*: one MATLAB license for each execution node or Matlab distributed server license with correspondent number of nods is required)

### Interface

A common interface has been implemented to ensure the operation is independent of the underlying service and messaging framework. As we use only restricted subset of MPI operations, necessary to our purposes, the interface appeared much simple then the standard MPI or even Matlab distributed computing toolbox interface. 

#### Cluster Management 
The cluster is controlled by a ClusterWrapper class, which provides common interface for the communicators/controllers mentioned above.
& Job Management


| Method | Notes|
| :--- | :--- |
| | |



| Method | Notes|
| :--- | :--- |
| | |

#### Message Framework

A messages framework is responsible for information exchange between independent workers

 To allow 

The default message framework is file based

| Method | Notes|
| :--- | :--- |
|`mess_name`||
|`send_message`||
|`receive_message`||
|`probe_all`||
|`send_all`||
|`receive_all`||
|`finalize_all`||