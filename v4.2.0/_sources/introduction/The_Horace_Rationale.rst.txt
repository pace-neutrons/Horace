####################
The Horace Rationale
####################

Horace is a suite of programs for the visualisation and analysis of large datasets from time-of-flight neutron inelastic scattering spectrometers. The feature of Horace that is new compared to existing software, such as MSlice, is that it allows you to combine data from multiple runs (each with different incident energy and/or sample orientation) and thus build up a 4-dimensional dataset that, in principle, covers Q and energy in all directions.

To understand why this is not possible with a single run, consider the diagram shown below.

.. image:: ../images/ToF_QE_coupling.jpg
   :width: 300px
   :alt: This is a caption

For a single incident energy and crystal orientation it is clear that one of the components of **Q**, that parallel to the scattered beam (**Q2**), is coupled to time-of-flight rather than detector position. This means that this component of **Q** is coupled to neutron energy transfer. Put simply, the effect of this is that a linear "scan" in **Q** actually follows a curved path in either energy or **Q2**. Clearly this can be avoided by taking measurements with a different orientation of the sample with respect to the incident beam, since for different orientations the coupling between **Q** and energy will be different. By making measurements at lots of different sample orientations, **Q** and energy can be completely decoupled.

Horace is a set of programs that can be used to build, visualise and analyse such a dateset. ToF_QE_coupling.
