##Filebased sqw-pixels operations state and forthcoming tasks. ##

10/02/2022

We currently have two independent implementations of filebased sqw-object pixel operations in Horace code base, covering different areas of the Horace code. The implementations covers different areas of operations, implement different approaches to the problem of processing large amount of pixels not fitting memory and is in different state of maturity and reliability. 
Supporting two independent approaches is not sustainable in a long run, so the task of reconciling and merging these approaches is forthcoming. 

### 1. Filebased PixelData approach ###

The approach, developed by Tessela is based on the idea, that ***PixelData*** class, wrapping pixels information, represents filebased class, which would transparently provide user with interface to access the data if the data do not fit the memory. In fact, the data provision is not so transparent as the loop over pixel pages needs to be organized to obtain a comprehensive data. Current implementation of PixelData class supports this approach, providing user with iterators to organize loops over filebased data. 
The chunk of data, accessed and processed by the algorithm is defined by global configuration. 
The algorithms, which currently can work using this approach, are unary and binary operations over filebased sqw-object’s pixel data and (not sure?) sqw_eval operations with user function

The problems with the approach:

1)	The performance drop occurring at transition from memory based to filebased operations is so steep that it can not be performed unnoticeable to users, except when applied to small datasets which fit memory anyway.
2)	It is unclear how to request result of operation to be memory based or filebased (its always filebased if the data requested exceed the page size selected)
3)	Its unclear how to parallelize this algorithm without informing user about the parallelization. No clear interface or approach is developed for user to request parallelization.
4)	Current access to a pixel information is explicitly based on paging over the whole pixels arrays. The approach gives no way to request partial extraction of pixel data (e.g. for cuts).
5)	The modified pages, which should eventually add up to the whole sqw-file size, are merged back into sqw file using internal and very slow algorithm. There are currently no way of optimizing and parallelizing this operation. 
6)	There are also minor issue with the handle class, associated with the file, which request use copy operation to do any modifications to sqw pixel data. The copy operation is performed in memory only and undefined for filebased classes. 

To provide reasonable performance of existing Horace algorithms, working with PixelData class, current page size for the PixelData is set equal to the whole computer memory, which disables all filebased operations on pixels. To perform filebased operations one needs explicitly change the page size before the operation, which is currently done in tests only. Some recent bugs ([#771](https://github.com/pace-neutrons/Horace/issues/771)) are related to the fact that the paging is currently disabled in the production code.

### 2. Filebased data accessor algorithms ###

Second approach to dealing with filebased data was in Horace from the days of its creation. The user select if he wants filebased/memory_based data and filebased/memory based result. Recently added options allow user to request parallelization. Current algorithms, which use this approach are ***gen_sqw*** and ***cut(sqw)*** The algorithms dealing with filebased data are well investigated, optimized and understood.  The attempt to reconcile these algorithms with algorithms, deployed under approach 1, attempted by Tessella have failed.

The problem with this approach:

1)	The interfaces to the filebased data are not well defined and buried inside the *faccess* family of classes. 
2)	The algorithms are not properly unit tested.
3)	No clear public interface to access the algorithms, so no definitions and no single united implementation.

The job of reconciling both approaches to provide single, well-tested and efficient version of the code is due.

As one can see, the problems with approach 1 are partially fundamental, as we will not have time and resources to write a system, which allows a user switch seamlessly between memory based/file based and serial/parallel operations without noticing the change of the operational mode. We can though, write a system, which provide the same interface to these operations and allow user to request operations, appropriate to his/her purposes. The problem with the approach 2 are rather related to luck of development efforts to advance it.

### Suggested way forward ###

The suggested way forward would be:
1.	Remove filebased implementation from existing PixelData interface
2.	Define and implement much simple but well tested interface to the filebased data, allowing to provide access to pixels on disk and loading PixelData in memory and write memory based/file based/parallel  (on request) algorithms accessing this interface for filebased or memory based operations.
3.	Re-implement filebased parts of the approach 1 using these interfaces.
4.	Document and unit test this interface.



