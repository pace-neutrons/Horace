# Generic MPI Framework

A generic parallelization framework has been created for Horace to improve performance of computationally-expensive operations benefiting from parallel execution.
The framework substantially simplifies the Horace parallelization,
particularly addressing Matlab's licensing issues surrounding the standard Parallel Computing toolbox for the purposes of distribution,
by tailoring a general MPI interface to the subset of the tasks relevant to Horace.

Horace is currently written in Matlab.
Matlab is commercial software, but for the cases the licensing requests
(one Matlab license for each execution node or Matlab distributed server license with corresponding number of nodes licenses is required)
are not satisfied, we provide compiled version of this code,
requiring only one Matlab license for the head node and [Matlab Redistributable](https://uk.mathworks.com/products/compiler/matlab-runtime.html) installed on the cluster.
A Python wrapper around Horace code, eliminating the need for any Matlab licensing, is under development.


A standard message passing framework consists of a communicator, which controls parallel processes and
an information exchange medium, responsible for point-to-point or collective interaction between these processes.

To accommodate the demands of different users on different systems, Horace can utilize three different **message transfer media**, namely:

1. Communication via message files written/read from a storage device,
2. Using Matlab parallel computing toolbox MPI implementation (based on the toolbox lab`**` operations) and finally,
3. Communication using a standard MPI framework. Currently supported MPI implementations are Microsoft MPI for Windows and MPICH for Linux.

The **communicator/controller** [[1]](https://en.wikipedia.org/wiki/Message_Passing_Interface#Communicator) parts for these media,
responsible for controlling the parallel processes, are respectively:

1. Pool of Matlab sessions or compiled Matlab sessions, launched by Matlab's Java launcher,
2. Matlab Parallel computing toolbox job control mechanism and
3. **mpiexec** launcher, directly controlling standard MPI processes.

An additional controller will be necessary to use Horace parallelization on a public cluster.
This controller is to wrap around and interfaces the cluster job submission mechanism (e.g. *qsub* or *bsub*).

Option 1) suits the users who do not want to compile C++ code and do not have the Matlab parallel computing toolbox installed.

Option 2) is best for people who have the Matlab parallel computing toolbox.

Option 3) is best for users who have access to Herbert's compiled C++ binaries, and do not have access to Matlab's Parallel Computing Toolbox.

To provide simple switching between different frameworks, common wrappers are written around the libraries and programs controlling parallel processes and transferring the messages.
The wrappers provide common interface to user jobs.
Horace parallel job tasks are controlled and communicate with each other using this interface independently of the underlying communication method.

Each **communicator/controller** is responsible for its corresponding **message transfer medium**. The correspondence is summarized in the following table:

**Table 1.** Parallel communicators and message transfer media used by the Horace parallel framework.

| communicator\media              | File-based |  Matlab MPI | mpiexec MPI |
| :----                           | :---:      | :---:       | :---:       |
| `Java Launcher`                 | **Native** | ---         | ---         |
| `Matlab MPI`                    | *possible* |  **Native** | ---         |
| `mpiexec MPI`                   | *possible* | ---         | **Native**  |
| `Job submission/initialization` | **Only**   | ---         | ---         |

Where the word *Native* indicates the medium a communicator is designed for (e.g. mpiexec is responsible for controlling the pool of parallel processes/programs, communicating through the MPI interface).
*Possible* means that, despite *Native* mechanisms existing, communication can be performed by alternative means,
i.e. *mpiexec* MPI processes can communicate by sending file-based messages if necessary.
This usually makes sense for debugging purposes only and is described in the **ClusterWrapper** classes chapter below.
The last row of the table indicates that each parallel job is initialized and controlled from the *Login Session* (**Fig 1**) using a file-based message,
i.e. the initialization information for a parallel task.
Logging of the progress and the information about the task results are distributed using file-based messages.

The file-based framework has been written with the assumption that *job chunks may be processed independently*,
and there are limited numbers of interprocess communications.
This restricts the use of file-based framework to this class of Horace algorithms and for job initialization.
Matlab MPI and standard MPI frameworks do not have such restrictions, but can not be used for submitting jobs to the cluster.

A cluster, executing a Horace job using the wrappers should have the following simple topology:

![Fig 1: Horace Cluster](../diagrams/HoraceMPICluster.png)

**Fig 1:** Cluster running Horace job with location of main software components of the parallel framework.

The diagram shows the interaction between the main hardware and software components, used to run these jobs.
Black boxes in **Fig 1** indicate the hardware components, namely parallel processes or parallel programs running Horace software.
Green boxes refer to the software components, running on the appropriate hardware.
The red arrows on the picture refer to the message transfer medium, used for communication between the processes/nodes.
Currently implemented Horace jobs mainly communicate with the *head node*, though this is an implementation detail rather than a constraint.
The frameworks allow for efficient communication between nodes.
The blue lines on the diagram refer to file-based message transfer, used to submit initial job and return job progress and information about the job results.
Black arrows, refer to the process of the software submission to the cluster, described in more details in the chapter on **Common initialization**.

From a user perspective, their interaction with a parallel job occurs the same way as they would work ordinarily with Horace analysing their data,
regardless of the underlying parallel structure, with Horace implicitly launching parallel jobs for time-consuming operations,
if parallel execution is configured for appropriate algorithms.

Generic Horace parallel job management and the interaction between software components is presented in **Fig 2**:

![Fig 2: MPI Framework](../diagrams/mpi-framework.png)

**Fig 2:**  Horace parallel job framework

The parallel framework currently operates under a fork-join model, where each task operates independently,
with limited communication between nodes.

An algorithm with parallel capabilities defines an appropriate **JobExecutor** class,
which together with correspondent parallel configuration, defined by  **parallel\_config** class is provided to **JobDispatcher**.
The **JobDispatcher** performs **ClusterWrapper** initialization according to that specified in the **parallel_config**
as well as dividing jobs into parallel "chunks" using a description of the physical problem, provided by **JobExecutor**.
**ClusterWrapper** starts the parallel cluster and takes the chunks of the job from the **JobDispatcher**,
formatted as job initialization messages.
**ClusterWrapper** sends these chunks to the parallel *workers*, which run independent Matlab instances,
executing the particular **JobExecutor** job chunks and communicating between each other using the appropriate **MessagesFramework**

The components of a Horace parallel job, presented in **Fig 1** and **Fig 2** and mentioned here are described below.

## Interfaces

A common interface has been implemented to ensure the operation of the parallel framework is independent of the underlying message framework.
As we only use a limited subset of MPI operations the interface is simpler than that of standard MPI or Matlab's Parallel Computing Toolbox.

## Job Management

#### JobExecutor:

Each independent Matlab or compiled Matlab session, controlled by any **Controller/ClusterWrapper** runs a *worker* script, which instantiates and runs **JobExecutor** class.
To run under the framework, a Horace parallel job has to inherit from the abstract **JobExecutor** class and define the main methods responsible for the particular job execution.

The methods to be defined for a job are:

**Table 2** Abstract methods of a **JobExecutor** class

| Method         | Description                                                                                       | Practical Example (From [*accumulate\_headers\_job*](https://github.com/pace-neutrons/Horace/blob/master/horace_core/sqw/%40accumulate_headers_job/accumulate_headers_job.m)  parallel algorithm) |
| :----          | :---                                                                                              | :---                                                                                                                                                                                              |
| `do_job`       | Do chunk of the job independent on other parallel executors                                       | Read range of tmp files and calculate this range average signal and error.                                                                                                                        |
| `reduce_data`  | Send result to head node (**Fig 1**) or receive partial result and combine them on the head node. | Send the average signal/error to node 1 or accept partial averages, sum them and send results to the logon node for node 1                                                                        |
| `is_completed` | Check if the job completed and return true if it is                                               | return true                                                                                                                                                                                       |

The **JobExecutor** parent class itself contains methods and properties responsible for inter-node communication and communication with the control node which launched the job.
The *worker* instantiates a job specific instance of **JobExecutor** child class and runs the following pseudo-code loop:

```matlab
 fbMPI = FileBasedFramework.initialize(Initialization_string) % Initialize file-based framework
 initialization_info = fbMPI.get_initialization_info();  % and obtain job initialization info,
                                                   %from the head node, running JobDispatcher

 TheJobExecutor.init(initialization_info);      % Initialized

 while ~TheJobExecutor.is_completed;
        TheJobExecutor.do_job();           % Do chunk of the work
        TheJobExecutor.labBarrier();       % Synchronize independent processes
        TheJobExecutor.reduce_data();      % Reduce intermediate data
 endwhile
 TheJobExecutor.labBarrier();

 TheJobExecutor.reduce_send_messages(Final result); % take final result and process it
 TheJobExecutor.finish_task();

```
The main methods and properties (M/P) of **JobExecutor** involved in a job control and inter-task communications are summarized in the table 3:

**Table 3** Main communication and control properties and methods of **JobExecutor** used in *worker* script

| Method or Property      | M/P  | Description                                                                                                                                                |
| :----                   | :--- | :---                                                                                                                                                       |
| `labIndex`              | P    | The ID(number) of the running task. (Worker Number in file-based, labIndex in Matlab or MPI rank+1 for MPI framework)                                      |
| `mess_framework`        | P    | Access to framework used for message exchange between the parallel tasks. (1)                                                                              |
| `control_node_exch`     | P    | The framework used to exchange messages between MPI job pool and the control (login) node. Contains initialized instance of a **MessagesFileBased** class. |
| `task_outputs`          | P    | The property, containing the result of `do_job` operation to distribute to other nodes or return to the head node(2) if these outputs are defined.         |
| *Communicator methods:* | ::   | *convenience methods, operating over defined messages frameworks*                                                                                          |
| `init`                  | M    | Initialize JobExecutor's communications capabilities.                                                                                                      |
| `reduce_send_message`   | M    | Collect (usually non-blocking (see below)) messages sent from nodes and send combined message to the head node(2)                                          |
| `log_progress`          | M    | Log progress of the job execution and report it to the calling framework.                                                                                  |
| `labBarrier`            | M    | Synchronize parallel workers.                                                                                                                              |
| `finish_task`           | M    | Safely finish job execution and inform other nodes about it.                                                                                               |

1) For file-based messages its the same as *control\_node\_exch*, but for other frameworks is usually different
2) Node 1 for nodes with N>1 or logon node for node 1

The file-based messaging framework is part of Herbert. As such, this framework is always available.
The input data of the particular parallel algorithm are separated into chunks and distributed to parallel workers using file-based messages.
The **JobDispatcher** class is responsible for splitting the task and instantiating the *worker*s which run user jobs, in parallel.

#### JobDispatcher:
To run the instances of **JobExecutor** in parallel, its input data have to be divided into appropriate chunks, and are sent for execution on the appropriate parallel environment.
The **JobDispatcher** class is responsible for distributing the task, controlling the parallel pool of workers, sending user job information to this pool and initial data for the user jobs, reporting the progress of the job and retrieving the job results for further use.
The main methods and properties (M/P) of this class are:

**Table 4** Main properties and methods of **JobDispatcher** class.

| Method or Property                         | M/P  | Description                                                                                                                |
| :----                                      | :--- | :---                                                                                                                       |
| **Job/Cluster identification properties:** | ::   | *Properties, used to identify the particular job and describe media, used in parallel execution:*                          |
| `job_id`                                   | P    | The ID to distinguish it from any other job, which may be running on a system.(1)                                          |
| `mess_framework`                           | P    | Instance of the file-based messages framework for exchange between *logon* node and the cluster.(2)                        |
| `cluster`                                  | P    | Exposes read access to the class controlling the cluster -- i.e. **ClusterWrapper** executing parallel job.                |
| `is_initialized`                           | P    | true if *JobDispatcher* already controls a cluster and does not need to start a new one.                                   |
| **Job control properties**:                | ::   |                                                                                                                            |
| `task_check_time`                          | P    | How often (in seconds) job dispatcher should query the task status and report progress to user.                            |
| `fail_limit`                               | P    | Number of times to try action before reporting failure.                                                                    |
| `time_to_fail`                             | P    | Time interval to wait before non-responsive jobs are considered failed and should be terminated.                           |
| **Job control Methods** :                  | ::   |                                                                                                                            |
| `start_job`                                | M    | Begin execution of a parallel process from the beginning. Returns the results of the job.                                  |
| `restart_job`                              | M    | Restart parallel Matlab job started earlier by *start\_job* command with new input data as though calling *start\_job*.(3) |
| `finalize_all`                             | M    | Stop parallel processes and delete cluster. Clear all existing messages.                                                   |
| `display_fail_job_results`                 | M    | Auxiliary method to display job results if jobs have failed.                                                               |
| `split_tasks`                              | M    | Divides input information between child processes. Returns the array of messages to initialize each worker of the cluster. |

1) A folder with this name is created by **MessagesFilebased** class to hold file-based messages related to this job.
2) The one used for initialization, logging from head node and returning some results (See **Table 1**).
3) The cluster to do the job must be running.

One of the main properties of **JobDispatcher** class is *cluster* property, containing an instance of **ClusterWrapper** class,
which is responsible for controlling the parallel processes or programs, i.e. the *cluster*.
The **JobDispatcher** controls and communicates with the cluster through the **ClusterWrapper** properties, described below.

## Cluster Management
Cluster classes are responsible for launching and initializing parallel workers, retrieving job progress and finalizing the parallel execution.
The parent for all cluster classes is a **ClusterWrapper** class, which provides common interface for the communicators/controllers managing the parallel processes itself.
**Fig 3** shows the **ClusterWrapper** interface and lists the current implementations of cluster classes.

![Fig 3: Cluster Wrapper](../diagrams/ClusterWrapperInterface.png)

**Fig 3:** Cluster Wrappers interface and its current implementations.

The particular implementation of a cluster overloads and expands *init* method of **ClusterWrapper**,
which is responsible for launching the parallel process and implements the standard methods for the medium.
The majority of the methods do not need extensive extension, as all deploy file-based messaging framework to exchange information with the cluster.
The list of the main methods is provided in the **Table 5** below.

Every cluster uses and may expand the **ClusterWrapper** methods used by **JobDispatcher** to control the jobs:

**Table 5** A Cluster properties and methods list:

| Method or Property              | M/P   | Description                                                                                                                                 |
| :---                            | :---: | :---                                                                                                                                        |
| `job_id`                        | P     | The ID of the running cluster and its jobs. It is the same name as *job\_id* in the **JobDispatcher**.                                      |
| `n_workers`                     | P     | number of independent parallel *workers*, running on the cluster.                                                                           |
| `status`                        | P     | Set of properties, used to control the cluster state and the job progress. Used by **JobDispatcher** to check and display the job progress. |
| `exit_worker_when_job_ends`     | P     | Logical property, indicating if cluster should be shut-down after the job is finished, or if it should be run waiting for the next job.     |
| `pool_exchange_frmwk_name`      | P     | Messages exchange framework for exchanging information between parallel workers.(1)                                                         |
| **Job Control methods:**        | ::    | *list of the methods, used to control the parallel job*:                                                                                    |
| `init`                          | M     | Accepts number of independent workers and physically start these parallel processes.                                                        |
| `start_job`                     | M     | Sends initialization messages generated by *JobDispatcher* to parallel processes to start the actual job execution.                         |
| `check_progress`                | M     | Check the messages, indicating the progress of the parallel job and receive these messages.                                                 |
| `display_progress`              | M     | Report job progress using internal state of the cluster calculated by executing *check\_progress* method                                    |
| `retrieve_results`              | M     | Get the results of the parallel job execution.                                                                                              |
| `finalize_all`                  | M     | Close parallel framework, delete file-based exchange folders and complete parallel job.                                                     |
| **Factory methods**             | ::    | *list of the methods, used by MPI\_fmwks\_factory to identify and work with available cluster types:*                                       |
| `check_availability`            | M     | true if cluster of given type is available on given machine.                                                                                |
| `get_cluster_configs_available` | M     | List of available cluster types. (2)                                                                                                         |

1) Typically the same as the cluster message exchange framework type (see **Table 1**), but  can be file-based message exchange.
2) A given type of cluster (except **ClusterHerbert**) may have different configurations. E.g., for **ClusterMPI** it may be *local* for running MPI on a local machine or clusters described by **mpiexec** hosts files. These files should be located in special clusters configurations folder.

To provide simple selection of a framework, all subclasses of **ClusterWrapper** are subscribed to framework factory **MPI\_clusters\_factory**. User interacts with the factory through **parallel\_config** configurations class:

![Fig 4:  Parallel Framework Selection](../diagrams/SelectClusterWrapper.png)
**Fig 4:** Selection of a parallel framework. The cluster classes are subscribed to factory with the following names: **herbert:->ClusterHerbert; parpool:->ClusterParpoolWrapper; mpiexec_mpi:->ClusterMPI**

**Parallel_config** class receives a list of the subscribed and available Cluster Wrapper names from **MPI\_clusters\_factory** and the user selects the appropriate wrapper and framework.
**Job_dispatcher** then uses the factory method **get\_running\_cluster** to start the cluster and use it for running the parallel job defined by the **JobExecutor** instance.

A brief description of the **ClusterWrapper** factory is provided in the **Table 6**

**Table 6** MPI clusters factory methods.

| Method or Property    | Access | Description                                                                                                  |
| :---                  | :---:  | :---                                                                                                         |
| *Properties list:*    | -      |                                                                                                              |
| `parallel_cluster`    | `RW`   | Returns or accepts the name of the cluster and message exchange framework to use as default.                 |
| `known_cluster_names` | `R`    | Returns the list of names of the parallel clusters, defined in Herbert and subscribed to factory.            |
| *Static Method*       | -      |                                                                                                              |
| `instance`            | `R`    | Return unique instance of the factory.                                                                       |
| *Methods*             | -      |                                                                                                              |
| `get_cluster`         | `R`    | Return the uninitialized instance of the cluster of given type.                                              |
| `get_all_configs`     | `R`    | Return list of configurations, available for cluster of given type. (1)                                      |
| `get_running_cluster` | `R`    | Initialize and return the initialized and running MPI cluster of given size, and set as the default cluster. |

1) See **parallel_config** description on the details about the cluster configuration

The user normally interacts with this factory through the **parallel_config** class, selecting which cluster to use.
**JobDispatcher** then uses this factory's `get_running_cluster` method to start the parallel cluster.

Each cluster runs its own parallel processes.
To be useful, the processes should interact with each other.
Messages framework classes are responsible for providing a common interface for message exchange within the cluster and message exchanges between **JobDispatcher**s running on the *login node* of the and the *head node*.

## Message Framework

A message framework is responsible for handling the information exchange between independent workers.
The messages API itself is built using very reduced subset of standard MPI API, hiding more complex details from users.
The information is transmitted through corresponding medium and wrapped by **Messages**, which are the instances of special *messages classes*, described in detail in the next chapter.
The same interface is used for sending the initial job description and parameters from the *logon node* to cluster nodes, but as neither Matlab MPI nor normal MPI are available for communications between logon node and a parallel job, only the file-based framework and file-based messages are used for a job initialisation.

The parent for all message framework classes is the abstract **iMessagesFramework** interface, which provides methods, common to all message frameworks, and defines interfaces for the methods, whose implementations vary.

![Fig 5: Messages interface](../diagrams/iMessagesInterface.png )

**Fig 5:** Messages Framework

Each message framework natively works with appropriate cluster wrapper.
This is why no independent factory exists to select framework as, by default, each cluster uses its native framework.
The **ClusterWrapper** property  *pool\_exchange\_frmwk\_name* can be used to set the **MessagesFilebased** framework to perform exchange between independent workers.
This is a very inefficient mechanism which should be used for debugging only.

Main Messages Framework methods are provided in the **Table 7**

**Table 7** Main message framework methods and properties.

| Method or Property          | M/P   | Description                                                                                                                                   |
| :---                        | :---: | :---                                                                                                                                          |
| `job_id`                    | P     | The ID of the running cluster and its jobs. It is the same name as *job\_id* in the **ClusterWrapper**.                                       |
| `labIndex`                  | P     | The ID of parallel process, used to identify the particular parallel worker.                                                                  |
| `NumLabs`                   | P     | Total number of workers in the parallel pool.                                                                                                 |
| `time_to_fail`              | P     | Time in seconds a system waits for blocking message until returning "not-received".                                                           |
| `throw_on_interrupts`       | P     | The property defines framework behaviour in case when interrupt message (cancelled or failed) received through the network. (1)               |
| **Common service methods:** | ::    | *Methods, used by all frameworks regardless of the framework type:*                                                                           |
| `build_worker_init`         | M     | Generate ASCII string, used for initialization of all workers. See **Common initialization**.                                                 |
| `get_interrupt`             | M     | Check if an interrupt message was received before and return it. See **Interrupts** below.                                                    |
| `set_interrupt`             | M     | Check if the input message is an interrupt message and store interrupt message in the interrupt buffer. See the chapter **Interrupts** below. |
| `retrieve_interrupt`        | M     | Add interrupt messages to the list of the messages received from other labs if interrupt message has been received. See **Interrupts** below. |
| **Abstract methods:**       | ::    | *The methods, exposing interface to MPI communications. Implementation is specific for each framework:*                                       |
| `init_framework`            | M     | Initialize framework with given input data.                                                                                                   |
| `send_message`              | M     | Send message to a specified worker. Non-blocking.                                                                                             |
| `receive_message`           | M     | Receive message from the specified task. (2)                                                                                                  |
| `probe_all`                 | M     | List all messages existing in the system from the tasks requested. Non-blocking.                                                              |
| `receive_all`               | M     | Receive all messages directed to current node and from the tasks with given IDs (2,3).                                                        |
| `labBarrier`                | M     | Synchronize parallel worker execution and wait until all independent workers arrive at the barrier.                                           |
| `clear_all`                 | M     | Receive and reject all messages directed to the current node including interrupt messages.                                                    |
| `finalize_all`              | M     | Shut down parallel framework and parallel cluster.                                                                                            |

1) Normally this means that all processing would be completed and worker shut-down so exception would be thrown. When the framework is gathering information on exceptions to report issue to user, interrupt messages are received to be processed by framework to return the diagnostics to users. The property in this case is set to false.
2) The user can explicitly request synchronous or asynchronous operation providing appropriate option ['-synchronous'!'-asynchronous']
3) Non-blocking if issued without any message name or with keyword *any* and blocking if a requested message name is specified.

A Horace job uses the relevant implementation of  **iMessageFramework** and uses the methods defined in the interface above to communicate with neighbouring workers when it becomes necessary.
Some coarse logic, providing basic communications and synchronization is implemented in the *worker* script.

The developer should expect that errors may happen during a worker execution, and a *Fail* or *Cancelled* message can be sent from the client instead of the regular exchange message.

If a *receive_message* command is issued in synchronous mode, the framework based on the real MPI exchange checks for interrupt once, and enters into synchronous MPI read or wait state, waiting for the appropriate synchronous message to appear.
If an interrupt message has been sent instead regular message, indicating error or cancellation issued by other parallel worker, the receivers remain waiting for initial message state.
An interrupt message usually indicate a critical failure so the framework will be cancelled through parallel interrupt, but if this is not happening, the parallel worker will hang up.
The *receive_all* method should be used instead of *receive_message* in any situation where synchronous receive can be interrupted.
The *receive_all* method will also fail on time-out if the requested synchronous message is not sent within the expected time interval.

#### Common initialization.

Different frameworks launch different types of parallel processes, but each process should know what sub-task it needs to perform.
The job description can be very different in size, so it is better to provide descriptions by writing appropriate description files.
Command line arguments provide each parallel worker with information about the location of the folder where the job initialization information, along with some auxiliary information, is written.
Currently auxiliary information contains the name of the *message framework* used for communications between workers and worker number (*labNum*) for a file-based messages framework.
To avoid issues with different frameworks and different operating systems processing non-ASCII characters in a command line differently,
the location information is encoded into single ASCII-128 string using standard Java base64 encoder.
The *build_worker_init* method of **iMessagesFramework** performs the encoding of the input initialization information for the transfer of this information to the parallel workers via command line arguments.

#### Interrupts or Persistent messages.

Independent workers may need to report to the other workers that some special conditions occurred during their execution.
These conditions currently result in a failure (an interrupt is raised at code execution).
We use Persistent (a.k.a. Interrupt) messages to distribute information about such states of the system as parallel interrupts,
as standard MPI interrupts normally used for these purposes in MPI frameworks are not available for all parallel frameworks.
Such a message, received by a worker from another worker, blocks all further communication with this worker.
All requests for information from this worker result in the persistent message (*failure*).
This state holds until special command (*clear_all* above) is executed by the receiving worker.

#### Messages types.

Different operations can be handled using different types of messages. There are 3 main types, differentiated in Horace.

1. Logging, diagnostics and informing user about progress of a job.
2. Interprocess data exchange, necessary for performing a particular user job and
3. Information about error or failure.

The following types of messages exist to meet these requirements:

1. Non-blocking (transient) messages. Informing user about a job's progress is an important task, but often the user is interested only in the final value.
   Different independent tasks should not need to be synchronous with regard to log messages as only some average progress is required.
   Non-blocking messages are best suited for this kind of task.
   If more then one non-blocking message is present in the MPI messages queue, the client receives only the last message.
2. Blocking messages are necessary to transfer information between independent workers when the results of calculations depend on results on other nodes.
3. Persistent messages necessary to indicate some critical conditions or error states, as, for example,
   parallel interrupts available in MPI are not available in file-based messages system (*ClusterHerbert*) and not accessible for Matlab MPI (*ClusterParpool*).
   Persistent messages are used to carry such information.

To provide the described flexibility and variability of messages, all messages used by Horace MPI are subclasses of the **aMessage** class and subscribed to a messages factory (see below).

## Messages class and messages factory.
### Messages:

Information transferred between independent workers is wrapped into message classes, which are the children of **aMessage** class.
The job specific data to transfer is assigned to the *payload* property.
Any Matlab data can be assigned to the *payload* property,
the only requirement is that the data are serializable, i.e. it is either basic Matlab data type or a class which have *saveobj/loadobj* methods or can be correctly converted to/from a structure.

The appropriate processing of messages data (see the **Messages types** above) is assured by different message classes.
The simplest messages classes are just instances of **aMessage** class with different names, indicating different states.
Examples of such messages are the `starting`  or `cancelled`  messages, indicating the appropriate states of the program.
Some messages need additional functionality, so additional properties are defined for the subclasses, describing these messages.
Any message class must subclass the **aMessage** class and must follow the naming convention *`MessageClassName = [MessageName, 'Message']`*.
This convention is enforced by messages factory **MESS_NAMES**, where each message is subscribed as the lower case of `messagename` of the message class name.
The factory is described in the next chapter.
The current family of specialized message classes is presented in **Fig 6**

![Fig 6: Messages Family](../diagrams/aMessagesTree.png)

**Fig 6** Existing family of messages classes

Additional properties and methods of overloaded message classes should just be convenient methods to get or modify the *payload* property below.

**Table 8** Main properties of **aMessage** class:
| Method or Property | M/P   | Description                                                                                                         |
| :---               | :---: | :---                                                                                                                |
| `payload`          | P     | Serializable data to be transferred.                                                                                |
| `mess_name`        | P     | Human readable message class name.                                                                                  |
| `tag`              | P     | Class ID assigned upon subscription to the factory, used as tag in standard MPI interfaces to identify the message. |
| `is_blocking`      | P     | true if message is blocking message (see **Messages types** of previous chapter)                                    |
| `is_persistent`    | P     | true if message contains the information about critical task state (see **Messages types** of previous chapter)    |
| `saveobj`          | M     | Convert message into a serializable structure                                                                       |
| `loadobj`          | M     | Build message from the structure, obtained by *saveobj* method                                                      |

Algorithms which need to send a message, instantiate an appropriate message by its constructor.
The constructor of **aMessage** class calls the **MESS\_NAMES** factory, checks the message subscription and verifies the correct constructor has been invoked.

### MessagesFactory:

The messages factory contains common information about all messages defined in the system.
Currently messages factory is responsible for
associating message names with message tags,
identifying and verifying the specific message classes (presented in **fig 6**) and
verifying the correct subclasses of **aMessage** class are instantiated for those messages with specialized class overloads.
All messages used by PACE are subscribed to the messages factory class **MESS\_NAMES**.
The messages are registered in the factory by their meaningful name (*mess\_name*). Currently, the following message names are defined:

 *'any', 'completed', 'pending', 'queued', 'init', 'starting', 'started', 'log', 'barrier', 'data', 'cancelled', 'failed'*

Where *any* is not strictly a message class, but the corresponding name of the tag which refers to any type of message in the system.
Not all messages are used by every framework.
For example, the `barrier` message is only used by the **MessagesFilebased** framework. Other frameworks use the MPI specific command `barrier` to achieve process synchronization.

There is agreement within the frameworks' code, that the *any* message has tag -1.
As Matlab MPI does not accept negative tags, the Herbert framework tags are shifted internally to get valid Matlab tags and Matlab tags are shifted back at receive to be consistent Herbert framework tags.

Messages which do not have a defined message class (i.e. not an explicit subclass) should be instantiated through calling the **aMessage** class constructor with a specific *mess\_name*.
For example, messages which identify the start and end of task initialization are **aMessage** classes instances with the names *starting* and *started*.
These messages are instantiated as **aMessage(`starting`)** and **aMessage(`started`)**.
*log* messages, which contain more advanced information about the progress of the job, need to be initialized by their own constructor **LogMessage(step,n\_steps,step\_time,add\_info)**
(see the class documentation describing the log message parameters meaning).
As a specific subclass for *log* message exists, *log* messages can not be instantiated by simply calling **aMessage('log')**.
The **MESS\_NAMES** factory, called within **aMessage** class constructor, would throw an error on this.

Main methods, defined by the **MESS\_NAMES** factory are summarized in **Table 9**.
All methods of the factory are static methods.

**Table 9** Main methods and properties of the **MESS\_NAMES** factory.

| Method or Property | M/P   | Description                                                                                                                         |
| :---               | :---: | :---                                                                                                                                |
| *Properties*       | -     | *Read-only class properties accessible through the instances of* **MESS\_NAMES**  *factory:*                                        |
| `known_messages`   | P     | List of the messages registered with the factory.                                                                                   |
| `is_initialized`   | P     | true if messages factory is initialized.                                                                                            |
| `interrupts`       | P     | List of the message names which can be used as interrupts (see message types).                                                      |
| `interrupts_tags`  | P     | List of the message tags which can be used as interrupts.                                                                           |
| *Class methods:*   | -     | *methods, accessed through the instance of the* **MESS\_NAMES** *class:*                                                            |
| `is_registered`    | M     | true if the given message name is registered with the factory.                                                                      |
| `is_subscribed`    | M     | true if the given message name is subscribed to the factory.                                                                        |
| `get_mess_class`   | M     | Return empty instance of a message of given class.                                                                                  |
| *Static methods*   | -     |                                                                                                                                     |
| `instance`         | M     | Return single, unique instance of the **MESS\_NAMES** class.                                                                        |
| `get_class_name`   | M     | Return corresponding class name for given message class name. (Specialized class name **NameMessage** if available or **aMessage**) |
| `mess_id`          | M     | Return the message tag of given message name.                                                                                       |
| `mess_name`        | M     | Return the message name of given message tag.                                                                                       |
| `tag_valid`        | M     | Verify given tag is a valid message tag.                                                                                            |
| `is_blocking`      | M     | true if the given message name is a blocking message class.                                                                         |
| `is_persistent`    | M     | true if the given message name is a persistent message class.                                                                       |

## Parallel configuration

The optimal setup should be identified for a given system, such as the appropriate message framework and other parallel settings.
These should stored and used for all subsequent calculations on that system.
The **parallel\_config** class is used to store this configuration and return these settings to the appropriate factories.
The class is a child of **config\_base**, which provides the ability to save appropriate values to configuration files and load these values on request.

The properties of the **parallel\_config** class provides are listed in **Table 10**

**Table 10** Parallel configuration settings.
| Property                  | R/W   | Description                                                                                                                        |
| :---                      | :---: | :---                                                                                                                               |
| `worker`                  | `RW`  | The name of the script or program to run on cluster in parallel using parallel workers.                                            |
| `is_compiled`             | `R`   | true if this script is compiled using the Matlab applications compiler.                                                            |
| `parallel_framework`      | `RW`  | The name of the parallel framework to use. Frameworks currently available are **`herbert`**, **`parpool`** and  **`mpi_cluster`**. |
| `cluster_config`          | `RW`  | The configuration class describing parallel cluster to run selected framework                                                      |
| `shared_folder_on_local`  | `RW`  | The folder to contain the job input and output data                                                                                |
| `shared_folder_on_remote` | `RW`  | The folder where shared data can be found on a remote worker (1)                                                                   |
| `working_directory`       | `RW`  | The folder containing input data for the job and where tmp and output results should be stored. (2)                                |
| `known_frameworks`        | `R`   | Return list of the parallel frameworks known to Herbert and available on the machine                                               |
| `known_clust_configs`     | `R`   | Return list of the clusters available to run the selected framework                                                                |

1) Can be useful if slave nodes have a different view of the filesystem, otherwise should be the same as `shared_folder_on_local`
2) Needs to have the same view from the local and remote workers else inconsistencies can happen.

## MPI state helper

The code used by the MPI framework must also be able to run serially.
The serial implementation may be complex and it is desirable to only make minor changes to the serial code to accommodate parallel execution.
Any code to be executed in parallel needs to inherit from the **JobExecutor** class.
When calling previously serial functions through the parallel framework,
it is inconvenient to have to modify the interface of the serial functions to get access to the methods of the **JobExecutor** class
(e.g. to deploy MPI logging functionality when the code runs in parallel).

The singleton **MPI\_State** exists to address this issue.
When the code is run under any of the messaging frameworks, a *parallel\_worker* sets **MPI\_State**'s *is\_deployed* property to true.
In addition to that, the **MPI\_State** contains methods useful within the serial section.
These functions are currently *log\_progress* and *is\_cancelled*.

The serial code modified with the checks may look like:
```matlab
if MPI_State.instance().is_deployed
        if MPI_State.instance().is_cancelled
                throw error -- parallel job is cancelled
        else
                MPI_State.instance().log_progress() % to parallel framework
        end
else
        report serial job progress to user
end
```

In addition to this **MPI\_State** gets several properties from the *parallel\_worker* and provides them to relevant parts of the parallel framework used for message exchange between workers.
The use of MPI methods direct within mainly serial code is undesirable as it makes serial code require a parallel framework, but may be necessary for particular purposes and jobs.

## Some details of implementation and operations
### Error processing
On error, the user job, running on the **JobExecutor** throws the appropriate exception.
This exception is intercepted in *parallel\_worker* and processed by **JobExecutor**'s *process_fail_state* method.
The method checks the exception and if it is not a **PARALLEL_FRAMEWORK:cancelled** exception, sends *CancelledMessage* to all other workers and terminates the failing task.
The cancellation message is always identified as incoming by the *probe_all* method and will be received as a priority over any other expected message by any *receive* method.
If the message is received by **JobExecutor**'s *receive_all* method, the **PARALLEL_FRAMEWORK:cancelled** exception is thrown by the *parallel\_worker*.
This exception, when caught by a parallel worker, will terminate its task.
If the user job receives messages using a framework *receive* method directly, or sets the framework property *throw_on_interrupts* to false,
it is necessary to establish custom processing for receiving *CancelMessage*s.

### Interrupts storage
Received interrupts are stored in a cache with keys corresponding to the task-id that triggered the interrupt.
The purpose of this is to provide better diagnostics of the cause of the interrupt.
The logic on failure is that: on receiving an interrupt message, the framework throws a **PARALLEL_FRAMEWORK:cancelled** exception, which is handled by the *finish_task* method of the **JobExecutor**.
The *finish_task* method under normal execution waits synchronously for **completed** messages from all parallel workers.
In case of failure, these messages are the appropriate interrupt messages, received from the corresponding tasks.

### Messages channels
To understand framework's operation, it is convenient to assume that the framework implicitly organizes message propagation using three channels: namely synchronous, asynchronous and interrupt.
Any receive operation scans an appropriate (synchronous or asynchronous depending on message type) channel along with the interrupt channel and returns the data.
Synchronous receive waits for a message to appear, where asynchronous returns empty if nothing is available when the request has been issued.
