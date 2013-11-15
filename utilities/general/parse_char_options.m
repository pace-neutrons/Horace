function [ok,mess,varargout]=parse_char_options(args,options)
% Check which optional keywords are present or not. Assumes that second character is unique
%
%   >> [ok,mess,varargout]=parse_char_options(args,options)
%
% Input:
% ------
%   args        Cell array of options (all must be non-empty character strings)
%   options     Cell array of valid options
%
% Output:
% -------
%   ok          True if all options are valid, and appear at most once
%   mess        If ok==true: empty; if ok==false: error message
%   varargout   List of arguments, one per valid option, that will be filled
%              with true or false according to the presence or absence of the
%              corresponding memebr of the valid options list.
%
% E.G.
%   >> options = {'-full','-enable','-revert','-parallel'};
%   >> [ok,mess,ok_f,ok_e,ok_r,ok_p]=parse_char_options({'-rev','-full',options)

% Author: T.G.Perring 15 Nov 2013

if iscell(args)
    narg=numel(args);
else
    narg=1;
    args={args};
end
nopt=numel(options);
nargoutchk(nopt+2,nopt+2)

for i=1:nopt
    varargout{i}=false;
end

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
            ok=false; mess=['Invalid input key: ''',args{i},''''];
            return
        else
            ok=false; mess=['Input key: ''',args{i},''' is an ambiguous abbreviation of at least two valid options'];
            return
        end
    else
        ok=false; mess='Only string input options are allowed';
        return
    end
end
ok=true;
mess='';
