function w = combine_libisis (s1, s2)
% combines a Horace dataset with a Libisis dataset. If given any other data
% type of data, then the returned value will be the first input. 
% 
% syntax: 
%
% >> Horace_dnd2 = combine_libisis(Horace_dnd, Libisis_dataset_nd)
%
% where n is the dimensionality of the dataset. 
%
% The header data and orientation data is taken from the Horace dataset,
% while the plot axis, signal and error data is taken from the Libisis
% dataset. 
%
% example:
%
% >> new_d1d = combine_libisis(d1d, IXTdataset_1d)
%
% new_d1d will be the same as d1d except that:
%
% new_d1d.s = IXTdataset_1d.signal
% new_d1d.p1 = IXTdataset_1d.x
% new_d1d.e = IXTdataset_1d.error

w = s1;