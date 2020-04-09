# Generic MPI Framework

A generic parallelization framework has been created in Horace to improve performance of computationally-expensive operations benefiting from parallel execution.

A standard message parsing interface consists of a communicator part, controlling parallel processes and an information exchange media, responsible for point-to-point or collective interaction between these processes.
To accommodate different demands of different users, 
we use three different **message transfer media**, namely: 1) message files stored/read from a HDD, 2) Matlab parallel computing toolbox MPI implementation (lab`**` operations) and 3) standard MPI framework. Currently used implementations are Microsoft MPI for Windows and MPICH for Linux. The **communicator/controller**[1](https://en.wikipedia.org/wiki/Message_Passing_Interface#Communicator) parts for these media, are correspondingly: 1) Matlab sessions or compiled Matlab sessions, launched by Matlab's Java launcher, 2) Matlab Parallel computing toolbox job control mechanism and 3) mpiexec launcher, directly controlling standard MPI processes.

The option 1) suits to users who do not want to compile C++ code on a Unix system and do not have Matlab parallel computing toolbox installed, option 2) best for people, who has Matlab parallel computing toolbox installed and 3) -- for experienced users who can compile 

To provide transparent


User jobs are compiled operations (e.g. C++, compiled MATLAB) or MATLAB scripts (*)

Communication between nodes and the dispatcher is via a Messaging Framework which can be file- or MPI- based.

The chunking of jobs into "pieces"is done in the MATLAB layer. The framework has been written with the assumption that *chunks may be processed independently*, however the framework supports limited inter-process-communication.

![MPI Framework](../diagrams/mpi-framework.png)

(*: one MATLAB license for each execution node or Matlab distributed server license with correspondent number of nods is required)

### Interface

A common interface has been implemented to ensure the operation is independent of the underlying service and messaging framework.

#### Cluster Management

| Method | Notes|
| :--- | :--- |
| | |

#### Job Management

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