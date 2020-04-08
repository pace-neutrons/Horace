# Generic MPI Framework

A generic parallelization framework has been created in Horace to improve expensive operations performance using parallel jobs execution. 

A standard message parsing interface consists of a communicator block, controlling parallel processes and information exchange media, responsible for point-to-point or collective interaction between processes.
To accommodate different demands and of different users, 
Current implementation supports three different message transfer media, namely message files on a HDD, Matlab parallel computing toolbox MPI implementation and standard MPI framework (currently used implementations are Microsoft MPI for Windows and MPICH for Linux).


 The framework presents a common interface to users and supports parallelization through the MATLAB parallel toolbox and using MPI. A switch argument is used to configure 'the amount of parallelism'

Jobs are compiled operations (e.g. C++, compiled MATLAB) or MATLAB scripts (*)

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