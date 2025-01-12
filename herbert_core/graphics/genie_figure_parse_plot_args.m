function [args,lims,fig_out]=genie_figure_parse_plot_args(opt,varargin)
% Parse the input arguments for the various different plot functions
%
%   >> [args,lims_type,fig_out] = genie_figure_parse_plot_args...
%                                   (opt,p1,p2,...)
%
% Input:
% ------
%   opt         Structure with fields giving options
%                   newplot     true or false
%                   over_curr       true or false
%                                   Only applies when newplot==false
%                default_name   Default plot window name if none given
%                                   Only applies if 'draw' or 'plot'
%                                   If not given, set to []
%                   lims_type   Limits type: 'xy' or 'xyz'
%                                   Only applies if 'draw'
%
%   p1,p2,...   Arguments: pairs of limits, or 'name',namestr
%
% Output:
% -------
%   args        Cell array with arguments as row vector (cell(1,0) if not OK)
%              suitable for passing down to another plot function e.g.
%              sqw/dl  calls IX_dataset_1d/dl.
%   lims        Cell array (row vector) of limits
%   fig_out     Figure name or figure handle


newplot=opt.newplot;
if ~newplot
    if isfield(opt,'over_curr') && islognumscalar(opt.over_curr)
        over_curr=logical(opt.over_curr);
    else
        over_curr=false;
    end
end

if newplot || ~over_curr
    if isfield(opt,'default_name')
        default_name=opt.default_name;
    else
        default_name=[];
    end

    % Parse input
    name_struct_default.name=default_name;
    [lims,name_struct,present,filled,ok,mess]=parse_arguments(varargin,name_struct_default);
    if ~ok, error('HERBERT:graphics:invalid_argument',mess); end

    % Check name is valid
    [fig_out,ok,mess]=genie_figure_target(name_struct.name,newplot,default_name);
    if ~ok, error('HERBERT:graphics:invalid_argument',mess); end

    % Check limits are valid (if any are permitted)
    if newplot
        lims_type=opt.lims_type;
        [ok,mess] = plot_limits_valid (lims_type, lims{:});
        if ~ok, error('HERBERT:graphics:invalid_argument',mess); end
    else
        % No limits can be given if overplotting
        if numel(lims)~=0
            if ~ok, error('HERBERT:graphics:invalid_argument', ...
                    'No limits can be given if overplotting requested'); end
        end
    end
    args=[lims,struct2namval(name_struct)];
else
    % Check there is a current figure
    if isempty(findobj(0,'Type','figure'))
        error('HERBERT:graphics:invalid_argument', ...
            'No current figure exists - cannot overplot');
    end
    fig_out=gcf;

    % Check there are no parameters
    if numel(varargin)>0
        error('HERBERT:graphics:invalid_argument', ...
            'Check the input parameters');
    end

    args=cell(1,0);
    lims=cell(1,0);
end
