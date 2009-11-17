function handles_out=hor_plotover_1d(handles_in)
%
% Function to do overplotting for 1d spectra
%
% R.A. Ewings 24/11/2008
%

handles_out=handles_in;%initialise output so that it is the same as the input
%That way any changes we make here are not passed back to the main GUI
%functions.

%===
%this needs to be checked:
if isfield(handles_in,'figure_props')
    if ~isempty(handles_in.figure_props);
        %continue
    else
        %if no figure to overplot, do a plot:
        handles_out=hor_plotswich(handles_in);
        return;
    end
else
    %if no figure to overplot, do a plot:
    handles_out=hor_plotswich(handles_in);
    return;
end
%end of check
%====

%==========================================================
%Check various fields to work out what kind of plot to do
%==========================================================

issqw=strcmp(class(handles_in.w_in),'sqw');
if issqw==1
    [handles_in,sqw_ndims]=hor_sqwdims(handles_in);
    handles_in.w_out=handles_in.w_in;
    %the w_out variable is created in the smoothing function, however for
    %an sqw object we do not call this.
else
    sqw_ndims=NaN;
end

%determine if object to plot is 1d or not.
is1d=(strcmp(get(handles_in.PlotStyle_panel,'Visible'),'on') | sqw_ndims==1);

if is1d==0
    disp('ERROR: Cannot overplot an object that is not 1-dimensional');
    set(handles.Working_text,'BackgroundColor','r');
    set(handles.Working_text,'String',{'Status :';'Error'});
    guidata(gcbo,handles);
    return;
end

%cannot smooth an sqw object without converting it to dnd.
%in fact the smoothing options should be invisible if an sqw object has
%been selected.
if issqw==0
    [handles_in,is_smoothed]=hor_plotsmooth(handles_in);%subroutine to do the appropriate smoothing
end

%Now do the plotting:
hor_plotover_1d_doplot(handles_in);
%
hor_plot1d_axes(handles_in);
 