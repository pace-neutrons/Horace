function handles_out=hor_nddatabutton_visibilities(handles)
%
% Set the correct visibilities of various fields and menus for when the
% "Get nd data from file" button is pressed.
%
% R.A. Ewings 17/11/2008
%

set(handles.cut_panel,'Visible','off');
set(handles.Plot_panel,'Visible','off');
set(handles.SQW_filename_text,'Visible','on');
set(handles.SQW_filename_edit,'Visible','on');
set(handles.SQW_filename_text,'String','Filename');
set(handles.BrowseSQW_pushbutton,'Visible','on');
set(handles.select_obj_menu,'Visible','off');
set(handles.LoadNdData_pushbutton,'Visible','on');
set(handles.proj_panel,'Visible','off');
handles.data_workspace_flag=0;
handles.data_file_flag=0;
handles.data_nd_file_flag=1;
set(handles.LoadPars_text,'Visible','on');
set(handles.LoadPars_edit,'Visible','on');
set(handles.LoadPars_browse,'Visible','on');
set(handles.LoadPars_load,'Visible','on');
set(handles.RetainPixel_text,'Visible','off');
set(handles.RetainPixel_radio,'Visible','off');

%Now make sure that the objects in the various visible panels are
%themselves visible if needed:
set(handles.axes_panel,'Visible','off');

set(handles.ax_label1_radio,'Visible','off');
set(handles.ax_label2_radio,'Visible','off');
set(handles.ax_label3_radio,'Visible','off');
set(handles.ax_label4_radio,'Visible','off');

set(handles.axislabel_edit1,'Visible','off');
set(handles.axislabel_edit2,'Visible','off');
set(handles.axislabel_edit3,'Visible','off');
set(handles.axislabel_edit4,'Visible','off');

set(handles.LoLim_Ax1_edit,'Visible','off');
set(handles.LoLim_Ax2_edit,'Visible','off');
set(handles.LoLim_Ax3_edit,'Visible','off');
set(handles.LoLim_Ax4_edit,'Visible','off');

set(handles.Step_Ax1_edit,'Visible','off');
set(handles.Step_Ax2_edit,'Visible','off');
set(handles.Step_Ax3_edit,'Visible','off');
set(handles.Step_Ax4_edit,'Visible','off');

set(handles.HiLim_Ax1_edit,'Visible','off');
set(handles.HiLim_Ax2_edit,'Visible','off');
set(handles.HiLim_Ax3_edit,'Visible','off');
set(handles.HiLim_Ax4_edit,'Visible','off');

%give the output:
handles_out=handles;