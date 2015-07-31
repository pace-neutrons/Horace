function varargout=graph_range(fig_handle,opt)
% Get the limits on x,y,z,c for current figure or named figure
%
%   >> [range,subrange]=graph_range(fig_handle)
%   >> [range,subrange]=graph_range(fig_handle,'evaluate')
%   >> present=graph_range(fig_handle,'present')
%
% Input:
% ------
%   fig_handle  Figure handle
%
%   opt         Option:
%               'evaluate'  Evaluate full range of data [Default]
%               'present'   Determine only if ZData and CData are present
%
% Output:
% -------
%   range       Structure with fields:
%       x   [x(1),x(2)]: full range along x axis of all the data
%       y   [y(1),y(2)]: full range along y axis of all the data
%       z   If present: [z(1),z(2)]: full range along z axis of all the data.
%           If no z data: []
%       c   If present: [c(1),c(2)]: full range along c axis of all the data
%           If no c data: []
%
%               If opt=='present', then all fields are set to []
%
%   subrange    Structure with fields:
%       y   [y(1),y(2)]: range along y axis within the current x-axis plot limits
%       z   If present: [z(1),z(2)]: range along z axis within the current
%                       x-axis and y-axis plot limits
%           If no z data: []
%
%               If opt=='present', then all fields are set to []
%
%   present     Structure with fields:
%       z   ZData present
%       c   CData present


% Check arguments
if ~exist('opt','var') || strcmp(opt,'evaluate')
    evaluate=true;
elseif strcmp(opt,'present')
    evaluate=false;
else
    error('Unrecognised option')
end

if (evaluate && nargout>2) || (~evaluate && nargout>1)
    error('Check number of output arguments')
end

% Get plot handles
[fig_h, axes_h, plot_h, plot_type] = genie_figure_all_handles (fig_handle);

% Now get data ranges
if evaluate
    xlim=get(axes_h,'XLim');
    ylim=get(axes_h,'YLim');
    xlo = Inf; xhi = -Inf;
    ylo = Inf; yhi = -Inf;
    zlo = Inf; zhi = -Inf;
    clo = Inf; chi = -Inf;
    ymin = Inf; ymax = -Inf;
    zmin = Inf; zmax = -Inf;
end

zpresent=false;
cpresent=false;
for i=1:numel(plot_h)
    
    % Get x and y limits
    if evaluate
        % Get x and y full range
        xdata = get(plot_h(i),'XData');
        ydata = get(plot_h(i),'YData');
        xlo = min(min(xdata(:)),xlo);
        xhi = max(max(xdata(:)),xhi);
        ylo = min(min(ydata(:)),ylo);
        yhi = max(max(ydata(:)),yhi);
        
        % Get y limits in the present x-range
        ok_x = xdata>=xlim(1) & xdata<=xlim(2);
        ymin = min(min(ydata(ok_x)),ymin);
        ymax = max(max(ydata(ok_x)),ymax);
    end
    
    % Get z and c limits
    if ~strcmp(plot_type{i},'line') && isprop(plot_h(i),'ZData')
        zdata = get(plot_h(i),'ZData');
        if ~isempty(zdata)
            zpresent=true;
            if evaluate
                % Get z full range
                zlo = min(min(zdata(:)),zlo);
                zhi = max(max(zdata(:)),zhi);
                
                % Get z limits in the present x-range and y-range
                ok_y = ydata>=ylim(1) & ydata<=ylim(2);
                zmin = min(min(zdata(ok_x&ok_y)),zmin);
                zmax = max(max(zdata(ok_x&ok_y)),zmax);
            end
        end
    end
    
    if isprop(plot_h(i),'CData')
        cdata = get(plot_h(i),'CData');
        if ~isempty(cdata)
            cpresent=true;
            if evaluate
                clo = min(min(cdata(:)),clo);
                chi = max(max(cdata(:)),chi);
                % Would also like to find min and max of cdata in the current x,y range,
                % but the interpretation of cdata is fairly sophisticated depending on
                % the call to patch, surface and other plotting routines. We ignore the
                % problem for the time-being
            end
        end
    end
end

% Fill output
if evaluate
    range.x=[xlo,xhi];
    range.y=[ylo,yhi];
    subrange.y=[ymin,ymax];
    if zpresent
        range.z=[zlo,zhi];
        subrange.z=[zmin,zmax];
    else
        range.z=[];
        subrange.z=[];
    end
    if cpresent
        range.c=[clo,chi];
    else
        range.c=[];
    end
    % Fill varargout
    if nargout>=1, varargout{1}=range; end
    if nargout>=2, varargout{2}=subrange; end
else
    present.z=zpresent;
    present.c=cpresent;
    % Fill varargout
    if nargout>=1, varargout{1}=present; end
end
