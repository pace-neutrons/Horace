function [handles_out,ndims]=hor_sqwdims(handles_in)
%
% function to deterine dimensionality of workspace object that is of the
% class 'sqw'.
%
% R.A. Ewings 24/11/2008
%

%There is a function in Horace to do this:

[ndims,sz] = dimensions(handles_in.w_in);
handles_out=handles_in;