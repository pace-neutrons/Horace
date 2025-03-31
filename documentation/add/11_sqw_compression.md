# SQW file compression 
Date: 2025-03-27



## The problem to solve and objectives

The major bottleneck when performing operations with the main experimental data sqw file on IDAaaS is the time it takes to read data from the disk. These files are typically c. 100GB – 200GB, and on occasion been as large as 500GB. The problem is most noticeable when making cuts from the data, as users wish to make cuts interactively as part of exploring data, and the fastest response is highly desirable. In particular, there have been  number of complaints from users and instrumnet scientists about how slow Horace 4 is to make cuts on IDAaaS, where the data is held on a shared file store. Tests by Alex Buts suggest that cuts can take 5 - 7 times longer than on a high-specification laptop with local storage, which indicates the time to make a cut on IDAaaS is dominated is the sheer volume of data that needs to be read. Given that we must work with the hardware that IDAaaS provides, the natural solution is to compress the volume of data.

The problem is not unique to cuts. Any operation that requires access to data in the sqw file will suffer from limited I/O speeds. However, cuts are the most demanding case, not just because the wall-clock time is most apparent to users, but because in general a cut needs to read only a small fraction of the data in an sqw file but that data will be distributed in many chunks around the whole of the file. This has technical implications relating to size of chunks of data the disk operating software reads and caches, as well as local caching of data on whichever node the user's virtual machine is running.

The best user experience of Horace is paramount. The goals are therefore to satisfy the following requirements:
- Cuts on a computer with local (high-speed) disk storage should be no slower than they are with the present sqw file format.
- Cuts on IDAaaS should ideally be as fast as, but no more than a factor 2 slower than, the above.



## Background

The 'master' sqw files created from experiments are typically c. 100GB to 500GB. The data is sorted into bins – 50 along each of the four axes (the three of wavevector, and energy transfer) – so that the data for all pixels within a given bin form a contiguous block. However, for a given bin, the pixels could be in any order. This coarse-grained sorting allows that when a cut is made, the bins that partially or wholly lie within the bounding surfaces of the cut can be computed, and then only the contents of those bins are read. This minimises the volume of data that needs to be read from the sqw file.

The disk space of a 4D sqw file generated in an experiment is overwhelmingly dominated by the pixel data. Defining:
- `nrun` = number of runs
- `ndet` = number of detectors in each run
- `ne` = number of energy bins for each detector

then the total number of pixels will be `N = (nrun * ndet * ne)`. Typically `nrun = 100 – 500`, `ndet = 40,000 – 100,000`, `ne = 200` which results in `N = 10^9` – `10^10` pixels.

Note that each run that contributes to an sqw file could have different detector data, a different incident energy (the fixed energy for that run) and a different number of energy bins. The calculation above of the number of pixels is nevertheless representative, because in practice the differences between detector data from run to run will be because there was a recalibration of the detectors or loss of a limited number of detectors halfway through the set of runs, for example, but ndet will likely be similar. The number of energy bins might vary from run to run, but will always be similar because they will be likely about the same fraction of the corresponding fixed energy. In the case of Mushroom, the fixed energy is in fact the final neutron energy, and is different for each detector element.

For each pixel, the following 9 pieces of information are stored, as a column in an array size [9,N]:
- `qx`, `qy`, `qz`,`irun`, `idet`, `ien`, `en`, `signal`, `error`

where for that particular pixel:
- `irun`: index of the run
- `idet`: index of into the detector array corresponding to that run
- `ien`: index into the list of the energy bin boundaries for that run
- `qx, qy, qz, en`: coordinates of wavevector q in the orthonormal frame that is the crystal Cartesian frame (actually, in an orthonormal coordinate frame rotated with respect to that frame if the crystal has been realigned)
- `signal`: intensity of data
- `error`: variance on the signal

The array is presently stored as a float32 array i.e. 4 bytes per element. Thus, storing the data for each pixel requires 36 bytes.



## The proposed compression scheme


### The principles of the scheme

The proposed compression scheme exploits the following two facts:
- `qx, qy, qz, en` are completely determined by {`irun, idet, ien`}, because those indices point to the experiment information that enables the value of the fixed energy, the detector element location, the energy bin (and hence energy transfer) and crystal orientation and lattice parameters that enable `qx, qy, qz, en` to be calculated.
- In most single crystal experiments, the fraction of pixels that contain non-zero signal is very small. For example:
	- Iron data: runs 15057 and 15097 (800 meV incident energy data): 0.13
	- RbMnO3: a selection of runs: 0.010 – 0.012

Accordingly, so long as we keep track of which pixels contain non-zero signal, we only need to keep the following information: 
-	`irun, idet, ien`: for all pixels			
-	`signal, error`: only for pixels with non-zero signal

The trade-off is between
- the overhead of recomputing `qx,qy,qz,en` on-the-fly when reading data, and 
- the reduced I/O time and the ability to cache entire sqw data on an IDAaaS node (as will be the case of a 200GB sqw file becoming a 50GB file – see explanation for the fourfold reduction in size in a later section).

Preliminary testing by Jacob Wilkins *(results to be collated and confirmed as part of the benchmarking for this epic)* suggest a clear win for the compressed format, notwithstanding the capability gain from caching the entire sqw object.



### First look at gains

Keeping only the unique information as described above results in the average storage per pixel (assuming float32 for all data) reducing from 36 bytes to (12 + 8f) bytes, where f is the fraction of pixels with non-zero signal (f = 0.01 and 0.13 in the two examples quoted above). The mean storage requirement is therefore reduced to:

**Table 1**

| Fraction of non-zero signal | Bytes per pixel | Percentage of current format
|-----------------------------|-----------------|-----------------------------
|  f = 0  (best case) |  12    | 33%
|  f = 0.011 (RbMnO3) |  12.09 | 34%
|  f = 0.13 (Fe)      |  13.04 | 36%
|  f = 0.25           |  14    | 39%
|  f = 1 (worst case) |  20    | 56%
		
For small values of f, the storage is dominated by the space needed to hold {`irun, idet, ien`} for every pixel. For typical data, the storage requirement is reduced to about 1/3 that of the present `sqw` files. 



### The proposed scheme and the achievable compression

To improve on the above, special knowledge of the maximum values of the indices, namely {`nrun, ndet, ne`} can be used to reduce the space to hold {`irun, idet, ien`} for every pixel. With the typical values `nrun = 500`, `ndet_max = 70,000`, `ne_max = 300` then `N_max = 1.05e10`. If {`irun, idet, ien`}  is converted into a linear index using the knowledge of `nrun, ndet_max, ne_max`, then the pixel indexing information can easily be held in a `float64` (maximum integer `2^53 = 9e15`) i.e. 8 bytes.

In practice, 
-	With any feasible values for {`nrun, ndet_max, ne_max`} in the lifetime of ISIS and other facilities, 8 bytes is all that is needed (see additional notes below for details).
-	Because the overall storage requirement in practice is dominated by {`irun,idet,ien`}, we could store the signal and error as `float64` with little penalty in disk space compared to storing as `float32`: only for f>0.21 does the penalty exceed 15%. The advantage is that the representation in memory and on disk are identical, with little penalty in overall storage in bytes. The following gives the storage needs for the two cases (and percentage size compared to the current sqw format):

**Table 2**

| Fraction of non-zero signal | Bytes per pixel float32 signal | Percentage of current format | Bytes per pixel float64 signal | Percentage of current format
|-----------------------------|-----------------|-----------------------------
|  f = 0  (best case) |  8     | 22% |  8     | 22%
|  f = 0.011 (RbMnO3) |  8.09  | 22% |  8.18  | 23%
|  f = 0.13 (Fe)      |  9.04  | 25% |  10.08 | 28%
|  f = 0.25           |  10    | 28% |  12    | 33%
|  f = 0.5            |  12    | 33% |  16    | 44%
|  f = 1 (worst case) |  16    | 44% |  24    | 67%
	
*Note: float32 signal and error: (8 + 8f) bytes per pixel; float64 signal and error: (8 + 16f) bytes per pixel*	



## Conclusion:
- With linear indexing of pixels in a `float64` and storing non-zero data only, the disk space required to hold an sqw object is in practice reduced to approximately 1/4 the present sqw file size.
- Storing `float64` signal and error only results in about a 10% increase in file size compared to `float32` for typical datasets.
- With current hardware, entire sqw files can be cached on a single node in IDAaaS. See benchmarking by Alex for the speed advantage this gives.
- The data access API to sqw files should hide any knowledge of the compression methodology, to eliminate any need to alter any of the code in the rest of Horace. This means it will be necessary to compute `qx, qy, qz, en` on-the-fly when reading data from a compressed sqw file. (Typically, in a Horace method, this is done a chunk of data at a time, with many chunks to be read from disk to perform the whole Horace operation.)
- Careful optimisation will need to be done to make this on-the-fly computation efficient.



## Appendix: additional notes

### Benchmarking that needs to be done in the analysis phase of the epic

- Check the ratio of empty to non-empty bins for a wider range of `nxspe` files on LET, MERLIN and MAPS. This will give a more robust distribution of the fraction of non-zero signal. If there are a significant proportion of experiment with f > ~ 0.4 it will be preferable to hold non-zero signal and error as float32 rather than float64.

- Benchmarking and profiling of the time to make cuts
	- Generate some  ‘real-world’ sized sqw files that can be used for benchmarking, varying the:
		- size of sqw files
		- single and multiple detector files and instrument components (to exercise the overheads of accessing via unique object stores)
		- direct and inverse geometry instruments (i.e. Mushroom)
		- Need to be able to generate these dummy data on demand using development versions of the compressed format to test timing improvements during development.
	- ‘real-world’ cuts from ‘real-world’ sqw files
		- Benchmarking and profiling on IDAaaS and local machines
		- Lots of small cuts 
		- Large cuts

Alex and Jacob have done some of benchmarking and profiling: Alex on total timings on IDAaaS and local machines, Jacob some testing of times for I/O .v. on-the-fly computation of qx,qy,qz,en using calculate_qw_pixels2.m. What is needed is definitive, documented, and reproducible test examples. 

Profiling is important because past experience with accessing unique object storage, and of accessing detector and run information in Tobyfit, has shown that without careful optimisation these operations can become very time-consuming.


### Why store the signal and variance as float64?
The contents on disk and in memory will then be identical. A problem we have had is comparing data when debugging because pixels close to the edge of a bin can move from one bin to another, as well as the obvious 7 sig. fig. rounding that takes place on double to single conversion.

The problem of pixel-to-bin mapping should disappear with on-the-fly computation of `qx,qy,qz,en`, as this will be done in memory from the run-detector-energy bin indices. That leaves just the question of the signal and error. Rounding to 7 sig fig may not be important. This should be considered further; particularly if the fraction of non-zero signal pixels is large for a significant proportion of experiments, then saving signal and error as float64 might result in a significant penalty (see Table 2). This will certainly be the case when simulating data with a model, when typically *all* pixels will have non-zero simulated signal. In this case the compressed format file will be 50% larger with float64 signal compared to float32 (and 2/3 the size of the current sqw file compared to 44% for float32).


### The meaning of ‘non-zero signal’
By non-zero signal we actually mean zero signal and zero error: nothing was counted. This is distinct from the case of a background subtraction that has been performed in the data reduction such that there is zero signal and non-zero error. 


### Values of nrun, ndet_max, ne_max
In practice, we won’t always know the values of nrun, ndet_max, ne_max in advance of construction of an sqw file, for example, if the sqw file is built up during an experiment by accumulating the data of newly arrived nxspe files as they appear. In practice, however, we can use default values that will be larger than any feasible experiment in the lifetime of ISIS or other facilities:

|          | Estimate of maximum value | Value | Comment
|-----------------------------|-----------------|-----------------------------
| nrun     | 0.025 degree steps over 360 degrees (full rotation) | 1.44e4 |  x30 most ever done!
| ndet_max | CSPEC at ESS if it gets the multigrid detectors | 1e6 | Very unlikely to get them!
| ne_max   | Somebody once had 800 to my knowledge  | 1e3 | x20 finer than resolution

Result: N_max = 3.6e11

The largest integer that can be stored exactly in a float64 is 2^53 = 9e15. We still have two orders of magnitude in hand, so we can choose the defaults:
- nrun_max = 9e4
- ndet_max = 1e7
- ne_max = 1e5

We can always hold [nrun_max, ndet_max, ne_max] in the sqw file itself, so that they can in principle set to any values beforehand (so long as their product is less than 9e15).

Why limit the total number of pixels to 9e15? This product of nrun_max, ndet_max and ne_max gives the maximum number of pixels that Horace can handle. In practice it is more than any reasonable amount of computing resource can handle. It is in any case an implicit limit throughout the existing Horace code wherever there are loops over the number of pixels.


### Thoughts on format on disk for the compressed sqw object
The current sqw file has two important arrays that locate pixels and bins in the file:
-	npix  	A multi-dimensional array with the number of pixels in each bin
-	pix 	A 9 x N array with the data for each pixel

npix enables the locations on disk of the start and end within pix to be computed for any block of data corresponding to one or more contiguous bins. Operations in Horace are typically done in chunks at a time. To minimise calls to disk when making a cut, the indices of bins that potentially could contribute pixels to the cuts are computed before any pixel data is read. The start and end of the data corresponding to contiguous ranges of bins are then computed.

The pixel information held in the file needs to be modified for the proposed compression method:
- We need to keep two lists of pixel data e.g.
	- pix_nonzero == [irun,idet,ien,signal,error] for those pixels with a signal
	- pix_zero == [irun,idet,ien] for those without signal. 
- We also need to keep track of how many pixels have zero counts in each bin, in addition to the total number of pixels in each bin e.g.
	- npix_nonzero (array of the number of pixels in each bin with a signal)
	- npix_zero (array of the number of pixels in each bin with no signal)  
	
The two arrays npix_nonzero and npix_zero will need to be stored in the header portion of the file, alongside experiment information etc., just like npix in the current format sqw file.

The most straightforward implementation would store pix_nonzero in its entirety in one contiguous stream (i.e. for all bins), followed by the whole of npix_zero. However, for each contiguous block of data that needs be read from pix in the current (uncompressed) implementation when making a cut, there would need to be two separate blocks of data read in the compressed implementation – one from pix_nonzero and one from pix_zero – with the associated access latency as the different locations are read.

Alternatively, we could store the pixel information as 

 	pix_nonzero for bin 1
	pix_zero for bin1
	pix_nonzero for bin 2
	pix_zero for bin 2
		:
	
That way, all data for a given bin is in a single contiguous block, just as at present.

Considerations of how data is physically stored needs to be part of the analysis phase of this epic. The above discussion is relevant if we have a file format with direct access to reading between start and end locations on disk (as we do with the present sqw file format). It may be irrelevant if we use the hdf format – but we need to be mindful of the speed of access however the data is stored.
