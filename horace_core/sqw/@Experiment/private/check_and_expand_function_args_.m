function [argout,npars]=check_and_expand_function_args_(varargin)
% Check arguments have one of the permitted forms below
%
%   >> argout=check_and_expand_function_args(arg1,arg2,...)
%
% Input:
% ------
%   arg1,arg2,...  Input arguments
%                  Each argument can be a 2D array with 0,1 or more rows
%                  If more than one row in an argument, then this gives the
%                  number of argument sets.
%
% Output:
% -------
%   ok              =true all OK; =false otherwise
%   mess            Error message if not OK; empty string if OK
%   argout          Cell array of arguments, each row a cell array
%                  with the input arguments
%
% Checks arguments have one of following forms:
%	- scalar, row vector (which can be numerical, logical,
%     structure, cell array or object), or character string
%
%   - Multiple arguments can be passed, one for each run that
%     constitutes the sqw object, by having one row per run
%   	i.e
%       	scalar      ---->   column vector (nrun elements)
%           row vector  ---->   2D array (nrun rows)
%        	string      ---->   cell array of strings
%
% Throws if not valid form

narg=numel(varargin);


% Find out how many rows, and check consistency
nr=zeros(1,narg);
nc=zeros(1,narg);
for i=1:narg
    if numel(size(varargin{i}))==2
        nr(i)=size(varargin{i},1);
        nc(i)=size(varargin{i},2);
    else
        error('HORACE:sqw:invalid_argument', ...
            'Check arguments have valid array size');

    end
end
if all(nr==max(nr)|nr<=1)
    nrow=max(nr);
else
    error('HORACE:sqw:invalid_argument', ...
        'If any arguments have more than one row, all such arguments must be the same number of rows');

end
npars = max(nr);

% Now create cell arrays of output arguments
if nrow>1
    argout=cell(nrow,narg);
    for i=1:narg
        if ~iscell(varargin{i})
            if nr(i)==nrow
                argout(:,i)=mat2cell(varargin{i},ones(1,nrow),size(varargin{i},2));
            else
                argout(:,i)=repmat(varargin(i),nrow,1);
            end
        else
            if nr(i)==nrow
                if nc(i)>1
                    argout(:,i)=mat2cell(varargin{i},ones(1,nrow),size(varargin{i},2));
                else
                    argout(:,i)=varargin{i};
                end
            else
                argout(:,i)=repmat(varargin(i),nrow,1);
            end
        end
    end
else
    argout=varargin;
end
