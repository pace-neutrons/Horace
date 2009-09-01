function handles_out=hor_plotswitch(handles_in)
%
% Function to determine what sort of plot we are going to do, and sort out
% the information from the GUI window.
%
% R.A. Ewings 11/11/2008
%

handles_out=handles_in;%initialise output so that it is the same as the input
%That way any changes we make here are not passed back to the main GUI
%functions.

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

%cannot smooth an sqw object without converting it to dnd.
%in fact the smoothing options should be invisible if an sqw object has
%been selected.
if issqw==0
    [handles_in,is_smoothed]=hor_plotsmooth(handles_in);%subroutine to do the appropriate smoothing
end


%===========================
%Non-d1d cases:
%===========================
switch is1d
    case false%not a 1d object (d1d object or 1d sqw object)
        %start off by cheking that there is an object to plot:
        if  isfield(handles_in,'w_out')
            w_out=handles_in.w_out;
            %plot(w_out);
        else
            disp('ERROR: no object selected');
            set(handles.Working_text,'BackgroundColor','r');
            set(handles.Working_text,'String',{'Status :';'Error'});
            guidata(gcbo,handles);
            return;
        end
        %we've now plotted the 2d slice or the sliceomatic window has
        %opened. Next we need to check if axes were specified for d2d case.
        objclass=class(w_out);
        if strcmp(objclass,'d3d') || sqw_ndims==3
            disp('----------------------------------------------');
            disp('Not reading plot axes limits');
            disp('Limits can be changed manually in sliceomatic');
            Axlabel1=get(handles.PlotAxis1_edit,'String');
            Axlabel2=get(handles.PlotAxis2_edit,'String');
            Axlabel3=get(handles.PlotAxis3_edit,'String');
            if ~isempty(Axlabel1) && strcmp(get(handles.PlotAxis1_edit,'Visible'),'on');
                xlabel(get(handles.PlotAxis1_edit,'String'));
            end
            if ~isempty(Axlabel2) && strcmp(get(handles.PlotAxis2_edit,'Visible'),'on');
                ylabel(get(handles.PlotAxis2_edit,'String'));
            end
            if ~isempty(Axlabel3) && strcmp(get(handles.PlotAxis3_edit,'Visible'),'on');
                zlabel(get(handles.PlotAxis3_edit,'String'));
            end
            return
        elseif strcmp(objclass,'d2d') || sqw_ndims==2
            da(w_out);
            %call a function to deal with d2d plots with axes
            hor_plotaxes(handles_in);
        end
     
 %===============================
 %d1d cases:
    case true%is a d1d
        %several possibilities here - deal with them in a subroutine.
        hor_plot1d(handles_in);
        %
        hor_plot1d_axes(handles_in);
end    