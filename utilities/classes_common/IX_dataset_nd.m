function w = IX_dataset_nd (varargin)
% Constructor for generic n-dimensional dataset. Not a class method, but gateway to constructors
%
%   >> w = IX_dataset_nd (ndim)         Create empty of object of the requested dimensionality
%   >> w = IX_dataset_nd (title, signal, error, s_axis, ax)
%
% 	title				char/cellstr	Title of dataset for plotting purposes (character array or cellstr)
% 	signal              double  		Signal (vector)
% 	error				        		Standard error (vector)
% 	s_axis				IX_axis			Signal axis object containing caption and units codes
%                   (or char/cellstr    Can also just give caption; multiline input in the form of a
%                                      cell array or a character array)
%   ax                  structure       Array of axis information structures; numel(ax)=dimensionality
%                                       Each element of ax has fields:
%           values          double     	Values of bin boundaries (if histogram data)
% 						                Values of data point positions (if point data)
%           axis            IX_axis     IXaxis object containing caption and units codes
%                   (or char/cellstr    Can also just give caption; multiline input in the form of a
%                                      cell array or a character array)
%           distribution    logical     Distribution data flag (true is a distribution; false otherwise)

% -------------------------------------------------------------------------------------------------
if nargin==1 && isnumeric(varargin{1}) && isscalar(varargin{1})
    % Format is: w = IX_dataset_nd (ndim)
    ndim=varargin{1};
    if ndim==1
        w=IX_dataset_1d;
    elseif ndim==2
        w=IX_dataset_2d;
    elseif ndim==3
        w=IX_dataset_3d;
    else
        error(['IX_dataset_nd with dimensionality n=',num2str(ndim),' is not supported'])
    end
    
% -------------------------------------------------------------------------------------------------
elseif numel(varargin)==5
    title=varargin{1};
    signal=varargin{2};
    err=varargin{3};
    s_axis=varargin{4};
    ax=varargin{5};
    % Format is: w = IX_dataset_nd (title, signal, error, s_axis, ax)
    fields = {'values';'axis';'distribution'};
    
    ndim=numel(ax);
    if ~(isstruct(ax) && isequal(fieldnames(ax),fields))
        error('axis description does not have correct fields')
    end
    
    if ndim==1
        w=IX_dataset_1d (title, signal, err, s_axis, ax(1).values, ax(1).axis, ax(1).distribution);
    elseif ndim==2
        w=IX_dataset_2d (title, signal, err, s_axis, ax(1).values, ax(1).axis, ax(1).distribution,...
            ax(2).values, ax(2).axis, ax(2).distribution);
    elseif ndim==3
        w=IX_dataset_3d (title, signal, err, s_axis, ax(1).values, ax(1).axis, ax(1).distribution,...
            ax(2).values, ax(2).axis, ax(2).distribution,...
            ax(3).values, ax(3).axis, ax(3).distribution);
    else
        error(['IX_dataset_nd with dimensionality n=',num2str(ndim),' is not supported'])
    end
    
% -------------------------------------------------------------------------------------------------
else
    error('Check number and type of input arguments')
end
