function wout= user_func(win,func_handle,varargin)
% This function allows for a user defined function to be applied to
% 2-dimensional dataset.
%
% Syntax:
%   >> wout= ufun (win, @func, arg1, arg1,....);
%
% Input:
% ------
%   win             Input dataset 
%
%   funfcn          User supplied function that is applied to win
%
%   arg1            input arguments that need to be passed to the user
%   arg2            defined function these get passed on as a cell array
%    :
%
% Output:
% -------
%   wout            Output dataset
%
% The following data are passed to the user defined function:
%   win, arg1, arg2....
%
% The user is allowed to only return the following fields from his/her
% function:
%   dout.s, dout.e, dout.title

% Original author: J. van Duijn
%
% $Revision$ ($Date$)
%
% Horace v0.1   J. van Duijn, T.G.Perring

if nargin==1
    wout = win; % trivial case of no user function being provided
else
    wout = dnd_create(dnd_user_func(get(win),func_handle, varargin{:}));
end