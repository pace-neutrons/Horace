###
FAQ
###

.. |SQW| replace:: :math:`S(\mathbf{Q}, \omega)`

Some frequently asked questions about Horace


Can I include more than one data file (spe/nxspe) with the same experimental configuration in an sqw file?
----------------------------------------------------------------------------------------------------------

Yes! The ``gen_sqw`` routine will check for repeat entries of filenames, so that
you cannot accidentally include the same run twice. But you can have the same
experimental conditions (:math:`E_i` and :math:`\psi`) for different runs and
include them. For example, suppose you had the same values of :math:`\psi` and
:math:`E_i` for ``file1`` and ``fileN-1``, and ``file2`` and ``fileN``, in the
example below:

::

   my_files={'file1','file2','file3',..,'fileN-1','fileN};
   ...
   psi=[1,2,3,..,1,2]
   ...

   gen_sqw(..,my_files,..psi,..)


In the resulting ``.sqw`` file the data from ``file1`` and ``fileN-1``, and
``file2`` and ``fileN``, will be combined and normalised correctly.


What is the difference between sqw and dnd objects
--------------------------------------------------

Summary
=======

The ``sqw`` object carries around an array containing the information of each
detector-energy pixel which underlies the result in a raw form. These pixels are
then accumulated and binned into the intensity histogram which makes up the
``dnd``. ``sqw`` s also carry around details about the contributing ``.nxspe``
files from which it was made and, in particular, allows for instrunment
information to be attached enabling resolution-convolution to be performed.

.. note::

   All ``sqw`` objects have a ``dnd`` in their ``data`` property.

The ``dnd`` should be thought of as the resulting image from the accumulation of
pixels in an ``sqw`` object. It carries around a projection (which orients the
display [plotting] region in reciprocal space) and a set of axes which define a
plotting region and the histogram bins into which the pixels are accumulated.

Should a ``dnd`` be separated from an ``sqw`` (e.g. by using the ``-nopix``
option on a :ref:`cut
<manual/Manipulating_and_extracting_data_from_SQW_files_and_objects:cut>` or by
extracting the ``data`` property from an ``sqw`` directly) certain operations
are no longer possible or act differently because the ``dnd`` no longer has the
underlying pixel data. This means that only operation which can act on the
intensity histogram are possible.

.. note::

   The technical differences between ``dnd`` and ``sqw`` objects is covered in
   more detail in :ref:`Advanced use <user_guide/Advanced_use:Creating an object
   from scratch>`.

Memory requirements
===================

Equivalent ``sqw`` and ``dnd`` objects require vastly different amounts of
computer memory. The ``dnd`` object is usually relatively small (typically
0.1-10MB), whereas an ``sqw`` object can easily be multiple GB. This is because
of the returntion of each detector-energy pixel element that contributed to the
observed signal. In a normal Horace experiment this often equates to many
millions of detector elements, hence the large memory requirement to store all
this information.

.. warning::

   ``.sqw`` files that are created from experiments can easily exceed 1TB and
   may take a long time to process!

Implications for simulations and fitting
========================================

The difference between ``sqw`` and ``dnd`` objects is clearly manifest, and
potentially most significant, when simulating and/or fitting a |SQW| model to
the data.

Consider the case of a 2-dimensional slice created by:

.. code-block::

   proj = line_proj([1 0 0], [0 1 0]);
   w = cut(file, proj, [], [], [-0.5 0.5], [10 20]);

where the plot axes are :math:`(h,0,0)` and :math:`(0,k,0)`, and we integrate
energy between 10meV and 20meV and integrate (0,0,l) between -0.5 and 0.5.

Suppose this material is 3-dimensional, so that there are excitations that
disperse along all 3 of the **Q** directions. We simulate a model |SQW| which
includes this 3-dimensional dispersion, but find that the simulations look
totally different if we simulate equivalent ``dnd`` and ``sqw`` data
objects. What is going on?

For the ``sqw`` object, the |SQW| model is calculated at the :math:`(h,k,l,e)`
co-ordinates of every single contributing detector pixel (of which there are
potentially many millions), and then combined in the same way that the data are
to produce a 2-dimensional colour map. Because we integrated over quite a wide
range of :math:`(0,0,l)` and energy, detector elements with similar
:math:`(h,k)` co-ordinates of can have totally different :math:`(0,0,l)` and
energy co-ordinates, and hence totally different |SQW|. When we sum these
elements together we get something that should (assuming the model is good) look
very similar to the data.

For the ``dnd`` object, we do not have the the :math:`(0,0,l)` and energy
co-ordinates of the contributing detector elements any more. So for each
:math:`(h,k)` bin we only have the average value of :math:`(0,0,l)` and energy -
in this case ``l=0`` and ``e=15meV`` respectively. The |SQW| model is thus only
evaluated at these single points in :math:`(0,0,l)` and energy. As a result, the
full dispersion is not captured and the simulated intensity is likely to be
wrong.

A caveat to this is the case where the |SQW| model does not give a 3-dimensional
dispersion, e.g. |SQW| is independent of :math:`(0,0,l)`. In this case the
``dnd`` and ``sqw`` object simulations will be the same.

I've got a problem and I can't find figure out how to solve it from the information on this website!
----------------------------------------------------------------------------------------------------

First, try using the **Search docs** on the left-hand side of all the pages on
this website. In the case that you have found the function you need and it is
failing, make sure you are looking at the docs for the :ref:`correct version
<Previous_versions:Previous Versions>` of Horace.

If that fails, or the information on the site doesn't answer your question,
email us at `Horace Help <mailto:HoraceHelp@stfc.ac.uk>`__. We will be happy to
help you.
