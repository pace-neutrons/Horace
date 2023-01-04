function is = is_sqw_struct(input)
% Check if input structure contans everything necessary to be used 
% as sqw obuect in some situiations e.g. 
%
% either: 
%       provides information to define a real sqw object
% or 
%       define the object, which may be used as sqw object in some tests
%
is = isa(input,'binfile_v4_block_tester') || ... % this is for testing new file format
    (isstruct(input) && all(isfield(input,{'main_header','header','detpar','data'})));
