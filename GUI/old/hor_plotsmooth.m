function [handles_out,is_smoothed]=hor_plotsmooth(handles_in)
%
% Function to apply appropriate smoothing to the object to be plotted
%
% R.A. Ewings 12/11/2008
%

handles_out=handles_in;%initialise the handles_out structure.
is_smoothed=false;%initialise a flag which tells us whether smoothing was done

%flags which tell us whether smoothing option is used:
smooth1exist=(get(handles_in.SmoothAx1_button,'Value')==1);
smooth2exist=(get(handles_in.SmoothAx2_button,'Value')==1);
smooth3exist=(get(handles_in.SmoothAx3_button,'Value')==1);


if ~isfield(handles_in,'smoothfunc1')
   handles_in.smoothfunc1='hat';%the default
end

if smooth1exist==1
    if isempty(get(handles_in.SmoothWid1_edit,'String'))%width 1 field not filled in
        %assume no smoothing
        set(handles_in.SmoothWid1_edit,'String','0');
    end
else
    set(handles_in.SmoothWid1_edit,'String','0');
end
if smooth2exist==1
    if isempty(get(handles_in.SmoothWid2_edit,'String'))%width 1 field not filled in
        %assume no smoothing
        set(handles_in.SmoothWid2_edit,'String','0');
    end
else
    set(handles_in.SmoothWid2_edit,'String','0');
end
if smooth3exist==1
    if isempty(get(handles_in.SmoothWid3_edit,'String'))%width 1 field not filled in
        %assume no smoothing
        set(handles_in.SmoothWid3_edit,'String','0');
    end
else
    set(handles_in.SmoothWid3_edit,'String','0');    
end

%Do the smoothing here:
w_in=handles_in.w_in;
objclass=class(w_in);

if strcmp(objclass,'d1d')
    w_out=smooth(w_in,str2double(get(handles_in.SmoothWid1_edit,'String')),handles_in.smoothfunc1);
    %note that even if smoothing was not selected this is OK, because if we
    %pass a width of 0 for the smoothing the function does nothing.
    handles_in.w_out=w_out;%updated object
elseif strcmp(objclass,'d2d')
    w_out=smooth(w_in,[str2double(get(handles_in.SmoothWid1_edit,'String')),...
        str2double(get(handles_in.SmoothWid2_edit,'String'))],...
        handles_in.smoothfunc1);
    handles_in.w_out=w_out;
elseif strcmp(objclass,'d3d')
    w_out=smooth(w_in,[str2double(get(handles_in.SmoothWid1_edit,'String')),...
        str2double(get(handles_in.SmoothWid2_edit,'String')),...
        str2double(get(handles_in.SmoothWid3_edit,'String'))],...
        handles_in.smoothfunc1);
    handles_in.w_out=w_out;
else
    handles_in.w_out=w_in;
end

handles_out=handles_in;%final output

%test the final output compared to the input. If different change the
%smoothed flag to true:
get_out=get(w_out); get_in=get(w_in);

%NB this line does not need to be changed, even with Horace Mk.2, because
%we only use the smooth on dnd objects, whose fields are essentially
%unaltered compared to the old version.
is_smoothed=isfinite(1./(sum(sum(sum(isfinite(1./(get_out.s - get_in.s)))))));






