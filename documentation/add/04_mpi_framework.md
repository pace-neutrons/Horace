# Generic MPI Framework

A generic parallelization framework has been created for Horace to improve performance of computationally-expensive operations benefiting from parallel execution. The framework substantially simplifies the standard parallelization by tailoring MPI interface to the subset of the tasks, relevant to Horace.

A standard message parsing interface consists of a communicator part, controlling parallel processes and an information exchange media, responsible for point-to-point or collective interaction between these processes.

To accommodate different demands of different users on different systems, 
Horace can utilize three different **message transfer media**, namely: 

    1. Communications via message files written/read from a HDD,
    2. Using Matlab parallel computing toolbox MPI implementation (based on toolbox lab`**` operations) and   
    3. Communication using standard MPI framework. Currently used MPI implementations are Microsoft MPI for Windows and MPICH for Linux. 
    
The **communicator/controller**[1](https://en.wikipedia.org/wiki/Message_Passing_Interface#Communicator) parts for these media, responsible for controlling the parallel processes, are correspondingly:

    1. Pool of Matlab sessions or compiled Matlab sessions, launched by Matlab's Java launcher,
    2. Matlab Parallel computing toolbox job control mechanism and 
    3. **mpiexec** launcher, directly controlling standard MPI processes.
    
Additional controller will be necessary to use Horace parallelization on a public cluster. This controller wraps around the cluster job submission mechanism (i.g. *qsub* or *bsub*)

The option 1. suits the users who do not want to compile C++ code on a Unix system and do not have Matlab parallel computing toolbox installed, option 2. is best for the people, who has Matlab parallel computing toolbox and 3. -- for experienced users who can compile C++ code and set up MPI framework. 

A cluster, executing Horace job should have the simple topology: 

![Horace Cluster](../diagrams/HoraceMPICluster.png)

**Fig 1** Cluster to run Horace jobs.

To provide simple switching between different frameworks, the common wrappers are written around the libraries and programs controlling parallel processes and transferring the messages. The wrappers provide common interface to users job. A Horace parallel job tasks are controlled and communicate with each other using this interface. This allows simple and transparent switching between the frameworks. 

Each **communicator/controller** is responsible for correspondent **message transfer media**. The correspondence is summarized in the following table:

**Table 1.** Parallel communicators and message transfer media used by Horace parallel framework. 

| communicator\media |  Filebased |  Matlab MPI | mpiexec MPI |
| :----  | :---: | :---: | :---: |
| Java Launcher | Native | -- | -- |
| Matlab MPI    | possible |  Native| -- |
| mpiexec MPI    | possible |  -- | Native |
| Job submission/initialization/control| Only | -- | -- | 

Where the word *Native* indicates the media, used by communicator by design (e.g. mpiexec program is responsible for controlling the pool of parallel processes/programms, communicating over MPI interface). *Possible* means that, despite *Native* mechanism exist, communication can be performed by alternative means, i.e. mpiexec processes can communicate between each other sending file-based messages if necessary. 
The last row of the table with world *Only* means that each parallel job is initialized and controlled from the *Login Session *(**Fig 1**) using file-based messages mechanism, i.e. input for the task, logging of the progress and output (unless it is source/target sqw file) are distributed using file-based messages. 


From a user perspective, interaction with a parallel job occurs the same way as they would work with Horace analysing their data, implicitly launching parallel jobs for time-consuming operations, if parallel execution is configured for appropriate algorithms. Horace is currently written in Matlab. Matlab is a commercial software, but for the cases the licensing requests (*) are not satisfied, we provide compiled version of this code, requesting only one Matlab license for the headnode and [Matlab Redistributable](https://uk.mathworks.com/products/compiler/matlab-runtime.html) installed on the cluster. The python wrapper around Horace code eliminating the need for any Matlab licensing is under development. 


The chunking of jobs into "pieces"is done in the MATLAB layer. The File-based framework has been written with the assumption that *chunks may be processed independently*, but limited number of interprocess communications is occurring. This restricts the use of file-based framework to the correspondent part of Horace algorithms and for initial job submission. Matlab MPI and standard MPI frameworks do not have such restrictions.

Generic Horace job management interaction is presented on the **Fig 2**: 

![MPI Framework](../diagrams/mpi-framework.png)

**Fig 2:**  Horace parallel job framework




(*: one MATLAB license for each execution node or Matlab distributed server license with correspondent number of nodes licenses is required)

## Interface

A common interface has been implemented to ensure the operation is independent of the underlying service and messaging framework. As we use only restricted subset of MPI operations, necessary to our purposes, the interface appeared much simple then the standard MPI or even Matlab distributed computing toolbox interface. 


## Job Management

#### JobExecutor:

Each independent Matlab or compiled Matlab session, runs a *worker* script, which instantiates and runs JobExecutor class.  To run under the framework, a Horace parallel job has to inherit from the abstract *JobExecutor* class and define the main methods responsible for the particular job execution.

The methods to be defined for a job are:

**Table 2** Abstract methods of a **JobExecutor** class

| Method | Description | Practical Example (From [*accumulate\_headers\_job*](https://github.com/pace-neutrons/Horace/blob/master/horace_core/sqw/%40accumulate_headers_job/accumulate_headers_job.m)  parallel algorithm)  |
| :----  | :--- | :---| 
| **do_job** | Do chunk of the job independent on other parallel executors | Read range of tmp files and calculate this range average signal and error. | 
| **reduce_data** | Send result to head worker (**Fig 1**) node or receive partial result and combine them on the head worker. | Send the average signal/error to node-1 or accept partial averages, sum them and send results to the logon node |
| **is_completed** | Check if the job completed and return true if it is | return true |
| **task_outputs** | The property, containing the result of **do_job** operation | Set the values to return the results of the calculations to the control node on the node-1. Ignore for other nodes.

The *JobExecutor* itself contains methods and properties, responsible for inter-nodes communications and the communications with the control node which launching the job. 
The *worker* instantiates The user's-redefined *JobExecutor* and runts it in the following loop:

```
 while ~TheJobExecutor.is_completed;
	TheJobExecutor.do_job();
	TheJobExecutor.reduce_data();
 endwhile	
```
The main methods and properties (M/P) of *JobExecutor* involved in a job control and intertask communications are summarized in the table:

**Table 3** Communicator and control properties and methods of **JobExecutor**

| Method or Property | M/P | Description |
|:----| :---: | :---
| labIndex | P | The id(number) of the running task (Worker Number in filebased, labNum in Matlab or MPI rank for MPI) |
|mess_framework | P |  Access to messages framework used to exchange messages between the parallel tasks. For file-based messages its the same as *control\_node\_exch*  but for proper MPI job or remote host its different | 
| control\_node\_exch | P | The framework used to exchange messages between MPI jobs pool and the control (login) node.  | 
| task_outputs | P | A helper property, containing task outputs to transfer to the headnode, if these outputs are defined. |
|_______________| __ | _______________________________________________________________| 
| init | M | Initialize JobExecutor's communications capabilities
| finish_task | M | Safely finish job execution and inform other nodes about it. |
| reduce\_send\_message | M | collect similar (usually unblocking) messages send from all nodes and send final message to the  head node (node 1 or logon node for node 1)|
| log_progress | M | log progress of the job execution and report it to the calling framework. | 

As file-based messaging framework is always available, input algorithm data are separated into chunks and distributed to parallel workers using file-based messages. The *JobDispatcher* class is responsible for running the *worker*-s instantiating user jobs, in parallel. 

#### JobDispatcher:
To run the *JobExecutor* in parallel, it has to be divided into appropriate chunks, and to be sent for execution on the appropriate parallel environment. 
The class, responsible for chunking the task, controlling the parallel pool, sending user job information to this pool and initial data for the user jobs and reporting the progress of the job is the *JobDispatcher* class.
The main methods and properties (M/P) of the class are:

**Table 4** Main properties and methods of **JobDispatcher** class.

| Method or Property | M/P | Description |
|:----| :---: | :--- |
| **Job/Cluster identification properties:** | -- | ---------------------|
| job_id | P | The name, which describes the job, and distinguish it from any other job, may be running on a system. Normally, a folder with such name exist on a shared file system and all file-based messages, related to controlling this job a distributed through this folder. 
| mess_framework | P | The framework used to exchange messages within the parallel cluster, i.e. between the parallel workers of the cluster. A job running on a cluster always communicate with *JobDispatcher* using file-based messages, but parallel workers can communicate among each other using range of different media (See **Table 1**)
| cluster | P | Exposes read access to the class, controlling cluster, i.e. the pool of independent processes or programs, to execute parallel job. 
| is_initialized | P | true if *JobDispatcher* already controls a cluster so the next job can be executed on existing cluster rather then after starting a new one. False if the cluster is not running and needs to be started up |
|**Job control properties**: | --- | ---------------------|
| task\_check\_time | P |  how often (in second) job dispatcher should query the task status |
| fail\_limit | P | number of times to try action until deciding the action have failed |
| time\_to\_fail | P | Time interval to wait until job which do not return any messages from the cluster is considered failed and should be terminated. |
|**Job control Methods** : | --- | ---------------------|
| split_tasks | M | Auxiliary method, used internally by the following methods and taking as input the structure, containing the information common to all parallel workers, number of workers and cellarray of input parameters to split among the workers. Returns the array of messages, to initialize each worker of the cluster. | 
| start_job | M | Taking as input the number of workers requested, job name and its input job parameters, splits the job among workers, starts the cluster and controls the job execution, regularly querying the *cluser* on the progress of the job execution and displaying the results of the execution. Returns the result of the job. |
| restart_job | M |  The same as *start_job* but does not start the cluster using existing cluster to start new or continue the old job providing new input data. |

One of the main properties of *JobDispatcher* class is *cluster* property, containing an instance of *ClusterWrapper* class, responsible for control of the pool of multiple parallel processes or programs, e.g. the *cluster*. The *JobDispatcher* controls and communicates with the cluster through the properties, described below. 



## Cluster Management 
Cluster classes are responsible for launching and initializing parallel workers, displaying job progress and completing parallel execution. The parent for all cluster classes is a *ClusterWrapper* class, which provides common interface for the communicators/controllers mentioned above.

![Cluster Wrapper](../diagrams/ClusterWrapperInterface.png)

**Fig 3** Cluster Wrappers interface and its current implementations. 

To provide simple selection of a framework, all Cluster Wrapper classes are subscribed to framework factory **MPI\_fmwks\_factory**. User interacts with the factory through **parallel_config** configurations class:

![Parallel Framework Selection](../diagrams/SelectClusterWrapper.png)
**Fig 4** Selection of a parallel framework. The clusters are subscribed to factory with the following names: **herbert:->ClusterHerbert; parpool:->ClusterParpoolWrapper; mpiexec_mpi:->ClusterMPI**

*parallel_config* class receives from *MPI\_fmwks\_factory*  list of the subscribed and available framework names and the user selects the appropriate framework. Then, *Job_dispatcher* uses *get\_running\_cluster* method of the factory to start cluster and use it for running the parallel job described by *theJobExectutor*. 

Each cluster implements the *ClusterWrapper* methods, *JobDispatcher* uses to control the jobs:

**Table 5** A cluster properties list:

| Method or Property| M/P |Description |
| :--- | :--- | :--- | 
|job\_id  | P  | The string, providing unique identifier(name) for the running cluster and the job running on this cluster. When cluster is running, it is the same name as *job\_id* in *JobDispatcher* and *iMessagesFramework* below.|
| n_workers | P | number of independent parallel workers, running in cluster. It is headless Matlab sessions or compiled Matlab sessions executing the selected job. |




## Message Framework

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