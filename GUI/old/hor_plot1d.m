function hor_plot1d(handles_in)
%
% Function to deal with the various options for 1d plotting.
%
% R.A. Ewings 12/11/2008
%

%Smoothing issues have already been dealt with, so we need only consider
%the axes and the plot style.

%Get the object to plot:
if isfield(handles_in,'w_out')
    w_out=handles_in.w_out;
else
    disp('ERROR: no object selected');
end

%====
%Set the plot defaults:
amark('o');
acolor('red');
aline('-');

%===================================================
%Now work out the plot style:

if isfield(handles_in,'marker') && ~strcmp(handles_in.marker,'none')
    marker=handles_in.marker(1);
elseif isfield(handles_in,'marker') && strcmp(handles_in.marker,'none')
    marker='none';
else
    marker='o';%default
end

if isfield(handles_in,'marker_colour')
    marker_colour=handles_in.marker_colour;
else
    marker_colour='black';%default
end

if isfield(handles_in,'line') && ~strcmp(handles_in.line,'none')
    line=strtrim(handles_in.line(1:2));
elseif isfield(handles_in,'line') && strcmp(handles_in.line,'none')
    line='none';
else
    line='-';%default
end

if isfield(handles_in,'errorbar_choice')
    errorbar_choice=handles_in.errorbar_choice(1);%'y' or 'n'
else
    errorbar_choice='y';%default
end

%=============================================

if strcmp(errorbar_choice,'y') && ~strcmp(marker,'none') && ~strcmp(line,'none')
    amark(marker);
    acolor(marker_colour);
    aline(line);
    dp(w_out);
    pl(w_out);
elseif strcmp(errorbar_choice,'y') && strcmp(marker,'none') && ~strcmp(line,'none')
    acolor(marker_colour);
    aline(line);
    de(w_out);
    pl(w_out);
elseif strcmp(errorbar_choice,'n') && ~strcmp(marker,'none') && ~strcmp(line,'none')
    amark(marker);
    acolor(marker_colour);
    aline(line);
    dl(w_out);
    pm(w_out);
elseif strcmp(errorbar_choice,'n') && strcmp(marker,'none') && ~strcmp(line,'none')
    acolor(marker_colour);
    aline(line);
    dl(w_out);
elseif strcmp(errorbar_choice,'y') && ~strcmp(marker,'none') && strcmp(line,'none')
    amark(marker);
    acolor(marker_colour);
    dm(w_out);
    pe(w_out);
elseif strcmp(errorbar_choice,'y') && strcmp(marker,'none') && strcmp(line,'none')
    acolor(marker_colour);
    de(w_out);
elseif strcmp(errorbar_choice,'n') && ~strcmp(marker,'none') && strcmp(line,'none')
    amark(marker);
    acolor(marker_colour);
    dm(w_out);
elseif strcmp(errorbar_choice,'n') && strcmp(marker,'none') && strcmp(line,'none')
    disp('ERROR: no marker, no line, and no errorbar = no plot!');
    set(handles.Working_text,'BackgroundColor','r');
    set(handles.Working_text,'String',{'Status :';'Error'});
    guidata(gcbo,handles);
    return;
end












