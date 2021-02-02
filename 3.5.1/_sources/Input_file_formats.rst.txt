##################
Input file formats
##################

To generate the SQW file from which Horace reads S(**Q**,w), neutron scattering data for each individual run and needs to be provided in one of two formats: the legacy ASCII format SPE file, together with an ASCII detector parameter file (the PAR file), or their replacements the HDF5 (Hierarchical Data Format) NXSPE file. Two functions are available as part of Horace to create SQW files from these input files, namely :ref:``gen_sqw`` (creates a new SQW file) and ``accumulate_sqw`` (accumulates data to an existing SQW file). The functions to generate SQW files are described in detail `here <Generating_SQW_files:Generating SQW files>`.

Generally, the input data files (SPE or NXSPE format) will be created by the data reduction code for the instrument which you are using if Horace has been made available for that instrument by the scientist(s) responsible. However, if you want to use Horace to analyse data from other instruments you need to know how to create the input files from whatever format your data is saved in.

NXSPE file
==========

The recommended input data file for Horace is the NXSPE file, which holds both the S(w) data and errors for each detector, detector position and size information, together with the crystal orientation angle\ ``psi`` and the incident neutron energy Ei. The NXSPE file stores the information in a NeXus format file, which is a common data exchange format for neutron, X-ray and muon data that is built on top of the HDF5 (Hierarchical Data Format) scientific data format.

Data files in the NXSPE format are produced by the Mantid data analysis software (http://www.mantidproject.org/). They are directly produced by the data reduction algorithms within Mantid for the direct geometry spectrometers at both the ISIS spallation neutron source at the Rutherford Appleton Laboratory in the UK and the SNS spallation neutron source at Oak Ridge National Laboratory in the USA. Mantid is an open source data manipulation and analysis framework for neutron and muon data analysis. If Mantid is used to perform the data corrections for a neutron spectrometer, then the Mantid algorithm ``SaveNXSPE`` can be used to output NXSPE files. Full details of how to use Mantid and the input/output for each algorithm are available at the [http://www.mantidproject.org/\ \| Mantid web site].

More suitable for a 'quick start', is if you can read corrected scattering data, associated estimated errors, and detector parameters into Matlab arrays. You can then use the Horace utility function ``gen_nxspe`` to create NXSPE files.

gen_nxspe
*********

This is a flexible to repackage and/or save S(**Q**,w) and detector to file. To write a single NXSPE file the syntax is as follows:

::

   gen_nxspe(S,ERR,en,par,nxspefile_name,efix,emode,psi)


The input parameters are defined as follows:

``S``: Array of signal strength size [ne,nd] where ne is the number of energy bins and nd is the number of detector elements.

``ERR``: Array of estimated standard errors with size [ne,nd].

``en``: Array of energy bin boundaries. The number of elements is therefore (ne+1).

``par``: Array of detector parameters with size [6,nd]. Each column of the array contains information for a detector element:

- ind: Detector index number. The detectors can be numbered 1,2,...nd

- L2: Distance (m) from the sample to detector.

- phi: Scattering angle (degrees) i.e. angle between the incident beam direction and a line connecting the sample to the detector. In spherical polar coordinates where the conventional z-axis points in the direction of the incident beam, this angle is the conventional polar angle theta.

- azim: Azimuthal angle (degrees). In the spherical polar frame defined above, and with the conventional y-axis pointing vertically upwards, this angle is the conventional azimuthal angle phi.

- width: Width (m) of the detector perpendicular to the Debye-Scherrer ring through the detector.

- length: Length (m) of the detector tangential to the Debye-Scherrer ring through the detector.

The width and length of the detector are not actually used by Horace, but dummy values need to be provided.

``nxspefile_name``: The name of the file to which the data will be saved.

``efix``: Fixed energy (meV). If emode=1 this is the fixed incident energy, if emode=2 it is the fixed final energy.

``psi``: Rotation about the vertical axis. This is the angle between the vector u of the pair of vectors u and v that define the horizontal scattering plane of the crystal.


SPE file and PAR file
=====================

These files may be encountered if you are using Horace to analyse older data. The ASCII format SPE file stores S(w) and associated error bars as a function of energy transfer, h-barw, for each detector in turn. In addition to the set of SPE files, Horace requires an accompanying ASCII file which contains information about the location of the detectors in the spectrometer's reference frame, the PAR file. Although these ASCII format files have largely been superseded in favour of the NXSPE format described above, such files are ubiquitous as the format in which historic data is saved, and are recognised by several other neutron visualisation and analysis programs. Some programs can also write their own output as SPE files, and consequently the SPE file is sometimes used as a transportable format data file for time-of-flight neutron spectrometers. The format of these two files is described here. However, it is not recommended to create new SPE files as it is now an obsolete file format.

SPE file format
***************

The SPE file contains the intensity and estimated standard deviation on those intensities for each detector element in turn, with header blocks that give the number of detectors and energy bins, and the scattering angle and energy transfer bin boundaries. These blocks are all separated by character strings that begin with '###'. In full:


::

   nd ne

   ### Phi Grid

   phi(1) phi(2)    phi(3)  phi(4)  phi(5)  phi(6)  phi(7)  phi(8)
   phi(9) phi(10)   phi(11) phi(12) phi(13) phi(14) phi(15) phi(16)
   :
   ...    phi(nd+1)

   ### Energy Grid

   en(1) en(2)    en(3)  en(4)  en(5)  en(6)  en(7)  en(8)
   en(9) en(10)   en(11) en(12) en(13) en(14) en(15) en(16)
   :
   ...   en(ne+1)

   ### S(Phi,w)

   S(1) S(2)  S(3)  S(4)  S(5)  S(6)  S(7)  S(8)
   S(9) S(10) S(11) S(12) S(13) S(14) S(15) S(16)
   :
   ...  S(ne)

   ### Errors ERR(1)  ERR(2)  ERR(3)  ERR(4)  ERR(5)  ERR(6)  ERR(7)  ERR(8)
   ERR(9)     ERR(10) ERR(11) ERR(12) ERR(13) ERR(14) ERR(15) ERR(16)
   :
   ...        ERR(ne)

   ### S(Phi,w)
   :
   ### Errors
   :


Here nd is the number of detectors, ne is the number of energy bins, phi contains scattering angles that are now ignored by all applications as well as Horace (set to 1,2,3...(nd+1)), en contains the energy transfer bin boundaries, and S and ERR contain the signal and standard error on the signal for each detecetor in turn.

On the first line, nd and ne need only to be separated by white space. In the blocks containing the signal and error the format is highly prescribed: each line must contain 8 real numbers, apart from the last line in each block, and each number must occupy a field of precisely 10 spaces. No white space is necessary. This is a frequent source of problem when writing the files. It is strongly recommended that you do not try to create your own SPE format files.


PAR file format
***************

The PAR file contains the position information of the detectors and their sizes. The format is:


======== ========= ========== =========== ============
ndet
L2(1)    phi(1)    azim(1)    width(1)    length(1)
L2(2)    phi(2)    azim(2)    width(2)    length(2)
:        :         :          :           :
L2(ndet) phi(ndet) azim(ndet) width(ndet) length(ndet)
======== ========= ========== =========== ============



where

- ndet: Total number of detector elements.

- L2: Distance (m) from the sample to detector.

- phi: Scattering angle (degrees) i.e. angle between the incident beam direction and a line connecting the sample to the detector. In spherical polar coordinates where the conventional z-axis points in the direction of the incident beam, this angle is the conventional polar angle theta.

- azim: Azimuthal angle (degrees). In the spherical polar frame defined above, and with the conventional y-axis pointing vertically upwards, this angle is the conventional azimuthal angle phi.

- width: Width (m) of the detector perpendicular to the Debye-Scherrer ring through the detector.

- length: Length (m) of the detector tangential to the Debye-Scherrer ring through the detector.

The width and length of the detector are not actually used by Horace, but dummy values need to be present in the file. The parameters need to be separated by white space, but otherwise there are no constraints on the format. NIMA_834_132_Horace_Paper.
