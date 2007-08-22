function wout = dnd_data_op(win, data_op, class_type, class_ndim, varargin)
% Horace dnd_data_op - operates on the data of a dnd object
%
% >> wout = dnd_data_op(win, data_op, class_type, class_ndim, varargin)
%
% inputs:
%---------
%       win:            input dataset
%       data_op:        handle to function to be performed (note that this
%                       should be a handle to the appropriate libisis
%                       function)
%       class_type:     string containing class type 
%       class_ndim:     number of dimensions in class type
%       varargin:       arguments required for operation given
%
% output:
%---------
%       wout:           Output dataset 
%
%       All fields will be the same as win except signal and plot axes
%       fields (i.e. wout.p1, wout.p2, ...). Some operations may be
%       performed on the title and axes labels. 
%
% datasets are converted to their Libisis counterparts and operated on
% using the function handle, then converted back again.
%
% example:
%----------
%
% >> myout = dnd_data_op(d2d_in, @rebin_x, 'd2d', 2, [0,100,10000])
%
% The above example will rebin along the p1 axis between 0 and 10000 in
% bins of 100. Note that the libisis and Horace axes related like so:
%
%       Horace Axis:            Libisis Axis:
%       p1              |       x
%       p2              |       y
%       p3              |       z
%       p4              |       no analogue.
% 
% 
for i = 1:numel(varargin)
    if isa(varargin{i},'d1d') || isa(varargin{i},'d2d')
        varargin{i} = convert_to_libisis(varargin{i});
    end
end

if strcmp(class_type,'d1d') || strcmp(class_type,'d2d')
    libisis_win = convert_to_libisis(win);
    libisis_wout = data_op(libisis_win, varargin{:});
    wout = combine_libisis(win, libisis_wout);
else
    error('data operations can only be performed on d2d or d1d objects')
end