function hor_plotaxes(handles)
%
% Function to deal with adjusting the plot axis limits by reading
% information from the GUI window.
%
% R.A. Ewings 12/11/2008
%

%Read limits from window:
LoLim1=get(handles.PlotAx1_lo_edit,'String');
HiLim1=get(handles.PlotAx1_hi_edit,'String');
LoLim2=get(handles.PlotAx2_lo_edit,'String');
HiLim2=get(handles.PlotAx2_hi_edit,'String');
LoLim3=get(handles.PlotAx3_lo_edit,'String');
HiLim3=get(handles.PlotAx3_hi_edit,'String');
Axlabel1=get(handles.PlotAxis1_edit,'String');
Axlabel2=get(handles.PlotAxis2_edit,'String');
Axlabel3=get(handles.PlotAxis3_edit,'String');
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
if isfield(handles,'linlog3')
    linlog3=handles.linlog3;
else
    linlog3='Linear';%default
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
elseif strcmp(linlog1,'Log')
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
elseif strcmp(linlog2,'Log')
    logy;    
end

if ~isempty(LoLim3) && ~isempty(HiLim3)
    lonum3=str2double(LoLim3);
    hinum3=str2double(HiLim3);
    if (hinum3>lonum3) && strcmp(linlog3,'Linear'); 
        lz lonum3 hinum3
    elseif (hinum3>lonum3) && strcmp(linlog3,'Log');
        lz lonum3 hinum3
        disp('Plotting with linear scale - log colour scale not possible with MGenie graphics');
    else
        disp('ERROR: Axis 3 - upper limit must be larger than lower limit');
    end
elseif strcmp(linlog3,'Linear')
    linz;
elseif strcmp(linlog3,'Log')
    logz;    
end

%=======================
%Now put on the new labels, if specified.
if ~isempty(Axlabel1) && strcmp(get(handles.PlotAxis1_edit,'Visible'),'on');
    xlabel(get(handles.PlotAxis1_edit,'String'));
end
if ~isempty(Axlabel2) && strcmp(get(handles.PlotAxis2_edit,'Visible'),'on');
    ylabel(get(handles.PlotAxis2_edit,'String'));
end
if ~isempty(Axlabel3) && strcmp(get(handles.PlotAxis3_edit,'Visible'),'on');
    zlabel(get(handles.PlotAxis3_edit,'String'));
end

