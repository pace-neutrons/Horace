function argout = parse_arguments_strip_args(pars,opt,keywords)
% Strip out keyword arguments and their values from an argument list.
%
%   >> argout = parse_arguments_strip_args(pars,opt,keywords)
%
% Input:
% ------
%   pars        Cell array of parameters
%   opt         Structure of keywords and their values
%   keywords    Keywords to remove before repacking the arguments
%
% Output:
% -------
%   argout      Cell array of argumentns: pars, followed by keywords and
%               values fron opt, with unwanted keywords and values removed
%
% Use this function to repack arguments after a call to parse_arguments
% after filtering out some keywords. Useful when nesting two or more
% functions that want input of the form par1,par2,...key1,val1,key2,val2,...

tmp=rmfield(opt,keywords);
optcell=[fieldnames(tmp),struct2cell(tmp)]';
argout=[pars(:)',optcell(:)'];
