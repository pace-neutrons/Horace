function [args,ok,mess,nw,lims,fig_out]=genie_figure_parse_plot_args2(opt,varargin)
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
    [args,ok,mess,nw,lims,fig_out]=error_return('Insufficient number of input arguments');
    return
elseif isnumeric(varargin{1})
    [args,ok,mess,nw,lims,fig_out]=error_return('First plot item must be an object - cannot be a numeric array');
    return
end

% Determine if just w, or w and wc as input:
w=varargin{1};
nw=1;
[args,ok1,mess1,lims,fig_out]=genie_figure_parse_plot_args(opt,varargin{2:end});
if ~ok1
    if numel(varargin)>=2 && (ismethod(varargin{2},'sigvar') || isnumeric(varargin{2}))
        wc=varargin{2};
        [args,ok2,mess2,lims,fig_out]=genie_figure_parse_plot_args(opt,varargin{3:end});
        if ~ok2
            if strcmpi(mess1,mess2) % same error picked up in both caes
                [args,ok,mess,nw,lims,fig_out]=error_return(mess1);
            else
                [args,ok,mess,nw,lims,fig_out]=error_return([mess1,' *OR* ',mess2]);
            end
            return
        end
        nw=2;
    else
        [args,ok,mess,nw,lims,fig_out]=error_return(mess1);
        return
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
                    [args,ok,mess,nw,lims,fig_out]=error_return...
                        ('The signal arrays of corresponding pairs of datasets do not have the same size');
                    return
                end
            end
        else
            [args,ok,mess,nw,lims,fig_out]=error_return...
                ('The number of datasets must be the same in the two arrays of datasets to be plotted');
            return
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
                [args,ok,mess,nw,lims,fig_out]=error_return(mess);
                return
            end
        else
            [args,ok,mess,nw,lims,fig_out]=error_return...
                ('The dataset to plot must be a scalar array if the second plot argument is a numeric array');
            return
        end
    end
end

% OK if got here
ok=true;
mess='';


%--------------------------------------------------------------------------------------------------
function [args,ok,mess,nw,lims,fig_out]=error_return(mess)
% Standard return arguments

args=cell(1,0);
ok=false;
nw=0;
lims=cell(1,0);
fig_out=empty_default_graphics_object();
