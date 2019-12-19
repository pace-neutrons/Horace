# SQW

## Overview

This section describes the the role of the SQW object within the Horace framework, data it holds and operations it supports without focusing on any implementation details. 

Where specific fields are cited they are the key data that represent that information.

### What is the purpose?

Holds neutron scattering experiment data and provides methods that manipulate, slice and project the data and generate model fits using third-party functions, 

Provide an interface to the Horace file which can be interchanged with external applications (* TBI)

The SQW object exists in two distinct forms: 

- "DND" which contains only processed image data
- "SQW" which is backed by a full detector pixel array.

In an SQW object where pixel data is included, operations are performed on that data and the current image pixel data recalculated from this. For DND objects operations are performed directly on the image.

Historically these objects both operate as 'first class citizens', but that logical distinction is necessary.

### Operations

#### Generate SQW file

Combine multiple experiment [data files](http://horace.isis.rl.ac.uk/Input_file_formats)  (pairs of legacy `.spe` and `.par` files, or `.nxspe` files from Mantid) into a single SQW object. 

1) `.nxspe` / `.spe` (per-run) data files are converted to intermediate `.sqw`-format data files. Pixel data is ordered by "image pixel" buckets

2) Intermediate files are combined on a image-pixel bucket basis to produce the final `.sqw` file. There is *no aggregation of signal/err data* in this step.

#### Read/Write

- Read the file data, but not pixel data

- Read the pixel data or an m-dimensional cut of the pixel data
- Read the pixel data corresponding to specific image pixels
- Write the pixel data for specific image pixels
- Write all pixel data
- Support for legacy Horace file format and 'new' NeXus / HDF5 format (TBI)
- Display data to console (1)
- Export data to ASCII file (1)

**Notes**
(1): What data subset of should be displayed at the console or in an text  export file?

#### Data manipulation

- Implement basic arithmetic operations on object data. 

- Cut -- extract a N-dimensional subset of pixels

- Projection -- aggregate pixel data onto an M-dimensional surface (M<N). This should support projections onto planes and spherical shells (TBI) and spiral slices (TBI).

- Symmetrization -- enhance signal-to-noise utilizing symmetries within the data

The operations are performed on the pixel data and the image recalculated from that. If the pixel-data is not available (a DND object) the operations are performed directly on the image.

#### Model Fitting

- Fit experiment data to parametized models. 

- Tobyfit (included in Horace) and third-party models are supported.

- Models cay take additional resolution convolution function to remove artefacts from the image

### Data

#### Source File Data

- Filename(s) of experiment data  files contributing to this data object

#### Experiment Data

|  | Description | Notes |
|-----|---------|---|
| emode | switch for efix as incident or final energy ||
| efix | incident or final neutron energy for file ||
| alatt | sample lattice basis vector (&#X00C5;) ||
| angdeg | angles between samples lattice basis vector | (1) |
| cu | sample orienting vector along neutron beam (reciprocal lattice) ||
| cv | sample orienting vector along plane normal to &Psi; (reciprocal lattice) ||
| psi | nominal angle between `cu` and incident beam ||
| omega | angle between `cv` and goniometer rotation `gs` ||
| gl | goniometer rotation perpendicular to &Psi; about axis `omega` away from `cu` | (2) |
| gs | goniometer rotation perpendicular to `gl` and &Psi; | (2) |
| en[] | Energy bin boundaries in input file (meV) ||

**Notes**
(1): is this an array?
(2): "typically" constant for all SPE files in one SQW; what if it's not?

#### Detector Data

|  | Description | Notes |
|-----|---------|---|
|  x2[] | Sample-to-detector distances |(1)|
| phi[]  | angle from incident neutron to detector ||
| azim[]  | angle from plane perp to &Psi; about incident beam to detector ||
| width[] | detector width |(1)|
| height[] | detector height |(1)|
| iGroup | index of detector group ||

**Notes**
(1): all distances are in the same (unspecified) unit

#### Instrument Data (optional)

Only included with Pixel Data.

- Unconstrained dictionary of data (1).

**Notes**
(1): Should this contain some mandated data fields?

#### Pixel Data (optional)

|  | Description | Notes |
|-----|---------|---|
|u1, u2, u3, dE | coordinate in crystal Cartesian lattice (a\*, b\*, a\* x b*, dE) | (2) |
| iFile | index into headers array for source file |(1)|
| iDetector | index of pixel detector |(1)|
| iEnergy | index of energy bin | (1) |
| signal | Correlated intensity ||
| err | Intensity variance ||

**Notes**
(1): the triple of indexes uniquely identify the detector element corresponding to this pixel and are an alternate representation of the (u1,u2,u3,dE) data.

(2): pixel data are ordered by IMAGE PIXEL. If projection is applied the IMAGE PIX ARRAY IS REORDERED

#### Image Data

|  | Description | Notes |
|-----|---------|---|
| signal[] | Mean intensity, calculated as `Sum(pix_signal(k))/npix(k)` | (1), (3) |
| err[] | Average error, calculated as  `sqrt(Sum(pix_err(k)^2/npix(k)))` |(1), (3)|
| npix[] | Number of detector pixels contributing to each image pixel ||
| uoffset[] | Offset of pixel project axes origin ||
| u_to_rlue\[\]\[\] | Matrix of pixel project in hkle ||
| ulen[] | Length of pixel projection axes Ang^-1 or meV | (2) |

**Notes**
(1): if the image data is updated, e.g. after a slice or projection, the backing pixel data must be updated/reordered
(2): where is the data saying which unit this is?
(3): `pix_signal` represents the array of pixel signal data from which this image data was derived, `pix_err` the array of pixel variance.

### Constraints

Object must support working with objects larger than system RAM. This requires the use of a "temporary" SQW file with updated pixel data; changes only written to the original file with an explicit write to avoid accidental modification of data.

Operations should make use of multi-core and multiprocessors when available

## Design

This section describes the implementation of SQW including full API and class breakdown.

#### Requirements

- Define primary API between objects
- Create standard co-ordinate systems for pixel data and common interface to create projections into alternate frames

### Classes

#### SQW

Core object providing the public API to datasets.

Responsible for supporting all required operations

_What does that actually mean?!_

#### Projection

Responsible for all image projections - this includes:

- Crystal Cartesian to h,k,l,
- arbitrary rotation,
- arbitrary offset,
- plane cuts
- spherical cuts
- cylindrical cuts

Operations result in the creation of a new SQW object.

Operations are performed to the Image Pixels using data from the backing PixelBlock.

#### Image

Represents the n-dimensional array of image pixel data with associated axis information. 

Image pixel data is generated from the PixelBlock.

- requires a well-defined mapping from image pixels to source data pixel

#### Axes

Represents a set of axis
- value range
- unit vectors
- units
- matrix mapping these axes to the pixeldata (? or should this be in the projection....)

#### PixelBlock

Contains the "raw" pixel data expressed as crystal Cartesian and detector index form.

Provides methods to "get contributing pixels" for any subset of image pixels.

- requires a well-defined mapping from image pixels to source data pixel

#### IX_dataset

Utility class for plot rendering; contains a simple representation of the image pixel data and axes with no additional functionality or data

#### OperationsManager

Utility class implementing low-level arithmetic operations.

Responsible for performing calculation on Image or Pixel data as appropriate.




### Public API


#### Model fitting (SQW)

| Operation            | SQW  | DND  | Notes |
| -------------------- | :--: | :--: | :---- |
| `multifit.m`         |  y   |  y   |       |
| `multifit_func.m`    |  y   |  y   |       |
| `multifit_sqw.m`     |  y   |  y   |       |
| `multifit_sqw_sqw.m` |  y   |  y   |       |

Q: Are these distinct functions or simply a set of optional arguments?

#### Data manipulation (SQW)

| Operation            | SQW  | DND  | Notes |
| -------------------- | :--: | :--: | :---- |
|`mask.m` | y | y |(bins) mask hunks of data|
|`mask_points.m`| y | y | Mask all pixels lying outside axis bounds |
|`mask_detectors.m`| y | n | Remove all pixels from one or more detectors ids |
|`mask_pixels.m`| y | n | Retain pixels defined by binary mask (1) |
|`mask_random_fraction_pixels.m`| y | n | Retain a random fraction `(0,1)` of pixels from the dataset (scalar or per-axis) |
|`mask_random_pixels.m`| y | n | Discard all except N random pixels from the dataset (scalar or per-axis) |
|`mask_runs.m`| y | n | Remove all pixels from a specified run |
|`slim.m`| y | n | Remove random pixels (wrapper around `mask_*` functions)|

Note: operations are performed on backing detector data where appropriate and image recalculated using the current projection

#### Object Conversions (IX_Dataset)

| Operator | SQW  | DND  | Notes |
| -------- | :-:  | :-:  | :------ |
|`IX_Dataset` |      |      | Factory returning IX_Dataset_Nd instance |

#### Load/Save (SQW)

| Operation  | SQW  | DND  | Notes                                   |
| ---------- | :--: | :--: | :-------------------------------------- |
| `read.m`   |  y   |  y   | read .`nxsqw` or `.sqw` file            |
| `save.m`   |  y   |  y   | save `.nxsqw` (or`.sqw` file with flag) |
| `export.m` |  y   |  y   | export data to ascii file               |

#### Standard arithmetic operations (SQW via OperationsManager)

| Operator                            | SQW  | DND  | Notes |
| ----------------------------------- | :--: | :--: | :---- |
| *Standard MATLAB unary operations*  |      |      |       |
| `acos.m`                            |  y   |  y   |       |
| `acosh.m`                           |  y   |  y   |       |
| `acot.m`                            |  y   |  y   |       |
| `acoth.m`                           |  y   |  y   |       |
| `acsc.m`                            |  y   |  y   |       |
| `acsch.m`                           |  y   |  y   |       |
| `asec.m`                            |  y   |  y   |       |
| `asech.m`                           |  y   |  y   |       |
| `asin.m`                            |  y   |  y   |       |
| `asinh.m`                           |  y   |  y   |       |
| `atan.m`                            |  y   |  y   |       |
| `atanh.m`                           |  y   |  y   |       |
| `cos.m`                             |  y   |  y   |       |
| `cosh.m`                            |  y   |  y   |       |
| `cot.m`                             |  y   |  y   |       |
| `coth.m`                            |  y   |  y   |       |
| `csc.m`                             |  y   |  y   |       |
| `csch.m`                            |  y   |  y   |       |
| `exp.m`                             |  y   |  y   |       |
| `log.m`                             |  y   |  y   |       |
| `log10.m`                           |  y   |  y   |       |
| `sec.m`                             |  y   |  y   |       |
| `sech.m`                            |  y   |  y   |       |
| `sin.m`                             |  y   |  y   |       |
| `sinh.m`                            |  y   |  y   |       |
| `sqrt.m`                            |  y   |  y   |       |
| `tan.m`                             |  y   |  y   |       |
| `tanh.m`                            |  y   |  y   |       |
| *Standard MATLAB binary operations* |      |      |       |
| `plus.m`                            |  y   |  y   |       |
| `minus.m`                           |  y   |  y   |       |
| `uminus.m`                          |  y   |  y   |       |
| `uplus.m`                           |  y   |  y   |       |
| `mtimes.m`                          |  y   |  y   |       |
| `mrdivide.m`                        |  y   |  y   |       |
| `mldivide.m`                        |  y   |  y   |       |
| `mpower.m`                          |  y   |  y   |       |

## Glossary

| | |
|---|---|
|`.d0d`, `.d1d`, `.d2d`, `.d3d`, `.d4d` | n-dimensional Horace binary data file|
| DND | n-dimensional image data object |
|`.nxspe`|NeXus / HDF5 experiment information and detector geometry file format |
|`.par`| Legacy detector geometry information [format](https://docs.mantidproject.org/nightly/algorithms/SavePAR-v1.html#algm-savepar) |
|`.spe`| Legacy experiment data [format](https://docs.mantidproject.org/nightly/algorithms/SaveSPE-v1.html#algm-savespe) |
|`.sqw`| Horace binary data file |
| SQW | Horace data object including experiment, pixel and image data |
|`.nxsqw` | Horace NeXus/HDF5 data file [format](http://download.nexusformat.org/sphinx/classes/applications/NXspe.html) |
