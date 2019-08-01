function w=IXTdataset_4d(varargin)
% Compatibility function to construct an IX_dataset_4d in Herbert in place of the Libisis IXTdataset_4d constructor
%
%   >> w = IXTdataset_4d (...)

% Catch case of first argument is IXTbase

if numel(varargin)>0 && ~isnumeric(varargin{1}) && ~ischar(varargin{1}) && ~iscellstr(varargin{1})
    if numel(varargin)>1
        w=IX_dataset_4d(varargin{2:end});
    else
        w=IX_dataset_4d;
    end
else
    w=IX_dataset_4d(varargin{:});
end
