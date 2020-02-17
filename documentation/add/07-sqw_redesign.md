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

#### Instrument Data

Full model of the machine instrument and detectors -- required for SQW object containing Pixel Data.

- Instance of the Herbert `IX_Instr` class used by TobyFit

Notes 

(1): Where does the data for this come from?

#### Pixel Data

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

## Migration Path

 *After each refactoring change it is essential that the unit and system tests pass; unit tests should be added for all new APIs.*

1. Ensure system tests exist that cover the major end-to-end paths through the system (`gen_sqw`,`tobyfit`, `multifit`, `cut`, `symmetrize` etc) and that these run and pass
2. Extract small data and utility classes from existing SQW object updating APIs across Horace and Herbert code  where appropriate. New classes should be "new style" MATLAB classes.
3. Extract `PixelBlock` into new class. All associated APIs updated.
4. Migrate `SQW` and `DND` objects to new style classes.
5. Review API and data in `SQW` and `DND`classes with a view to removing unrequired methods and data.

## Implementation Decisions

- Handle classes to be used for external objects (e.g. DND, SQW)

- Update SQW object to include number of pixblock columns and read/write N columns rather than the current fixed 7

- Experiment object includes array of instrument, sample, lattice, detector data and mappings from pix-block to objects

- Instrument data will be added to SQW object post-creation until full data is available in the Mantid data files; scripts exist for construction of LET and are a model for other instruments. Since the Mantid file parse will require an XML to IX_Inst builder this can be written ahead of time and instruments created as XML.

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

#### ProjectionManager

Responsible for all image projections - this includes:

- Crystal Cartesian to h,k,l,
- arbitrary rotation,
- arbitrary offset,
- plane cuts
- spherical cuts
- cylindrical cuts

Operations result in the creation of a new SQW object. Operations are performed to the Image Pixels using data from the backing PixelBlock.

#### IProjection

Interface class for single projection/transformation operation.

#### Image

Represents the n-dimensional array of image pixel data with associated axis information. 

Image pixel data is generated from the PixelBlock.

- requires a well-defined mapping from image pixels to source data pixel

#### Axes

Represents a set of axis
- value range
- unit vectors
- units
- matrix mapping these axes to the pixel data (? or should this be in the projection....)

#### Pixel Block

Contains the "raw" pixel data expressed as crystal Cartesian and detector index form.

Provides methods to "get contributing pixels" for any subset of image pixels as well as get/set methods for each column or block of columns, e.g. `get_signals()`, `get_coordinates()`, `get_energy_ids()` and the number of pixels.

Custom data may be stored per-pixel in a named elements `get_data(name): data[n,m]`.

The same `get_data(name)` method can be used to provide access to the "standard" data (e.g. `get_data("signal")`)

- requires a well-defined mapping from image pixels to source data pixel

#### IX_dataset

Utility class for plot rendering; contains a simple representation of the image pixel data and axes with no additional functionality or data

#### MainHeader

Metadata for the file:

- number of files
- file information

#### Experiment

Collects all data describing the experiment: sample, conditions, instrument, detectors

- Instrument specification (`IX_instr`)
- Detector information (`IX_detector_array`)
- Sample information (`IX_sample`)  --  orientation, lattice angles, goniometer position

#### Header

Represents metadata for a single source file

- filepath and filename
- sample state (orientation, lattice angles, goniometer position
- mapping of PixelBlock detector, run, instrument IDs to elements in the instrument and detector arrays
- mapping of array of energies (incident or final) to detector and instrument blocks


#### OperationsManager

Utility class implementing low-level arithmetic operations.

Responsible for performing calculation on Image or Pixel data as appropriate.



### Class Overview

#### SQW
![SQW Class Overview](C:\Users\xzl80115\PACE\Horace\documentation\diagrams\sqw.png)

#### DND
![DND Class Overview](C:\Users\xzl80115\PACE\Horace\documentation\diagrams\dnd.png)

#### Projection
![Projection Class Overview](C:\Users\xzl80115\PACE\Horace\documentation\diagrams\projection.png)

### Public API


#### Model fitting (SQW)

| Operation            | SQW  | DND  | Notes |
| -------------------- | :--: | :--: | :---- |
| `multifit.m`         |  y   |  y   |       |
| `multifit_func.m`    |  y   |  y   |       |
| `multifit_sqw.m`     |  y   |  y   |       |
| `multifit_sqw_sqw.m` |  y   |  y   |       |

Q: Are these distinct functions or simply a set of optional arguments?

#### Bin calculations (SQW)
| Operation            | SQW  | DND  | Notes |
| -------------------- | :--: | :--: | :---- |
|`calculate_q_bins.m` | y | y ||
|`calculate_qsqr_bins.m`| y | ||
|`calculate_qsqr_w_bins.m`| y | ||
|`calculate_qsqr_w_pixels.m`| y | ||
|`calculate_qw_bins.m` | y | y ||
|`calculate_qw_pixels.m`| y | ||
|`calculate_qw_pixels2.m`| y | |This should be used in place of `calculate_qw_pixels` as it handles the symmetrized data case correctly.|
|`calculate_uproj_pixels.m` | y | |Projection|

#### Projection Manager  (SQW)

Provides methods to *generate* an image from an existing image (DND) or the base pixel data; supports definition of multiple sequential transformations.
| Operation            | SQW  | DND  | Notes |
| -------------------- | :--: | :--: | :---- |
|`cut` | y | n | Perform a cut and return new SQW object|
|`symmetrize`| y | n | Symmetrize return new SQW object |
| `transform` | y | y | Execute a sequence of `IProjection`s on the data to create a new image |

#### IProjection

Interface class to support the creation of a range of simple projections - translation, rotation, skew, cylindrical, spherical.

| Operation            | SQW  | DND  | Notes |
| -------------------- | :--: | :--: | :---- |
|`apply_tansformation` | y | y | Execute the transformation and return a new data object|

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
|`noisify.m`| y | y | Add random noise and update error for image data |
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

#### Display (helper)

|Operator|SQW|DND|Notes  |
|--------|:-:|:-:|:------|
|`display.m`  | y | y | pretty print object|
|`shift_energy_bins.m`| y | n | for plotting data adjusted with `shift_pixels` |
|`run_inspector.m`| y | n | Display UI for browsing|

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

#### Pixel Block

Object supports storage of custom data in addition to the standard 9-columns of pixel data. These are stored in a dictionary `{name: value}`.

| Operation  |          | Notes |
| ---------|---------- | :---- |
| `get_pixels` | `set_pixels` | Return/replace full pixel block array |
| `get_coords` | `set_coords` | Return/replace `n x 4` array of the four co-ordinates |
| `get_run_ids` | `set_run_ids` | Return/replace `n x 1` vector of run indexes |
| `get_energy_ids` | `set_energy_ids` | Return/replace `n x 1` vector of energy indexes |
| `get_detector_ids` | `set_detector_ids` | Return/replace `n x 1` vector of detector indexes |
| `get_signal` | `set_signal` | Return/replace `n x 1` vector of run signal |
| `get_variance`| `set_variance`  | Return/replace `n x 1` vector of run signal variances |
| `get_num_pixels`|   | Return number of pixels (`n`) |
| `get_data(name)` | `set_data(name, ...)` | Return/replace `n x m` array of (named) custom or default data |

## PseudoCode


### PixelBlock

Existing PixelBlock read/write from the `SQW` object are to slices, e.g. in `tobyfit_DGdisk_resconv`

```matlab
% Run and detector for each pixel
irun = win(i).data.pix(5,:)';   % column vector
idet = win(i).data.pix(6,:)';   % column vector
npix = size(win(i).data.pix,2);
```

or `read_cut_diff`

```matlab
% Take difference between the cut files, looking after error bars appropriately
data=data1;     % pick up values from first dataset

data.y=data1.y-data2.y;    
data.pixels(:,5)=data1.pixels(:,5)-data2.pixels(:,5);
if all(ebars==[0,0])
    data.e=zeros(size(data.e));
    data.pixels(:,6)=0;
elseif all(ebars==[0,1])
    data.e=data2.e;
    data.pixels(:,6)=data2.pixels(:,6);
elseif all(ebars==[1,1])
    data.e=sqrt(data1.e.^2+data2.e.^2);
    data.pixels(:,6)=sqrt(data1.pixels(:,6).^2+data2.pixels(:,6).^2);
end
```


#### Proposed API

The new PixelBlock class can wrap this access with a `getPixels()` if there is a need for the whole array (e.g. for writing) or via helper `getX`/`setX` functions:

```
getPixels() { return pixels }

getCoords() { return pixels(:, 1:4) }
getRunIds() { return pixels(:, 5) }
getDetectorIds()  { return pixels(:, 6) }
getEnergyIds()  { return pixels(:, 7) }
getSignal() { return pixels(:, 8) }
getVariance() { return pixels(:, 9) }
getNumPixels() { return npix }

setSignal(signal) { pixels(:, 8) = signal }
setVariance(var) { pixels(:, 9) = var }
[...]
```
So the example in  `tobyfit_DGdisk_resconv` becomes

```matlab
% Run and detector for each pixel
irun = win(i).data.getRunIds()';   % column vector
idet = win(i).data.getDetectorIds()';   % column vector
npix = win(i).data.getNumPixels();
```

Over use-cases in `recompute_bin_data`:

```matlab
wout.data.s=accumarray(ind, w.data.pix(8,:), [nbin,1])./w.data.npix(:);
```
becomes
```matlab
wout.data.s=accumarray(
  ind, w.data.getSignal(), [nbin,1]
)./w.data.getNumPixels();
```
and in `noisify`        

```matlab
[wout(i).data.pix(8,:),wout(i).data.pix(9,:)]=noisify(
  w(i).data.pix(8,:), w(i).data.pix(9,:), varargin{:});
```
becomes
```matlab
[sig, var] = noisify(
  w(i).data.getSignal(), w(i).data.getVariance(), varargin{:}
)

wout(i).data.setSignal(sig)
wout(i).data.setVar(var)
```
or
```matlab
wout(i).data.setSigVar(
  noisify(
    w(i).data.getSignal(), w(i).data.getVariance(), varargin{:}
  )
)
```



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

