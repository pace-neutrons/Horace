function obj_out = replicate (obj, n)
% Replicate detector elements to make n-fold larger detector array
%
%   >> obj_out = reorder (obj, n)
%
% Input:
% ------
%   obj         Input object
%   n           Number of times to replicate the detectors
%
% Output:
% -------
%   obj_out     Output array such that all internal data has been
%               repeated n times, increasing the nmber of detectors by a
%               facator of n


% Replicate the detector arrays
obj_out = obj;

store_check = obj_out.do_check_combo_arg_;
obj_out.do_check_combo_arg_ = false;

obj_out.depth  = repmat(obj.depth_,[n,1]);
obj_out.width  = repmat(obj.width_,[n,1]);
obj_out.height = repmat(obj.height_,[n,1]);
obj_out.atten  = repmat(obj.atten_,[n,1]);

obj_out.do_check_combo_arg_ = store_check;
