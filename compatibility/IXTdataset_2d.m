function w=IXTdataset_2d(varargin)
% Compatibility function to construct an IX_dataset_2d in Herbert in place of the Libisis IXTdataset_2d constructor
%
%   >> w = IXTdataset_2d (...)

% Catch case of first argument is IXTbase

if numel(varargin)>0 && ~isnumeric(varargin{1}) && ~ischar(varargin{1}) && ~iscellstr(varargin{1})
    if numel(varargin)>1
        w=IX_dataset_2d(varargin{2:end});
    else
        w=IX_dataset_2d;
    end
else
    w=IX_dataset_2d(varargin{:});
end
