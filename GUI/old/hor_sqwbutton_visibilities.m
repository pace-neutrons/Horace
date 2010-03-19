function handles_out=hor_sqwbutton_visibilities(handles)
%
%function to update the visibilities of various buttons and fields so that
%all of the necessary things are displayed when the "Get SQW data from
%file" button is pressed.
%
% R.A. Ewings 17/11/2008
%

%Make all of the panels visible
set(handles.cut_panel,'Visible','on');
set(handles.Plot_panel,'Visible','on');

%Make the editor visible etc
set(handles.SQW_filename_text,'Visible','on');
set(handles.SQW_filename_edit,'Visible','on');
set(handles.BrowseSQW_pushbutton,'Visible','on');
set(handles.select_obj_menu,'Visible','off');
set(handles.proj_panel,'Visible','on');
set(handles.SQW_filename_text,'String','SQW Filename');
set(handles.LoadNdData_pushbutton,'Visible','off');
handles.data_workspace_flag=0;
handles.data_file_flag=1;
handles.data_nd_file_flag=0;
set(handles.LoadPars_text,'Visible','on');
set(handles.LoadPars_edit,'Visible','on');
set(handles.LoadPars_browse,'Visible','on');
set(handles.LoadPars_load,'Visible','on');
set(handles.RetainPixel_text,'Visible','on');
set(handles.RetainPixel_radio,'Visible','on');

%Make necessary fields and panels visible:
set(handles.axes_panel,'Visible','on');

set(handles.ax_label1_radio,'Visible','on');
set(handles.ax_label2_radio,'Visible','on');
set(handles.ax_label3_radio,'Visible','on');
set(handles.ax_label4_radio,'Visible','on');

set(handles.axislabel_edit1,'Visible','on');
set(handles.axislabel_edit2,'Visible','on');
set(handles.axislabel_edit3,'Visible','on');
set(handles.axislabel_edit4,'Visible','on');

set(handles.LoLim_Ax1_edit,'Visible','on');
set(handles.LoLim_Ax2_edit,'Visible','on');
set(handles.LoLim_Ax3_edit,'Visible','on');
set(handles.LoLim_Ax4_edit,'Visible','on');

set(handles.Step_Ax1_edit,'Visible','on');
set(handles.Step_Ax2_edit,'Visible','on');
set(handles.Step_Ax3_edit,'Visible','on');
set(handles.Step_Ax4_edit,'Visible','on');

set(handles.HiLim_Ax1_edit,'Visible','on');
set(handles.HiLim_Ax2_edit,'Visible','on');
set(handles.HiLim_Ax3_edit,'Visible','on');
set(handles.HiLim_Ax4_edit,'Visible','on');

%First we must check if integration buttons are already pressed:
%put in upper and lower limits of integration if the radio buttons are
%already checked:
if get(handles.ax_label1_radio,'Value') == get(handles.ax_label1_radio,'Max')...
        && strcmp(get(handles.ax_label1_radio,'Visible'),'on');
    set(handles.Step_Ax1_edit,'Visible','off');
end
if get(handles.ax_label2_radio,'Value') == get(handles.ax_label2_radio,'Max')...
        && strcmp(get(handles.ax_label2_radio,'Visible'),'on');
    set(handles.Step_Ax2_edit,'Visible','off');
end
if get(handles.ax_label3_radio,'Value') == get(handles.ax_label3_radio,'Max')...
        && strcmp(get(handles.ax_label3_radio,'Visible'),'on');
    set(handles.Step_Ax3_edit,'Visible','off');
end
if get(handles.ax_label4_radio,'Value') == get(handles.ax_label4_radio,'Max')...
        && strcmp(get(handles.ax_label4_radio,'Visible'),'on');
    set(handles.Step_Ax4_edit,'Visible','off');
end




% if get(handles.ax_label1_radio,'Value')==1 || get(handles.ax_label2_radio,'Value')==1 ||...
%         get(handles.ax_label3_radio,'Value')==1 || get(handles.ax_label4_radio,'Value')==1
%     handles_out=handles;
%     return;%do not want to adjust the visibilities any further!
% end



%the output:
handles_out=handles;