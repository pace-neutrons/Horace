# Parallel hardware and software requests for excitation group.
Date: 2021-01-15

## User requests, how they are satisfied now and insufficient computational resources for advanced analysis.
The users of ISIS facility who performs excitation experiments are generating large data volumes (up to 0.5Tb observed) and request substantial processor power to process these data and the access to fast parallel file system to store and efficiently manage the data.
From the point of view of the computational resources necessary for a excitation user, one may separate two tasks with subtasks, arranged in the order of increasing computational power requested:
 1. Generation and primary analysis of the results of an experiment. This includes:
  1a) Initial data reduction.
  1b) Generation of multidimensional scattering images (sqw files) and their initial analysis (visualization)
  1c) Primary analysis of these images (symmetrization, background subtraction, arithmetic operations)
 2. Modelling and comparison between a model and the experimental results, namely:
  2a) Fitting to simple models (Multifit)
  2b) Fitting to simple models accounting to resolution effects (Tobyfit)
  2c) Simulation of complex models (e.g. SpinW or Castep )
  2d) Comparison and fitting between experiment and complex models accounting for resolution effects.

### Task 1 Primary analysis. Cutting, slicing, viewing:
It is mainly satisfied by iDaaaS service, thought has some minor shortcomings:
   * 1a. is performed in Mantid and iDaaaS virtual machines provide sufficient resources to run Mantid for data reduction.
   * 1b. is performed in Horace, using Horace parallel extensions and is mainly file-IO bound process. Now redundant ISISCOMPUTE service was providing large physical machines (~100CPU, 0.5Tb RAM, fast parallel file system), which allow efficiently run 8-16 parallel Horace instances, each instance using ~8 processors, doing parallel IO to access the data. There were no point of increasing number of parallel process, as the data analysis speed was constrained by parallel file system access speed.
   Current iDaaaS service provides fewer processors per session with almost the same parallel file system access speed. Despite decreasing functionality and smaller memory (90Gb), it allows efficiently run 4-6 independent Horace instances the newer processors and good parallel file access speed provide reasonable performance for the task. Despite the speed of generating large sqw files on iDaaaS virtual machine is 1.5-2 times higher then iDaaaS, it is mainly adequate for the user needs.
   * 1c. is performed in Horace. Horace parallel extensions are available for symmetrization, but are currently under development for other operations. The task is more demanding to memory and CPU resources then 1b, so ISISCOMPUTE was had insufficient power to run this task efficiently. To make the symmetrization an IO bound task, a user would need to run 32 or more independent parallel Horace instances, and running 32 instances on ISISCOMPUE made multi-user machine unresponsive to other users. iDaaaS is even less adequate for this task as has to decrease the number of independent processes used for  symmetrization due to memory constrains. Users performed this task on ISISCOMPUTE and now moved to iDaaaS are unhappy. Luckily there are very few such users.

### Task 2 Advanced analysis. Simulation and fitting:
We do not currently able to run the software, necessary to perform Task 2, in parallel. iDaaaS provides adequate resources to run single instance analysis. One of the ongoing PACE project objectives is to provide enhanced capabilities for performing Task 2 (simulation and modelling). Other objective is to write parallel extensions to run this task, so iDaaaS resources will become insufficient for performing tasks 2b-2d, even less sufficient then currently for doing task 1c.

## Ways to address the luck of computational resources.

There are three possible approaches of addressing the luck of computational resources, necessary to perform advanced analysis:
1. Provide users with more big machines like ISISCOMPUTE and even bigger machines.
2. Connect users to an existing parallel cluster like SCARF and modify the software using its parallel capabilities.
3. Group number of smaller iDaaaS machines in a cluster and provide users with convenient way of submitting their analysis jobs to it.

Though approach 1 is conceptually simpler and easier to parallelize, as parallel software for a large machine may use threads and shared memory programming instead of MPI communications necessary for cases 2 and 3, it has substantial disadvantages. The solution is hardly scalable as more computational resources for a user would mean buying bigger machine. It is also inefficient, as user spends substantial part of his time looking at the results or doing simple and small jobs (e.g. small cuts) and analysing (viewing) results. During all this time the expensive large hardware is not used. If a larger machine is used as multi-user machine, the resource sharing becomes a problem as if two users try to perform high-CPU/IO tasks simultaneously, they mutual performance gets highly affected and no simple ways of resolving the conflict exists.
Large virtual machines used for analysis within this approach remove number of disadvantages, like access to hardware or creation new and larger machines, but are still inefficient as most of his time user is not utilizing the whole resources of a large machine. Ignoring this inefficiencies, such approach would be easiest to utilize from the development point of view.

Approach 2, i.e. SCARF lucks the simple access to large data and parallel file system. Though parallel file system and parallel access is available from the cluster nodes running parallel job, the system is ill suited for interactive applications and does not provide good access for parallel IO from the user node. In addition to that, the problem of transferring large user data to and from the computational cluster does not seems have easy solution and would request high user involvement. Because of that, clusters like SCARF become very inconvenient for initial data analysis (Task 1) and if user tries to move from simple to advanced analysis he faces problem of transferring ~Tb of data from one file system to another using slow links. This makes analysis prohibitive for an average user. Saying so, some users may need high CPU requests to perform analysis (Task 2), so our software will need to support SCARF.

Approach 3 is the approach best suitable for our needs, as user does primary analysis using existing iDaaaS capabilities and when he request more for advanced analysis he just submits a parallel job to parallel iDaaaS cluster running on the same parallel file system. The approach promises additional advantage over Approach 1 running large iDaaaS machine, as the iDaaaS cluster nodes would have independent access to parallel file system so may provide better IO speeds. 

## Resources and development necessary to satisfy excitation group requests:

Summarizing the above information, we need access to specialized hardware with controlling software and need to adapt our software and development practices to this hardware. Different groups of the hardware users perform different tasks, so different hardware, controlling software configurations and access rights are necessary for different tasks. We have identified the following groups of users, requesting different things:
1. Users performing the initial analysis of the results of experiment
2. Users performing advanced analysis and simulation
3. Developers, testing serial software on iDaaaS cluster.
4. Developer, testing parallel software on iDaaaS cluster.
5. Automation software (Jenkins) running automating tests for software.

In details:
 * 1. Group one request are satisfied by current iDaaaS service.
 * 2. Users of this group need access to parallel iDaaaS cluster.
  namely:
Number of iDaaaS nodes (the configuration similar to Excitation small machine configuration is a good candidate for a node configuration), should be connected into virtual cluster, available for users to submit jobs. 16, 32 and 64 nodes per cluster would satisfy different users requests. Different ways of connecting the nodes into cluster and submitting jobs to this cluster are available. iDaaaS team suggests that [Slurm job management system](https://slurm.schedmd.com/overview.html) can be deployed to connect iDaaaS nodes into cluster and control the job running on this cluster. Such cluster will be provided to us **by iDaaaS team**. [PACE project](https://github.com/pace-neutrons) [parallel framework](https://github.com/pace-neutrons/Horace/blob/master/documentation/add/04_mpi_framework.md) is written to support Horace parallel job execution. The job submission mechanism for the framework has common interface described and implemented within the *ClusterWrapper* class (see the details in the [Cluster Management](https://github.com/pace-neutrons/Horace/blob/master/documentation/add/04_mpi_framework.md) chapter of the [parallel framework](https://github.com/pace-neutrons/Horace/blob/master/documentation/add/04_mpi_framework.md) documentation). The appropriate *SlurmClusterWrapper* class to work with Slurm job management system has to be written by **PACE team**.
 * 3.