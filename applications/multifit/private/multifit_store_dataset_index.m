function varargout=multifit_store_dataset_index (varargin)
% Get or set the most recently set index and type of function evaluation request
%
%   >> multifit_store_dataset_index     % Clean up
%
%   >> multifit_store_dataset_index (index,foreground,store_calcs)    % Set values
%
%   >> [isfitting,index,foreground,store_calcs] = multifit_store_dataset_index  % Fetch current values
%
% Input:
% ------
%   index           Index of function 
%   foreground      Logical flag:
%                       =true  if foreground function
%                       =false if background function
%   store_calcs     Logical flag:
%                       =true  if computed values of the function are being stored
%                       =false if computed values are not being saved
%                   This is equivalent to partial derivatives not being evaluated
%                  if true, or they are being evaluated if false.
%
% Input:
% ------
%   isfitting       Logical flag:
%                      =true  if in multifit least squares fitting function
%                      =false if not
%   index       -|
%   foreground   |- Current status. Empty if not isfitting
%   store_calcs -|
%
%
% This function is only for internal use in multifit, except where values can be retrived
% through a public interface.

persistent index_store foreground_store store_calcs

if nargout>0        % Fetch current values
    if ~(isempty(index_store)||isempty(foreground_store)||isempty(store_calcs))
        varargout{1}=true;
        if nargout>=2, varargout{2}=index_store; end
        if nargout>=3, varargout{3}=foreground_store; end
        if nargout>=4, varargout{4}=store_calcs; end
    elseif isempty(index_store)&&isempty(foreground_store)&&isempty(store_calcs)
        varargout{1}=false;
        if nargout>=2, varargout{2}=[]; end
        if nargout>=3, varargout{3}=[]; end
        if nargout>=4, varargout{4}=[]; end
    else
        error('Logic problem: invalid status in multifit - please see T.G.Perring')
    end
    
elseif nargin==0    % Cleanup and return if requested
    index_store=[];
    foreground_store=[];
    store_calcs=[];

elseif nargin==3    % Set values
    index_store=varargin{1};
    foreground_store=varargin{2};
    store_calcs=varargin{3};
    
else
    error('Logic problem: incorrect use of this function - please inform T.G.Perring')
    
end
