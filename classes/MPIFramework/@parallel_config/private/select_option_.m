function the_opt = select_option_(opt,arg)
% Select slingle valid option from the list of available options
if isnumeric(arg)
    if arg<0 || arg>numel(opt)
        error('PARALLEL_CONFIG:invalid_argument',...
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
    error('PARALLEL_CONFIG:invalid_argument',...
        'The selected framework should be defined by the name of the framework or its number in the framework list');
end
ind=find(strncmpi(arg,opt,numel(arg)));
if isempty(ind)
    strarg = cellfun(@(x)([x,'; ']),opt,'UniformOutput',false);
    strarg = [strarg{1:end-1}];
    error('PARALLEL_CONFIG:invalid_argument',...
        ['Unknown option: %s. ',...
        'Only options: %s and %s',...
        '  are currently accepted'],...
        arg,strarg,opt{end});
    
elseif numel(ind)>1
    strarg = cellfun(@(x)([x,'; ']),opt(ind),'UniformOutput',false);
    strarg = [strarg{1:end-1}];
    error('PARALLEL_CONFIG:invalid_argument',...
        'Input name: %s is an ambiguous abbreviation of at least two valid framework names: %s',...
        arg,strarg);
else
    the_opt = opt{ind};
end
