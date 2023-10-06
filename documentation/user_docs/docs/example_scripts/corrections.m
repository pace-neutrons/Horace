%Worked example script for data corrections

%Aleks Krajewska 15/09/2022

%After obtaining datasets one often needs to apply corrections, such as
%background subtraction or thermal population factor correction

%Set the data folder
folder = '/mnt/ceph/auxiliary/pace/docs/05_10_corrections_spinw-horace/';

%Load the example raw sqw file
sqw_file = ['/instrument/MERLIN/CYCLE20191/RB1910504/', 'CaFe2O4_70meV.sqw'];

%Define the projection axes
proj = line_proj([1,0,0], [0,1,0], [0,0,1]);
proj = line_proj([1,1,0], [-1,1,0], [0,0,1], 'nonorthogonal', true);

%%
%1 Addition/subtraction: Background. For magnetism, common subtraction methods
%involve: subtracting high temperature dataset from the low temperature
%dataset, subtracting empty sample environment/instrument dataset,
%subtracting a reference sample dataset (a "phonon blank",
%that is a sample with identical structure but only non-magnetic ions) or
%subtracting a high-Q region with weak magnetic signal from the rest of the
%low temperature dataset.

%Here, only the low temperature sample dataset is available and hence the
%last method, which is the least common, will be used.

%Plot the slice.
%Note that here we plot very far in Q which at first does not seem useful. However,
%in this material, the spin waves persist until high Q. For sampling high-Q
%background one needs to go in Q to values of 8-10 in the first projection
%axis.

slice=cut(sqw_file,proj,[-10,0.025,5],[0.9,1.1],3.5+[-0.3,0.3],[0,0.4,40]);
plot(compact(slice));
lz 0 1;
grid on;
keep_figure;

%Make 1D cut from the above slice at high Q
background = cut(slice, [-8.3,-7.7], []);
plot(background);
keep_figure;

%Tile the 1D background cut to match the slice dimension. Note the dnd
%conversion. The 1D cut is taken from a particular Q,E region with
%particular pixel infomation. Simply replicating this pixel information is
%incorrect, and therefore the pixel information is fully discarded by
%converting to dnd objects.
background_rep = replicate(d1d(background), d2d(slice));
plot(background_rep);
lz 0 1;
grid on;
keep_figure;

%Subtract the background "slice" from the original low temperature slice
%with magnetic signal
slice_sub = d2d(slice) - background_rep;
plot(slice_sub);
lz 0 1;
grid on;
keep_figure

%Compare "slice" and "slice-sub". Some of the intensity, especially around
%the elastic line, is subtracted.

%%
%2 -Multiplication: Bose correction. The scattering from bosonic
%excitations (e.g. magnons) is proportional to the Bose-Einstein population
%factor at T>0:

%n(E,T) = [1- exp(E/(kB*T))]

%where n(E,T) is the energy E and temperature T - dependent Bose-Einstein
%population factor and k_B is the Boltmann constant.

%Plot the slice
slice = cut(sqw_file,proj1,-1+[-0.1,0.1],[0,0.025,2],2+[-0.15,0.15],[0,0.4,40]);
plot(compact(slice));
lz 0 1;
grid on;
keep_figure;

%For this correction the energy from the slice is needed. It used to be
%possible with "signal" function, however it no longer works. Instead, one can
%extract parts of the slice with "sqw_eval" function and a function with a
%dummy parameter p:
energy = coordinates_calc(slice, 'E');
plot(energy);
grid on;
keep_figure;
energy_matrix = energy.data.s

%Write the Bose function for temperature T = 5 K to create a slice with
%bose correction for each datapoint in the slice.
T = 5
bose_factor = (1-exp((-11.6044 * energy)/T));
plot(bose_factor);
lz 0 1;
grid on;
keep_figure;

%Apply Bose correction to the original slice
slice_bose_corrected = slice * bose_factor
plot(compact(slice_bose_corrected));lz 0 1;grid on;keep_figure;

%What was done above gives the same result as the "bose" function with
%bose(input, temperature)
slice_bose_corrected_2 = bose(slice, 5);
plot(compact(slice_bose_corrected_2));lz 0 1;grid on;keep_figure;
