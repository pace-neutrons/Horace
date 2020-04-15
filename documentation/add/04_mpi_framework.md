# Generic MPI Framework

A generic parallelization framework has been created in Horace to improve performance of computationally-expensive operations benefiting from parallel execution. The framework substantially simplifies the standard parallelization interface by tailoring it to the subset of the tasks, relevant to Horace.

A standard message parsing interface consists of a communicator part, controlling parallel processes and an information exchange media, responsible for point-to-point or collective interaction between these processes.

To accommodate different demands of different users on different systems, 
Horace can utilize three different **message transfer media**, namely: 1) Communications via message files written/read from a HDD, 2) Using Matlab parallel computing toolbox MPI implementation (based on toolbox lab`**` operations) and 3) Communication using standard MPI framework. Currently used MPI implementations are Microsoft MPI for Windows and MPICH for Linux. The **communicator/controller**[1](https://en.wikipedia.org/wiki/Message_Passing_Interface#Communicator) parts for these media, responsible for controlling the parallel processes, are correspondingly: 1) Matlab sessions or compiled Matlab sessions, launched by Matlab's Java launcher, 2) Matlab Parallel computing toolbox job control mechanism and 3) mpiexec launcher, directly controlling standard MPI processes. Additional controller will be necessary to use Horace parallelization on a public cluster. This controller is wrapping the cluster job submission mechanism (i.g. *qsub* or *bsub*)

The option 1) suits for users who do not want to compile C++ code on a Unix system and do not have Matlab parallel computing toolbox installed, option 2) is best for the people, who has Matlab parallel computing toolbox and 3) -- for experienced users who can compile C++ code and set up MPI framework. 

A cluster, executing Horace job should have the simple topology: 
![Horace Cluster](../diagrams/HoraceMPICluster.png )
**Fig 1** Cluster to run Horace jobs.

To provide transparent interchange between these frameworks, the common wrappers are written around used message transfer media and controllers, to provide common interface to the job. The Horace parallel job communicate with each other using this interface, which allows simple and transparent switching between the frameworks. 

The interaction between **communicator/controller** and **message transfer media** running a Horace job on a  cluster presented on **Fig 1**, can be summarised in the following table:

| communicator\media |  Filebased |  Matlab MPI | mpiexec MPI |
| :----  | :---: | :---: | :---: |
| Java Launcher | Native | -- | -- |
| Matlab MPI    | possible |  Native| -- |
| mpiexec MPI    | possible |  -- | Native |
| Job submission/initialization/control| Only | -- | -- | 
Where Native indicates 


From a user perspective, the interaction with the parallel jobs occurs the same way as they would work with Horace analysing their data, implicitly launching parallel jobs for time-consuming operations, if parallel execution is configured for appropriate algorithms. Horace is currently written in Matlab. Matlab is a commercial software, but for the cases the licensing requests (*) are not satisfied, we provide compiled version of this code, requesting only one Matlab license for the headnode and [Matlab Redistributable](https://uk.mathworks.com/products/compiler/matlab-runtime.html) installed on the cluster. The python wrapper around Horace code eliminating the need for any Matlab licensing is under development. 


The chunking of jobs into "pieces"is done in the MATLAB layer. The File-based framework has been written with the assumption that *chunks may be processed independently*, but limited number of interprocess communications is occurring. This restricts the use of file-based framework to only part of Horace algorithms. In addition to that, current implementation allows to use filebased framework on single multiprocessor node only. Matlab MPI and standard MPI frameworks do not have such restrictions.

Generic Horace job management interaction is presented on the Fig 2: 
![MPI Framework](../diagrams/mpi-framework.png)
**Fig 2:**  Horace parallel job framework




(*: one MATLAB license for each execution node or Matlab distributed server license with correspondent number of nodes licenses is required)

## Interface

A common interface has been implemented to ensure the operation is independent of the underlying service and messaging framework. As we use only restricted subset of MPI operations, necessary to our purposes, the interface appeared much simple then the standard MPI or even Matlab distributed computing toolbox interface. 


## Job Management

#### JobExecturor:
To run under the framework, a Horace parallel job has to inherit from the abstract *JobExecutor* class and define the main methods responsible for the job execution.

The methods to be defined by a user are:

| Method | Description | Practical Example (From [*accumulate\_headers\_job*](https://github.com/pace-neutrons/Horace/blob/master/horace_core/sqw/%40accumulate_headers_job/accumulate_headers_job.m)  parallel algorithm)  |
| :----  | :--- | :---| 
| **do_job** | Do chunk of the job independent on other parallel executors | Read range of tmp files and calculate running average | 
| **reduce_data** | Send result to headnode or receive partial result and combine them | Send the running average to node-1 or accept partial averages, sum them and send results to the control node |
| **is_completed** | Check if the job completed and return true if it is | return true |
| **task_outputs** | The property, containing the result of **do_job** operation | Set the values to return the results of the calculations to the control node on the node-1. Ignore for 

The *JobExecutor* itself contains methods and properties, responsible inter-nodes communications and the communications with the control node which launching the job. The user job is executed by a parallel worker, which is a Matlab or compiled Matlab session, running the [*worker*](https://github.com/pace-neutrons/Herbert/blob/master/admin/worker_v2.m.template) script. 
The *worker* instantiates The user's-redefined *JobExecutor* and runts it in the following loop:

```
 while ~TheJobExecutor.is_completed;
	TheJobExecutor.do_job();
	TheJobExecutor.reduce_data();
 endwhile	
```
The main methods and properties of *JobExecutor* involved in job control and intertask communications are summarized in the table:

| Method | M/P *Method or Property* | Description |
|:----| :---: | :---
| labIndex | P | The id(number) of the running task (Worker Number in filebased, labNum in Matlab or MPI rank for MPI) |
|mess_framework | P |  Access to messages framework used to exchange messages between the parallel tasks For filebased messages its the same as *control\_node\_exch*  but for proper MPI job or remote host its different | 
| control\_node\_exch | P | The framework used to exchange messages between MPI jobs pool and the control node.  | 
| task_outputs | P | A helper property, containing task outputs to transfer to the headnode, if these outputs are defined. |
|_______________| __ | _______________________________________________________________| 
| init | M | Initialize JobExecutor's communications capabilities
| finish_task | M | Safely finish job execution and inform the head node about it. |
| reduce_send_message | M | collect similar messages send from all nodes and send final message to the  head node |
| log_progress | M | log progress of the job execution and report it to the calling framework. | 

As filebased messaging framework is always available, input algorithm data are separated into chunks and distributed to parallel workers using filebased messages. The JobDispatcher class is responsible for running the *worker*-s instantiating user jobs, in parallel. 

#### JobDispatcher:
To run the *JobExecutor* in parallel, it has to be divided into appropriate chunks, and to be sent for execution on the appropriate parallel environment. 
The class, responsible for chunking the task, controlling the parallel pool, sending user job information to this pool and initial data for the user jobs and reporting the progress of the job is the *JobDispatcher* class.
The main methods of the class are:

| Method | M/P *Method or Property* | Description |
|:----| :---: | :---
| job_id | P | The id(number) of the running task (Worker Number in filebased, labNum in Matlab or 




## Cluster Management 
Cluster classes are responsible for launching and initializing parallel workers, displaying job progress and completing parallel execution. The parent for all cluster classes is a *ClusterWrapper* class, which provides common interface for the communicators/controllers mentioned above.



| Method | Notes|
| :--- | :--- |
| | |



| Method | Notes|
| :--- | :--- |
| | |

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