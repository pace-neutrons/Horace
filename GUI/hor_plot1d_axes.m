function hor_plot1d_axes(handles)
%
% Adjust the axes of a 1d plot.
%
% R.A. Ewings 12/11/2008

%Read limits from window:
LoLim1=get(handles.PlotAx1_lo_edit,'String');
HiLim1=get(handles.PlotAx1_hi_edit,'String');
LoLim2=get(handles.PlotAx2_lo_edit,'String');
HiLim2=get(handles.PlotAx2_hi_edit,'String');
%
%Read lin/log scale from window:
if isfield(handles,'linlog1')
    linlog1=handles.linlog1;
else
    linlog1='Linear';%default
end
if isfield(handles,'linlog2')
    linlog2=handles.linlog2;
else
    linlog2='Linear';%default
end
%

if ~isempty(LoLim1) && ~isempty(HiLim1)
    lonum1=str2double(LoLim1);
    hinum1=str2double(HiLim1);
    if (hinum1>lonum1) && strcmp(linlog1,'Linear')
        linx;
        lx lonum1 hinum1
    elseif (hinum1>lonum1) && strcmp(linlog1,'Log')
        logx;
        lx lonum1 hinum1
    else
        disp('ERROR: Axis 1 - upper limit must be larger than lower limit');
    end
elseif strcmp(linlog1,'Linear')
    linx;
else
    strcmp(linlog1,'Log')
    logx;
end

if ~isempty(LoLim2) && ~isempty(HiLim2)
    lonum2=str2double(LoLim2);
    hinum2=str2double(HiLim2);
    if (hinum2>lonum2) && strcmp(linlog2,'Linear')
        liny;
        ly lonum2 hinum2
    elseif (hinum2>lonum2) && strcmp(linlog2,'Log')
        logy;
        ly lonum2 hinum2
    else
        disp('ERROR: Axis 2 - upper limit must be larger than lower limit');
    end
elseif strcmp(linlog2,'Linear')
    liny;
else
    strcmp(linlog2,'Log')
    logy;
end

Axlabel1=get(handles.PlotAxis1_edit,'String');
Axlabel2=get(handles.PlotAxis2_edit,'String');

if ~isempty(Axlabel1) && strcmp(get(handles.PlotAxis1_edit,'Visible'),'on');
    xlabel(get(handles.PlotAxis1_edit,'String'));
end
if ~isempty(Axlabel2) && strcmp(get(handles.PlotAxis2_edit,'Visible'),'on');
    ylabel(get(handles.PlotAxis2_edit,'String'));
end
