###
FAQ
###

Some frequently asked questions about Horace


Can I include more than one data file (spe/nxspe) with the same experimental configuration in an sqw file?
----------------------------------------------------------------------------------------------------------

Yes! The ``gen_sqw`` routine will check for repeat entries of filenames, so that you cannot accidentally include the same run twice. But you can have the same experimental conditions (Ei and psi) for different runs and include them. For example, suppose you had the same values of psi and Ei for file1 and fileN-1, and file2 and fileN, in the example below:

::

   my_files={'file1','file2','file3',...,'fileN-1','fileN};
   ...
   psi=[1,2,3,....,1,2]
   ...

   gen_sqw(...,my_files,...psi,...)


In the resultant sqw file the data from file1 and fileN-1, and file2 and fileN, will be combined and normalised correctly.


The difference between sqw and dnd objects
------------------------------------------

The technical differences between dnd and sqw objects are dealt with in :ref:`Advanced use <Advanced_use:Creating an object from scratch>`. Both data objects contain the same arrays of signals, variances, plot and integration axis coordinates etc., but the sqw object contains an additional array which provides detailed information about every detector-energy pixel from every run which contributed to the signal in the object. It also contains more information about the original contributing NXSPE files and in particular allows for instrument information to be stored that enables resolution convolution to be performed.


Memory requirements
===================

Equivalent sqw and dnd objects require vastly different amounts of computer memory. The dnd object is usually relatively small (typical 0.1-10MB), whereas an sqw object can easily be >1GB. This is because in the sqw object, nine numbers (see :ref:`Advanced use <Advanced_use:Creating an object from scratch>` for details) are retained about each detector-energy pixel element that contributed to the observed signal. In a normal Horace experiment this often equates to many millions of detector elements, hence the large memory requirement to store all this information. SQW files that are created from experiments can exceed 1TB if read into memory: don't try to do that unless you are very sure about the size of the file and the memory on your computer!

Implications for simulations and fitting
========================================

The difference between sqw and dnd objects is clearly manifest, and potentially most significant, when simulating and/or fitting a S(Q,w) model to the data.

Consider the case of a 2-dimensional slice by way of an example, where the plot axes are (h,0,0) and (0,k,0), and we integrate energy between 10meV and 20meV and integrate (0,0,l) between -0.5 and 0.5. Suppose this material is 3-dimensional, so that there are excitations that disperse along all 3 of the Q directions. We simulate a model S(Q,w) which includes this 3-dimensional dispersion, but find that the simulations look totally different if we simulate equivalent dnd and sqw data objects. What is going on?

For the sqw object, the S(Q,w) model is calculated at the (h,k,l,e) co-ordinates of every single contributing detector pixel (of which there are potentially many millions), and then combined in the same way that the data are to produce a 2-dimensional colour map. Because we integrated over quite a wide range of (0,0,l) and energy, detector elements with similar (h,k) co-ordinates of can have totally different (0,0,l) and energy co-ordinates, and hence totally different S(Q,w). When we sum these elements together we get something that should (assuming the model is good) look very similar to the data.

For the dnd object, we do not have the the (0,0,l) and energy co-ordinates of the contributing detector elements any more. So for each (h,k) bin we only have the average value of (0,0,l) and energy - in this case l=0 and e=15meV respectively. The S(Q,w) model is thus only evaluated at these single points in (0,0,l) and energy, and the full dispersion is thus not captured, and the simulated intensity is likely to be wrong.

A caveat to this is the case where the S(Q,w) model does not give a 3-dimensional dispersion, e.g. S(Q,w) is independent of (0,0,l). In this case the dnd and sqw object simulations will be the same.

I've got a problem and I can't find figure out how to solve it from the information on this website!
----------------------------------------------------------------------------------------------------

First, double check that the information really isn't hidden away on the website somewhere by using the **search** tool located on the left-hand side of all the pages on this website. In the case that you have found the function that you need but it is crashing even though you have checked that you are using it correctly, make sure you have the latest version of Horace installed.

If that fails, or the information on the site doesn't answer your question, email us at `Horace Help <mailto:HoraceHelp@stfc.ac.uk>`__. We will be happy to help you.
