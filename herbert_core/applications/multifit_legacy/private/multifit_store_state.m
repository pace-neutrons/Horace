function varargout=multifit_store_state (varargin)
% Get the multifit status and get or set the most recently set index and type of function evaluation request
%
%   >> multifit_store_state     % Clean up
%
%   >> multifit_store_state (isfitting,index,foreground,store_calcs)    % Set values
%
%   >> [isfitting,index,foreground,store_calcs] = multifit_store_state  % Fetch current values
%
% Input:
% ------
%   isfitting       Logical flag:
%                      =true  if in multifit least squares fitting function
%                      =false if in multifit, but not in the least squares algorithm
%   index           Index of current dataset
%   foreground      Logical flag:
%                       =true  if foreground function
%                       =false if background function
%   store_calcs     Logical flag:
%                       =true  if computed values of the function are being stored
%                       =false if computed values are not being saved
%                   This is equivalent to partial derivatives not being evaluated
%                  if true, or they are being evaluated if false.
%
% Output:
% -------
%   isfitting   -|
%   index        |- Current status. Empty if not in multifit
%   foreground   |
%   store_calcs -|
%
%
% This function is only for internal use in multifit, except where values can be retrived
% through a public interface. It is assumed that i/o is valid.

persistent isfitting index_store foreground_store store_calcs

if nargout>0        % Fetch current values
    if ~(isempty(isfitting)||isempty(index_store)||isempty(foreground_store)||isempty(store_calcs))
        % All are non-empty, so valid to retrieve
        varargout{1}=isfitting;
        if nargout>=2, varargout{2}=index_store; end
        if nargout>=3, varargout{3}=foreground_store; end
        if nargout>=4, varargout{4}=store_calcs; end
    elseif isempty(isfitting)&&isempty(index_store)&&isempty(foreground_store)&&isempty(store_calcs)
        % All are empty, so in cleanup state; return all output as empty
        varargout{1}=[];
        if nargout>=2, varargout{2}=[]; end
        if nargout>=3, varargout{3}=[]; end
        if nargout>=4, varargout{4}=[]; end
    else
        error('Logic problem: invalid status in multifit - please see T.G.Perring')
    end
    
elseif nargin==0    % Cleanup and return if requested
    isfitting=[];
    index_store=[];
    foreground_store=[];
    store_calcs=[];

elseif nargin==4    % Set values. No checks on validity, as assumed OK (thi is a private function)
    isfitting=varargin{1};
    index_store=varargin{2};
    foreground_store=varargin{3};
    store_calcs=varargin{4};
    
else
    error('Logic problem: incorrect use of this function - please inform T.G.Perring')
    
end
