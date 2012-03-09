function w=IXTdataset_3d(varargin)
% Compatibility function to construct an IX_dataset_3d in Herbert in place of the Libisis IXTdataset_3d constructor
%
%   >> w = IXTdataset_3d (...)

% Catch case of first argument is IXTbase

if numel(varargin)>0 && ~isnumeric(varargin{1}) && ~ischar(varargin{1}) && ~iscellstr(varargin{1})
    if numel(varargin)>1
        w=IX_dataset_3d(varargin{2:end});
    else
        w=IX_dataset_3d;
    end
else
    w=IX_dataset_3d(varargin{:});
end
