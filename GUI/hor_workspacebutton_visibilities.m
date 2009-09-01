function handles_out=hor_workspacebutton_visibilities(handles)
%
% Set the correct visibilities of various fields and menus for when the
% "Get nd data from file" button is pressed.
%
% R.A. Ewings 17/11/2008
%

set(handles.cut_panel,'Visible','on');
set(handles.Plot_panel,'Visible','on');
set(handles.SQW_filename_text,'Visible','off');
set(handles.SQW_filename_edit,'Visible','off');
set(handles.BrowseSQW_pushbutton,'Visible','off');
set(handles.select_obj_menu,'Visible','on');
set(handles.proj_panel,'Visible','off');
set(handles.LoadNdData_pushbutton,'Visible','off');
handles.data_workspace_flag=1;
handles.data_nd_file_flag=0;
handles.data_file_flag=0;
set(handles.LoadPars_text,'Visible','on');
set(handles.LoadPars_edit,'Visible','on');
set(handles.LoadPars_browse,'Visible','on');
set(handles.LoadPars_load,'Visible','on');
set(handles.RetainPixel_text,'Visible','off');
set(handles.RetainPixel_radio,'Visible','off');


%Now make sure that all of the objects in the various visible panels are
%themselves visible:
set(handles.axes_panel,'Visible','on');

% set(handles.ax_label1_radio,'Visible','on');
% set(handles.ax_label2_radio,'Visible','on');
% set(handles.ax_label3_radio,'Visible','on');
% set(handles.ax_label4_radio,'Visible','on');

set(handles.axislabel_edit1,'Visible','on');
set(handles.axislabel_edit2,'Visible','on');
set(handles.axislabel_edit3,'Visible','on');
set(handles.axislabel_edit4,'Visible','on');

set(handles.LoLim_Ax1_edit,'Visible','off');
set(handles.LoLim_Ax2_edit,'Visible','off');
set(handles.LoLim_Ax3_edit,'Visible','off');
set(handles.LoLim_Ax4_edit,'Visible','off');

set(handles.Step_Ax1_edit,'Visible','off');
set(handles.Step_Ax2_edit,'Visible','off');%these are off because you can't specify
%a step size for a cut of a dnd object.
set(handles.Step_Ax3_edit,'Visible','off');
set(handles.Step_Ax4_edit,'Visible','off');

set(handles.HiLim_Ax1_edit,'Visible','off');
set(handles.HiLim_Ax2_edit,'Visible','off');
set(handles.HiLim_Ax3_edit,'Visible','off');
set(handles.HiLim_Ax4_edit,'Visible','off');

%put in upper and lower limits of integration if the radio buttons are
%already checked:
if get(handles.ax_label1_radio,'Value') == get(handles.ax_label1_radio,'Max')...
        && strcmp(get(handles.ax_label1_radio,'Visible'),'on');
    set(handles.LoLim_Ax1_edit,'Visible','on');
    set(handles.HiLim_Ax1_edit,'Visible','on');
end
if get(handles.ax_label2_radio,'Value') == get(handles.ax_label2_radio,'Max')...
        && strcmp(get(handles.ax_label2_radio,'Visible'),'on');
    set(handles.LoLim_Ax2_edit,'Visible','on');
    set(handles.HiLim_Ax2_edit,'Visible','on');
end
if get(handles.ax_label3_radio,'Value') == get(handles.ax_label3_radio,'Max')...
        && strcmp(get(handles.ax_label3_radio,'Visible'),'on');
    set(handles.LoLim_Ax3_edit,'Visible','on');
    set(handles.HiLim_Ax3_edit,'Visible','on');
end
if get(handles.ax_label4_radio,'Value') == get(handles.ax_label4_radio,'Max')...
        && strcmp(get(handles.ax_label4_radio,'Visible'),'on');
    set(handles.LoLim_Ax4_edit,'Visible','on');
    set(handles.HiLim_Ax4_edit,'Visible','on');
end


%give the output:
handles_out=handles;