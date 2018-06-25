function [ok,mess,varargout]=parse_char_options(args,options)
% Check which optional keywords are present or not. Assumes that second character is unique
%
%   >> [ok,mess,varargout]=parse_char_options(args,options)
%
% Input:
% ------
%   args        Cell array of inputs to analyse, containing all or distinctive
%               parts of acceptable options.
%   options     Cell array of acceptable options which may or may not be present within
%               args.
%
% Output:
% -------
%   ok          True if all options are valid, and appear at most once
%   mess        If ok==true: empty; if ok==false: error message
%   varargout   List of arguments, one per valid option, that will be filled
%               with true or false according to the presence or absence of the
%               corresponding member of the valid options list.
%   arg_left    if such variable is present, it contains cellarray of the
%               arguments which are not found among the options.
%
% E.G.
%   >> options = {'-full','-enable','-revert','-parallel'};
%   >> [ok,mess,ok_f,ok_e,ok_r,ok_p]=parse_char_options({'-rev','-full'},options)
% where ok_r and ok_f will be true because '-full' and '-revert' options
% are present among input arguments and ok_e and ok_p are false as these
% options are absent
%
% or:
%   >>[ok,mess,ok_f,ok_e,ok_r,ok_p,missing]=parse_char_options({'-rev','-full','other'},options)
%where values of ok_f,ok_e,ok_r,ok_p would be the same as before and
%the value of missing is equal to {'other'} as key 'other' is not among the
% cellarray of existing options.
%
% Accepts partial keywords, e.g. the recognized input keyword can be minimally
% different from other possible options. In the example above, inputs may
% be defined by one letter (i.e. '-f','-e','-r','-p')

% Author: T.G.Perring 15 Nov 2013
%
% $Revision$ ($Date$)
%
if iscell(args)
    narg=numel(args);
else
    narg=1;
    args={args};
end
nopt=numel(options);
%nargoutchk(nopt+2,nopt+3,nargout)
if nargout<nopt+2 || nargout>nopt+3
    ok=false;
    mess = 'function parse_char_options called with invalid number of output arguments';
    return
end
return_remaining = false;
nouts = nopt;
if nargout == nopt+3
    nouts = nopt+1;
    return_remaining=true;
end

if return_remaining
    remaining_args=logical(zeros(narg,1));
end
varargout = cell(nouts,1);
varargout = cellfun(@(x){false},varargout);
for i=1:narg
    if ischar(args{i}) && size(args{i},1)==1 && ~isempty(args{i})
        ind=find(strncmpi(args{i},options,numel(args{i})));
        if numel(ind)==1
            if ~varargout{ind}
                varargout{ind}=true;
            else
                ok=false; mess=['Input key: ''',options{ind},''' appears at least twice in the argument list'];
                return
            end
        elseif numel(ind)==0
            if return_remaining
                remaining_args(i)=true;
            else
                ok=false; mess=['Invalid input key: ''',args{i},''''];
                return
            end
        else
            ok=false; mess=['Input key: ''',args{i},''' is an ambiguous abbreviation of at least two valid options'];
            return
        end
    else
        if return_remaining
            remaining_args(i)=true;
        else
            ok=false; mess='Only string input options are allowed';
            return
        end
    end
end
ok=true;
mess='';
if return_remaining
    varargout{nouts} = args(remaining_args);
end

