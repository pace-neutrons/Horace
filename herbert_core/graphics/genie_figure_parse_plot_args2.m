function [args,nw,lims,fig_out]=genie_figure_parse_plot_args2(opt,varargin)
% Parse the input arguments for the various different plot functions
%
%   >> [args,ok,mess,nw,lims_type,fig_out] = genie_figure_parse_plot_args...
%                                   (opt,w[,wc],arg1,arg2,...)
%
% Input:
% ------
%   opt         Structure with fields giving options
%                   newplot     true or false
%                   over_curr   true or false
%                                   only applies when newplot==false
%                default_name   Default plot window name if none given
%                                   only applies if 'draw' or 'plot'
%                   lims_type   Limits type: 'xy' or 'xyz'
%                                   only applies if 'draw'
%
%   w           Data object (or arrayof objects) to plot
%
%   wc          [optional] second data object or array of objects to plot.
%              Alternatively, it can be a numeric array.
%               Its presence is deduced from the number and type of input
%              arguments.
%               Both w and wc must have a method called sigvar which
%              returns the signal and error arrays in a sigvar object;
%              checks on the dimensionality and sizes of the signal arrays
%               - If w is an array of objects, then wc must contain
%                 the same number of objects.
%               - If wc is a numeric array then w must be a scalar
%                 object.
%
%   p1,p2,...   Arguments: pairs or limits, or 'name',namestr
%
% Output:
% -------
%   args        Cell array with arguments as row vector (cell(1,0) if not OK)
%              suitable for passing down to another plot function e.g.
%              sqw/dl  calls IX_dataset_1d/dl.
%   ok          true if arguments are acceptable
%   mess        Error message if not ok; empty string if ok
%   lims_type   Cell array (row vector) or limits
%   fig_out     Figure name


% Must have at least w, and it cannot be a numeric array
if numel(varargin)==0
    error('HERBERT:graphics:invalid_argument', ...
        'Insufficient number of input arguments');
elseif isnumeric(varargin{1})
    error('HERBERT:graphics:invalid_argument', ...
        'First plot item must be an object - cannot be a numeric array');
end

% Determine if just w, or w and wc as input:
w=varargin{1};
nw=1;
try
    [args,lims,fig_out]=genie_figure_parse_plot_args(opt,varargin{2:end});
catch ME
    if ~strcmp(ME.identifier,'HERBERT:graphics:invalid_argument')
        rethrow(ME);
    end
    if numel(varargin)>=2 && (ismethod(varargin{2},'sigvar') || isnumeric(varargin{2}))
        wc=varargin{2};
        [args,lims,fig_out]=genie_figure_parse_plot_args(opt,varargin{3:end});
        nw=2;
    else
        rethrow(ME);
    end
end

% Check signal dimensions are compatible if both w and wc are given
if nw==2
    if ~isnumeric(wc)
        if numel(w)==numel(wc)
            for i=1:numel(w)
                tmp=sigvar(w(i));   sz=size(tmp.s);   clear tmp;
                tmpc=sigvar(wc(i)); szc=size(tmpc.s); clear tmpc;
                if ~(numel(sz)==numel(szc) && all(sz==szc))
                    error('HERBERT:graphics:invalid_argument', ...
                        'The signal arrays of corresponding pairs of datasets do not have the same size');
                end
            end
        else
            error('HERBERT:graphics:invalid_argument', ...
                'The number of datasets must be the same in the two arrays of datasets to be plotted');
        end
    else
        if numel(w)==1
            tmp=sigvar(w); sz=size(tmp.s); clear tmp;
            szc=size(wc);
            if ~(numel(sz)==numel(szc) && all(sz==szc))
                mess='The signal array size of the dataset does not match the size of the numeric array';
                if isscalar(wc) && strcmpi(opt.plot_type,'draw')
                    mess=['Check number of limits *OR* ',mess];     % common problem is one too many limits
                end
                error('HERBERT:graphics:invalid_argument', mess);
            end
        else
            error('HERBERT:graphics:invalid_argument',...
                'The dataset to plot must be a scalar array if the second plot argument is a numeric array');
        end
    end
end
