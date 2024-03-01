function the_opt = select_option_(opt,arg)
% Select single valued option from the list of available options
% Inputs:
% opt -- cellarray of available options
% arg -- either string, which uniquely define one of the options or
%        the number, selecting the option with number.
%        Uniquely here means that the comparison of the
%        argument with all options available returns only
%        one match.
%
if isnumeric(arg)
    if arg<0 || arg>numel(opt)
        error('HERBERT:parallel_config:invalid_argument',...
            ['If the parallel framework is defined by a number, its range should be from 0 to number of known frameworks (currently %d)',...
            ' The number provided is: %d. Number 0 selects the default (first) framework'],...
            numel(opt),arg);
    end
    if arg == 0
        the_opt = opt{1};
    else
        the_opt = opt{arg};
    end
    return;
elseif ~(ischar(arg) && size(arg,1)==1 && ~isempty(arg))
    error('HERBERT:parallel_config:invalid_argument',...
        'The selected framework should be defined by the name of the framework or its number in the framework list');
end

ind=find(strncmpi(arg,opt,numel(arg)));
if isempty(ind)
    if numel(opt) == 1
        error('HERBERT:parallel_config:invalid_argument',...
            ['Unknown option: %s. ',...
            'Only possible option currently is: %s'],...
            arg,opt{1});
    else
        strarg = strjoin(opt,'; ');
        error('HERBERT:parallel_config:invalid_argument',...
            ['Unknown option: %s. ',...
            'Only possible options currently are: %s and %s'],...
            arg,strarg,opt{end});
    end
elseif numel(ind)>1
    strarg = strjoin(opt,'; ');
    error('HERBERT:parallel_config:invalid_argument',...
        'Input name: %s is an ambiguous abbreviation of at least two valid framework names: %s',...
        arg,strarg);
else
    the_opt = opt{ind};
end
