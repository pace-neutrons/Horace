# v3 SQW and DND implementations




### Process Data

|Operator|SQW|DND|Notes  |
|--------|:-:|:-:|:------|
|`calculate_q_bins.m` | y | y ||
|`calculate_qsqr_bins.m`| y | ||
|`calculate_qsqr_w_bins.m`| y | ||
|`calculate_qsqr_w_pixels.m`| y | ||
|`calculate_qw_bins.m` | y | y ||
|`calculate_qw_pixels.m`| y | ||
|`calculate_qw_pixels2.m`| y | ||
|`calculate_uproj_pixels.m` | y | |Projection|
|`change_crystal.m` | y | y ||
|`compact.m` | y | y ||
|`cut.m`  | y | |projects n-dimensions down onto a m-dimensional plane defined by the argument vectors|
|`cut_sym.m`  | y | |cut with symmetrization|
|`to_cut.m`| y | ||
|`to_slice.m`| y | | plot routine|
|`join.m`| y | ||
|`disp2sqw_eval.m` | y | y ||
|`dispersion.m` | y | y ||
|`func_eval.m` | y | y ||
|`hkle.m`| y | ||
|`mask.m` | y | y |(bins) mask hunks of data|
|`mask_detectors.m`| y | ||
|`mask_pixels.m`| y | ||
|`mask_points.m`| y | y ||
|`mask_random_fraction_pixels.m`| y | ||
|`mask_random_pixels.m`| y | ||
|`mask_runs.m`| y | ||
|`noisify.m`| y | y ||
|`permute.m`| y | y ||
|`pop.m` | y |n||
|`rebunch.m`| y | y ||
|`refine_crystal.m`| y | n ||
|`replicate.m`| y | | Extend dimension of dataset |
|`section.m`| y | y | Extract an n-dimensional rectangle bounded by axis limits from dataset as a SQW/DND object. Same effect as `cut` with no projection argument |
|`shift_pixels.m`| y | n||
|`signal.m` | y |n||
|`slim.m`| y | n | Remove random pixels (wrapper around `mask_*` functions)|
|`smooth.m`| y | y | Smooth DND data in pixel units|
|`smooth_units.m`| y |y  | Smooth DND data in axis units|
|sqw_eval.m| y |n | Calculate SQW for model scattering function|

### Model fitting

| Operation | SQW | DND | Notes |
|--------|:-:|:-:|:------|
|`multifit.m`| y | y ||
|`multifit_func.m`| y | y ||
|`multifit_sqw.m`| y | y ||
|`multifit_sqw_sqw.m`| y | y ||

### Object data operations

|Operator|SQW|DND| Notes |
|--------|:-:|:-:|:------|
|_Standard MATLAB unary operations_||||
| `acos.m` | y | y ||
| `acosh.m` | y | y ||
| `acot.m` | y | y ||
| `acoth.m` | y | y ||
| `acsc.m` | y | y ||
| `acsch.m` | y | y ||
| `asec.m` | y | y ||
| `asech.m` | y | y ||
| `asin.m` | y | y ||
| `asinh.m` | y | y ||
| `atan.m` | y | y ||
| `atanh.m` | y | y ||
| `cos.m` | y | y ||
| `cosh.m` | y | y ||
| `cot.m` | y | y ||
| `coth.m` | y | y ||
| `csc.m` | y | y ||
| `csch.m` | y | y ||
| `exp.m` | y | y ||
| `log.m` | y | y ||
| `log10.m` | y | y ||
| `sec.m` | y | y ||
| `sech.m` | y | y ||
| `sin.m` | y | y ||
| `sinh.m` | y | y ||
| `sqrt.m` | y | y ||
| `tan.m` | y | y ||
| `tanh.m` | y | y ||
| *Standard MATLAB binary operations* ||||
| `plus.m` | y | y ||
| `minus.m` | y | y ||
|`uminus.m`| y | y ||
| `uplus.m` | y | y ||
| `mtimes.m` | y | y ||
|`mrdivide.m`| y | y ||
|`mldivide.m`| y | y ||
| `mpower.m` | y | y ||

Wrappers classes for Herbert objects
|Operator|SQW|DND| Notes |
|--------|:-:|:-:|:------|
|`sigvar.m`| y | y ||
|`sigvar_get.m`| y | y ||
|`sigvar_set.m`| y | y ||
|`sigvar_size.m`| y | y ||

|Operator|SQW|DND| Notes |
|--------|:-:|:-:|:------|
|`get_test_calc_projections.m`| y | n ||
|`head.m` | y | y ||
|`header_average.m`| y | n ||
|`is_sqw_type.m`| y | n ||
|`is_sqw_type_file.m`| y | n ||
|`isvalid.m` | y | y ||
|`IX_dataset_1d.m` | y | y (d1d) ||
|`IX_dataset_2d.m` | y | y (d2d) ||
|`IX_dataset_3d.m` | y | y (d3d) ||
|`lattice_parameters.m`| y | n ||

|Operator|SQW|DND| Notes |
|--------|:-:|:-:|:------|
| *Custom operations* ||||
| `equal_to_tol.m` | y | n ||
|`arrayfun.m`| y | ||
|*Data information*||||
|`dimensions.m` | y | y ||
|`dimensions_match.m`| y |||
|*Get Data*||||
|`value.m`| y |||
|`xye.m`| y |||
|`copydata.m`  | y | y |SQW wraps DND copydata|
|`get_efix.m`| y |||
|`get_inst_class.m`| y |||
|`get_mod_pulse.m`| y |||
|`get_nearest_pixels.m`| y |||
|`get_proj_and_pbin.m` | y | y ||
|`get_sqw.m`| y |||
|*Set Data*||||
|`set_efix.m`| y | n ||
|`set_instrument.m`| y | n ||
|`set_mod_pulse.m`| y | n ||
|`set_sample.m`| y | n ||

### Object Converters

| Operation | SQW | DND | Notes |
|--------|:-:|:-:|:------|
|`d0d.m` | y |n | Convert SQW to specific dNd |
|`d1d.m`| y |n ||
|`d2d.m`| y |n ||
|`d3d.m`| y |n ||
|`d4d.m`| y |n||
|`dnd.m` | y |n | wrapper: SQW to appropriate dNd |
|`spe.m`| y | n |SQW to SPE|
|`split.m`| y |n | Split SQW into array of object made from SQE data sets|

### Load/Save

| Operation | SQW | DND | Notes |
|--------|:-:|:-:|:------|
|`read.m`| y | y | read sqw file |
|`save.m`| y | y | save as binary sqw file |
|`save_xye.m`| y | y | save as ascii |

### Display

|Operator|SQW|DND|Notes  |
|--------|:-:|:-:|:------|
|`display.m`  | y | y | pretty print object|
|`shift_energy_bins.m`| y | n | for plotting data adjusted with `shift_pixels` |
|`run_inspector.m`| y | n | Display UI for browsing|

### Deprecated 

These functions are currently marked as deprecated and can by removed in the new implementation.

|Operator|SQW|DND|Notes  |
|--------|:-:|:-:|:------|
|`accumulate_sqw.m`|y|n||
|`fit_func.m`  | y | y ||
|`fit.m` | y | y ||
|`fit_sqw.m` | y | y ||
|`fit_sqw_sqw.m` | y | y ||
|`fit_legacy.m` | y | y ||
|`fit_legacy_func.m` | y | y ||
|`fit_legacy_sqw.m` | y | y ||
|`fit_legacy_sqw_sqw.m` | y | y ||
|`multifit_legacy.`m| y | y | Complex interface|
|`multifit_legacy_func.m`| y | y ||
|`multifit_legacy_sqw.m`| y | y ||
|`multifit_legacy_sqw_sqw.m`| y | y ||

### Fake class API

Utilities/support for old-classes implemented from [A Comprehensive Guide to OO Programming in Matlab](https://books.google.co.uk/books?id=mYLOBQAAQBAJ&pg=PA27&lpg=PA27&dq=andy+register+struct+matlab&source=bl&ots=YNxVTUATco&sig=ACfU3U0TJ0vTlGlHqrEJrZ27LOoTpRnaRQ&hl=en&sa=X&ved=2ahUKEwjxraOEi-zlAhUlmVwKHZvjAXMQ6AEwA3oECAkQAQ#v=onepage&q=struct&f=false) (C) Andy Register

|Operator|SQW|DND|
|--------|:-:|:-:|
|`get.m` | y | y |
|`set.m`| y | y |
|`struct.m`| y | y |
|`subsasgn.m`| y | y |
|`subsref.m`| y | y |

### Test

| Operator | SQW | DND | Notes |
|:-------------|:-:|:-:|:---------|
|`accumulate_cut_tester.m`| y | n | |
|`testgateway.m`| y | n | Expose private methods for testing |
|`recompute_bin_data_tester.m`|y | n | Expose private methods for testing |

`private/`

average_bin_data.m
binary_op_manager.m
binary_op_manager_single.m
calculate_qw_points.m
change_crystal_alter_fields.m
check_parameter_values_ok.m
check_sqw.m
check_sqw_detpar.m
check_sqw_header.m
check_sqw_main_header.m
checkfields.m
classname.m
combine_dnd_same_bins.m
combine_sqw_same_bins.m
compress_array.m
coordinates_calc.m
copydata_dnd.m
cut_data_from_array.m
cut_data_from_file.m
cut_dnd_calc_ubins.m
cut_dnd_main.m
cut_sqw_check_input_args.m
cut_sqw_check_sym_arg.m
cut_sqw_main.m
cut_sqw_main_single.m
cut_sqw_read_data.m
cut_sqw_sym_main.m
cut_sqw_sym_main_single.m
data_bin_limits.m
data_dims.m
display_single.m
fieldnames_comments.m
header_average.m
ind_from_nrange.m
is_horace_data_object.m
permute_pix_array.m
rebunch_dnd.m
recompute_bin_data.m
recompute_urange.m
replicate_array.m
replicate_dnd.m
run_inspector_animate_1d.m
run_inspector_animate_2d.m
run_inspector_videofig.m
smooth_dnd.m
smooth_func_gaussian.m
smooth_func_hat.m
smooth_func_resolution.m
sqw_display_single.m
title_squeeze.m
unary_op_manager.m



make_sqw.m    // constuct class
make_sqw_detpar.m
make_sqw_header.m // build header
make_sqw_main_header.m

## SQW Properties

| Header | Comment |
|:---|:----|
|  filename  | Name of sqw file excluding path|
|  filepath  | Path to sqw file including terminating file separator|
|  efix      | Fixed energy (ei or ef depending on emode)|
|  emode   |   Emode=1 direct geometry, =2 indirect geometry|
|  alatt     | Lattice parameters (Angstroms)|
|  angdeg |    Lattice angles (deg)|
|  cu       |  First vector defining scattering plane (r.l.u.)|
|  cv        | Second vector defining scattering plane (r.l.u.)|
|  psi       | Orientation angle (deg)|
|  omega   | --|
|  dpsi       |   Crystal misorientation description (deg)|
|  gl          |  See notes elsewhere e.g. Tobyfit manual|
|  gs        | --|
|  en         |Energy bin boundaries (meV) [column vector]|
|  uoffset   []| Offset of origin of projection axes in r.l.u. and energy ie. [h; k; l; en] [column vector]|
|  u_to_rlu   | Matrix (4x4) of projection axes in hkle representation  u(:,1) first vector - u(1:3,1) r.l.u., u(4,1) energy etc.|
|  ulen   |    Length of projection axes vectors in Ang^-1 or meV [row vector]|
|  ulabel     |Labels of the projection axes [1x4 cell array of character strings]|
|  instrument| Instrument information - free format|
|  sample    | Sample information - free format|



| Main Header | Comment |
|:---|:----|
|  filename|   Name of sqw file that is being read, excluding path|
|  filepath  | Path to sqw file that is being read, including terminating file separator|
|  title      |Title of sqw data structure|
|  nfiles    | Number of spe files that contribute|


| Detpar | Comment |
|:---|:----|
|  filename |  Name of file excluding path|
|  filepath  | Path to file including terminating file separator|
|  group     | Row vector of detector group number|
|  x2        | Row vector of secondary flightpath (m)|
|  phi       | Row vector of scattering angles (deg)|
|  azim     |  Row vector of azimuthal angles (deg)   (West bank=0 deg, North bank=90 deg etc.)|
|  width |     Row vector of detector widths (m)|
|  height  |   Row vector of detector heights (m)|

