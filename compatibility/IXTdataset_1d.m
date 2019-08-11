function w=IXTdataset_1d(varargin)
% Compatibility function to construct an IX_dataset_1d in Herbert in place of the Libisis IXTdataset_1d constructor
%
%   >> w = IXTdataset_1d (...)

% Catch case of first argument is IXTbase

if numel(varargin)>0 && ~isnumeric(varargin{1}) && ~ischar(varargin{1}) && ~iscellstr(varargin{1})
    if numel(varargin)>1
        w=IX_dataset_1d(varargin{2:end});
    else
        w=IX_dataset_1d;
    end
else
    w=IX_dataset_1d(varargin{:});
end
