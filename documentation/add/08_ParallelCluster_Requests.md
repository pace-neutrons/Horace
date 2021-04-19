# Parallel hardware and software requests for excitation group.
Date: 2021-01-15

## User requests, how they are satisfied now and insufficient computational resources for advanced analysis.
The users of the ISIS facility who performs excitation experiments are generating large data volumes (up to 0.5Tb observed) and request substantial processor power to process these data and then the access to fast parallel file system to store and efficiently manage these data.
From the point of view of the computational resources necessary for an excitation user, one may separate two tasks with subtasks, arranged in the order of increasing computational power requested:
 1. Generation and primary analysis of the results of an experiment. This includes:
  1a) Initial data reduction.
  1b) Generation of multidimensional scattering images (sqw files) and their initial analysis (visualization)
  1c) Primary analysis of these images (symmetrization, background subtraction, arithmetic operations)
 2. Modelling and comparison between a model and the experimental results, namely:
  2a) Fitting to simple models (Multifit)
  2b) Fitting to simple models accounting for resolution effects (Tobyfit)
  2c) Simulation of complex models (e.g. SpinW or Castep )
  2d) Comparison and fitting between experiment and complex models accounting for resolution effects.

### Task 1 Primary analysis. Cutting, slicing, viewing:
It is mainly satisfied by iDaaaS service, thought has some minor shortcomings:
   * 1a. is performed in Mantid and iDaaaS virtual machines provide sufficient resources to run Mantid for data reduction.
   * 1b. is performed in Horace, using Horace parallel extensions and is mainly file-IO bound process. Now redundant ISISCOMPUTE service was providing large physical machines (~100CPU, 0.5Tb RAM, fast parallel file system), which allow efficiently run 8-16 parallel Horace instances, each instance using ~8 processors, doing parallel IO to access the data. There were no point of increasing number of parallel process, as the data analysis speed was constrained by parallel file system access speed.
   Current iDaaaS service provides fewer processors and smaller memory per user session with almost the same parallel file system access speed. Despite decreasing functionality and smaller memory (90Gb), it allows efficiently run 4-6 independent Horace instances. The newer processors and good parallel file access speed provide reasonable performance for the task. Despite the speed of generating large sqw files on iDaaaS virtual machine is ~1.5 times lower than on ISISCOMPUTE, it is mainly adequate for the user needs.
   * 1c. is performed in Horace. Horace parallel extensions are available for symmetrisation, but are currently under development for other operations. The task is more demanding to memory and CPU resources then 1b, so ISISCOMPUTE had insufficient power to run this task efficiently. To make the symmetrization an IO bound task, a user would need to run 32 or more independent parallel Horace instances, and running 32 instances of Horace computational engine on ISISCOMPUE made multi-user machine unresponsive to other users. iDaaaS is even less adequate for this task as has to decrease the number of independent processes used for  symmetrisation due to memory constrains. Users performed this task on ISISCOMPUTE and now moved to iDaaaS are unhappy. Luckily, there are very few such users.

### Task 2. Advanced analysis. Simulation and fitting:
We do not currently able to run the software, necessary to perform Task 2 in parallel on the Horace level, i.e. not doing MPI parallelization. Users may write their own Matlab or C\++(mex) functions, providing Matlab parallel toolbox or C++ OMP parallelisation capabilities. iDaaaS provides adequate resources to run single instance analysis with user parallelisation on all processors, available on a machine. One of the ongoing PACE project objectives is to provide enhanced capabilities for performing Task 2 (simulation and modelling). Other objective is to write parallel extensions to run this task, so iDaaaS resources will become insufficient for performing tasks 2b-2d, even less sufficient then currently for doing task 1c.

## Ways to address the lack of computational resources.

There are three possible approaches of addressing the lack of computational resources, necessary to perform advanced analysis:
1. Provide users with more big machines like ISISCOMPUTE and even bigger machines.
2. Connect users to an existing parallel cluster like SCARF and modify the software using its parallel capabilities.
3. Group number of smaller iDaaaS machines in a cluster and provide users with convenient way of submitting their analysis jobs to it.

Though **approach 1** is conceptually simpler and easier to parallelise, as parallel software for a large machine may use threads and shared memory programming instead of MPI communications necessary for cases 2 and 3, it has substantial disadvantages. The solution is hardly scalable as more computational resources for a user would mean buying bigger machine. It is also inefficient, as user spends substantial part of his time looking at the results or doing simple and small jobs (e.g. small cuts) and analysing (viewing) results. During all this time the expensive large hardware is not used. If a larger machine is used as multi-user machine, the resource sharing becomes a problem as if two users are trying to perform high-CPU/IO tasks simultaneously, they mutual performance gets highly affected and no simple ways of resolving the conflict exists.
Large virtual machines used for analysis within this approach remove number of disadvantages, like access to hardware or creation new and larger machines, but are still inefficient, as most of his time user is not utilizing the whole resources of a large machine. Ignoring these inefficiencies, such approach would be easiest to utilize from the development point of view.

This approach can be resurrected if situation changes as it minimizes the need for software development, but requests investment into out-of shelves high-performance hardware.

**Approach 2**, i.e. SCARF lacks the simple access to large data and parallel file system. Though parallel file system and parallel access is available from the cluster nodes running parallel job, the system is ill suited for interactive applications and does not provide good access for parallel IO from the user node. In addition to that, the problem of transferring large user data to and from the computational cluster does not seem have an easy solution and would request high user involvement. Because of that, clusters like SCARF become very inconvenient for initial data analysis (Task 1) and if user tries to move from simple to advanced analysis he faces problem of transferring ~Tb of data from one file system to another using slow links. This makes analysis prohibitive for an average user. Saying so, some users may need high CPU requests to perform analysis (Task 2), so our software will need to support SCARF.

**Approach 3** is the approach best suitable for our needs, as user does primary analysis using existing iDaaaS capabilities and when more resources are necessary for advanced analysis, the user just submits a parallel job to parallel iDaaaS cluster running on the same parallel file system. User uses the same interface, same data and the same software, as for a normal (serial) analysis, just providing some additional switches, requesting the task to be executed in parallel. The approach promises additional advantage over Approach 1 running large iDaaaS machine, as the iDaaaS cluster nodes would have independent access to the parallel file system so may provide better IO speeds.

## Resources and development necessary to satisfy excitation group requests:

Summarizing the above information, we need access to specialized hardware with controlling software and need to adapt our software and development practices to this hardware. Different groups of the hardware users perform different tasks, so different hardware, controlling software, software configurations and access rights are necessary for different tasks. We have identified the following groups of users, requesting different things:
1. Users performing the initial analysis of the results of experiment
2. Users performing advanced analysis and simulation
3. Developers, testing serial software using iDaaaS services.
4. Developers, testing parallel software using iDaaaS services.
5. Automation software (Jenkins) running automating tests for software.

In details:
 * 1) **Group one** requests are satisfied by current iDaaaS service, though the performance of the initial Horace analysis task (sqw file generation) is slightly lower.
 * 2) Users of **group 2** need more computational resources and preferably access to parallel iDaaaS cluster.
  namely:
Number of iDaaaS nodes (the configuration similar to Excitation small machine configuration is a good candidate for a node configuration), should be connected into virtual cluster, available for users to submit jobs. 16, 32 and 64 nodes per cluster would satisfy different user's requests. Different ways of connecting the nodes into cluster and submitting jobs to this cluster are available. iDaaaS team suggests that [Slurm job management system](https://slurm.schedmd.com/overview.html) can be deployed to connect iDaaaS nodes into cluster and control the jobs running on this cluster.

    **iDaaaS team** needs to develop and provide excitation group with such cluster.
    **PACE team** according to the [PACE project](https://github.com/pace-neutrons) plan have developed the [parallel framework](https://github.com/pace-neutrons/Horace/blob/master/documentation/add/04_mpi_framework.md) to support Horace parallel job execution. The job submission mechanism for the framework has common interface described and implemented within the *ClusterWrapper* class (see the details in the [Cluster Management](https://github.com/pace-neutrons/Horace/blob/master/documentation/add/04_mpi_framework.md) chapter of the [parallel framework](https://github.com/pace-neutrons/Horace/blob/master/documentation/add/04_mpi_framework.md) documentation). The appropriate *SlurmClusterWrapper* class to work with Slurm job management system has to be written to utilize the parallel cluster. In addition to that, the Horace will be extended with more parallel extensions to perform more of its tasks in parallel.

   To provide users of **group 2** with more adequate computational resources, it may be desirable to organize access to a large virtual machines, emulating ISISCOMPUTE machines, until parallel cluster is working and Horace adaptation to the parallel cluster is completed. Such machines are currently exist at [test iDaaaS ISIS machines](https://isis-test.analysis.stfc.ac.uk/#/my-machines/ISIS) under *Alex Development machine*  The machines can be shared with users. The conditions of sharing such machine with other users is not fully defined.

 * 3) **Group 3** are the developers, currently organized into [PACE project team](https://github.com/pace-neutrons). The developers need to be able to test and modify software, compile it, install and test different compiles i.e. have administrative access to an iDaaaS machine. It is not necessary for this machine to be connected to parallel file system.
  **iDaaaS team** have provides PACE team with access to the [test iDaaaS machines](https://isis-test.analysis.stfc.ac.uk/) (Works under vpn).
  Does every developer from **PACE team** have access to such machines?

 * 4) **PACE team** need to test software and parallel software on the machines, similar to the user machines. This access is currently provided under standard [iDaaaS service](https://isis.analysis.stfc.ac.uk/#/login). Access to a Slurm controlled cluster is necessary to develop the appropriate cluster wrapper (see above)
   **iDaaaS team** should provide PACE development team with access to a small parallel cluster under Slurm control (4 nodes are sufficient for development), for the PACE team to be able to develop *SlurmClusterWrapper*.
   Alternative to the Slurm job management may be a system based on custom control over iDaaaS virtual machines, constructed using API, described in the Appendix 1 below. Though such cluster will work, and probably be useful, development in this direction is highly undesirable, as a standard cluster management system takes a lot of efforts to develop and provides wide possibilities for control and management. Custom implementation of such system exclusively for purposes of PACE project will be expensive, inconvenient and unreliable. 

 * 5) [Anvil Jenkins automation service](https://anvil.softeng-support.ac.uk/) is currently used by **PACE team** to support continuous integration and continuous delivery. Unix test are currently run on Anvil-provided Linux test nodes under assumption that these nodes are the same as iDaaaS nodes, provided to users. This assumption is not entirely correct. In addition to that, performance tests (currently not implemented), should be run on the same machines as provided to users.
    **iDaaaS team** have provided set of API (see **Appendix 1**) sufficient to lunch iDaaaS machines from a script and deploy Jenkins pipeline run on iDaaaS.
    **PACE team** should use this API to enable running Jenkins pipelines on *iDaaaS*

    While Anvil service provides sufficient access to Linux test machines, the testing software on other supported OS is difficult as no service similar to Anvil or iDaaaS is available for other OS. **PACE Team** needs to run Jenkins test nodes on personal machines. This approach suffers from lack of computational power and poor reliability.
    A service to provide reasonable number of virtual Windows and Mac hosts in a way, similar to Anvil or iDaaaS providing for Linux would be very beneficial.


## Appendix 1. API to run iDaaaS machines from command line
Courtesy of [Fraser Barnsley](mailto:frazer.barnsley@stfc.ac.uk)

The API uses python. Necessary packages should be installed by invoking:
```
yum install python3 python3-pip
pip3 install requests
```

The sample script to start/pause/control/stop an iDaaaS virtual machine is:
```python
import sys
import json
import requests

ICAT_URL = "https://icatisis.esc.rl.ac.uk"
DAAAS_URL = "https://isis-test.analysis.stfc.ac.uk/topcat_daaas_plugin/api/user/machines"

USER_OFFICE_EMAIL = "my@email.com"
USER_OFFICE_PASSWORD = "password"



# Login to the frontend
payload = 'json={"plugin":"uows","credentials":[{"username":"%s"}, {"password":"%s"}]}' % (USER_OFFICE_EMAIL, USER_OFFICE_PASSWORD)
headers = {"Content-Type": "application/x-www-form-urlencoded"}
response = requests.post(ICAT_URL + '/icat/session', params=payload, headers=headers)

if response.status_code != 200:
  print("Bad login: " + response.text)
  sys.exit(1)

sessionid = json.loads(response.text)["sessionId"]
print("Session ID: " + sessionid)



# Create machine
payload = {
  'icatUrl': ICAT_URL,
  'sessionId': sessionid,
  'machineTypeId': 22
}
headers = {"Content-Type": "application/x-www-form-urlencoded"}
response = requests.post(DAAAS_URL, data=payload, headers=headers)

if response.status_code != 200:
  print("Bad create: " + response.text)
  sys.exit(1)

# Example response
#{
#  "id":"30191",
#  "name":"Preprod Excitations [8 CPU / 32GB RAM]",
#  "host":"host-172-16-113-216.nubes.stfc.ac.uk",
#  "screenshotMd5":"uhMv0dJd4xZ48+5crDZSDQ==",
#  "createdAt":"2020-06-26T17:48:28.774+01:00",
#  "users":[]
#}

machineinfo = json.loads(response.text)
print("ID: " + machineinfo["id"])
print("Hostname: " + machineinfo["host"])



# I stop execution here so it does not instantly delete the machine you created
sys.exit(0)



# Delete machine
MACHINE_ID = machineinfo["id"]

payload = {
  'icatUrl': ICAT_URL,
  'sessionId': sessionid,
}
headers = {"Content-Type": "application/x-www-form-urlencoded"}
response = requests.delete(DAAAS_URL + '/' + MACHINE_ID, params=payload, headers=headers)

if response.status_code != 200:
  print("Bad delete: " + response.text)
  sys.exit(1)

print("Machine deleted")
print(response.text)

```