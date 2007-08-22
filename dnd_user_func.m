function dout= dnd_user_func(din,func_handle,varargin)
% This function allows for a user defined function to be applied to the
% data.
%
% Syntax:
%   >> dout= dnd_user_fun (din, @func, arg1, arg2,....);
%
% Input:
% ------
%   din             Input dataset that needs to be manipulated 
%                   Type >> help dnd_checkfields for a full description of
%                   the fields
%
%   funfcn          User supplied function that is applied to din
%
%   arg1            input arguments that need to be passed to the user
%   arg2            defined function these get passed on as a cell array
%    :
%
% Output:
% -------
%   dout            Output dataset. Its elements are the same as those of din,
%                  appropriately updated.
%
% The following data fields are passed to the user defined function:
%   din, arg1, arg2, ....
%
% The user is allowed to only return the following fields from his/her
% function:
%   dout.s, dout.e, dout.title
% These values have to be returned in a single structure. 
%
% e.g.
%   >> wout= user_func(w,@scale, scale, new_title)
%
%   Where the function scale appears on the matlab path
%       function dout= scale(din, scale, title_new)
%       dout.s= din.s*scale;
%       dout.e= din.e*scale;
%       dout.title= [din.title,title_new];

% Original author: J. van Duijn
%
% $Revision$ ($Date$)
%
% Horace v0.1   J. van Duijn, T.G.Perring

dout=din;   % makes sure that the output data structure is the same as the input one
if nargin==1    % trivial case - no manipulation of data, so return
    return
end

%construct the function line
str= 'func_handle(din';

n= nargin-2;
if n>0  %optional arguments were passed
    for i=1:n
        str= [str,[',varargin{',num2str(i),'}']];
    end
    command= [str,');'];
else
    command= [str,');'];
end

% evaluate the function
dfunc=eval(command); % the only valid return fields are dtemp.s, dtemp.e and/or dtemp.title

% Check the out put and update the relevant fields in dout.
if ~isstruct(dfunc) || length(dfunc)>1
    error('ERROR: you are only allowed to return a single structure array');
end

names=fieldnames(dfunc);
n='';
for i=1:length(names)
    if strcmp(names{i},'s')
        dout.s= dfunc.s;
        n=[n,i];
    elseif strcmp(names{i},'e')
        dout.e= dfunc.e;
        n=[n,i];
    elseif strcmp(names{i},'title')
        dout.title= dfunc.title;
        n=[n,i];
    end
end

if length(n)<length(names)
    error(['ERROR: not all of the return fields have been assigned,',...
        'remember you are only allowed to return dout.s and/or dout.e',...
        ' and/or dout.title']);
end
