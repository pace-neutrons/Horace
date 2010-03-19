function handles_out=hor_cutprep(handles)
%
% Function to read and then repackeage in appropriate format all of the
% information required to determine what kind of cut to do.
%
% R.A. Ewings 12/11/2008
%

handles_out=handles;%initialise output parameter


%determine paramters that are used irrespective of data type:
%get the integration ranges (if selected) or data ranges
int1=get(handles.ax_label1_radio,'Value');
int2=get(handles.ax_label2_radio,'Value');
int3=get(handles.ax_label3_radio,'Value');
int4=get(handles.ax_label4_radio,'Value');
if int1==1
    lo=str2num(get(handles.LoLim_Ax1_edit,'String'));
    hi=str2num(get(handles.HiLim_Ax1_edit,'String'));
    if lo>=hi;
        disp('ERROR: integration low limit > high limit, axis 1');
        set(handles.Working_text,'BackgroundColor','r');
        set(handles.Working_text,'String',{'Status :';'Error'});
        guidata(gcbo,handles);
        return;
    end
    range1=[lo,hi];
    p1=['[',num2str(range1(1)),',',num2str(range1(2)),']'];
elseif ~isempty(get(handles.LoLim_Ax1_edit,'String')) && ...
        ~isempty(get(handles.HiLim_Ax1_edit,'String')) && ...
        ~isempty(get(handles.Step_Ax1_edit,'String')) && int1==0
    lo=str2num(get(handles.LoLim_Ax1_edit,'String'));
    hi=str2num(get(handles.HiLim_Ax1_edit,'String'));
    step=str2num(get(handles.Step_Ax1_edit,'String'));
    if lo>=hi; disp('ERROR: integration low limit > high limit, axis 1');
        set(handles.Working_text,'BackgroundColor','r');
        set(handles.Working_text,'String',{'Status :';'Error'});
        guidata(gcbo,handles);
        return;
    end
    range1=[lo,step,hi];
    p1=['[',num2str(range1(1)),',',num2str(range1(2)),',',num2str(range1(3)),']'];
elseif int1==1 && (isempty(get(handles.LoLim_Ax1_edit,'String')) || ...
        isempty(get(handles.HiLim_Ax1_edit,'String')))
    disp('ERROR: integration selected for axis 1 but lower and upper limits not given');
    set(handles.Working_text,'BackgroundColor','r');
    set(handles.Working_text,'String',{'Status :';'Error'});
    guidata(gcbo,handles);
    return;
elseif ~isempty(get(handles.Step_Ax1_edit,'String'))
    range1=(get(handles.Step_Ax1_edit,'String'));
    p1=range1;
else
    p1='[]';
end
%====
if int2==1
    lo=str2num(get(handles.LoLim_Ax2_edit,'String'));
    hi=str2num(get(handles.HiLim_Ax2_edit,'String'));
    if lo>=hi;
        disp('ERROR: integration low limit > high limit, axis 2');
        set(handles.Working_text,'BackgroundColor','r');
        set(handles.Working_text,'String',{'Status :';'Error'});
        guidata(gcbo,handles);
        return;
    end
    range2=[lo,hi];
    p2=['[',num2str(range2(1)),',',num2str(range2(2)),']'];
elseif ~isempty(get(handles.LoLim_Ax2_edit,'String')) && ...
        ~isempty(get(handles.HiLim_Ax2_edit,'String')) && ...
        ~isempty(get(handles.Step_Ax2_edit,'String')) && int2==0
    lo=str2num(get(handles.LoLim_Ax2_edit,'String'));
    hi=str2num(get(handles.HiLim_Ax2_edit,'String'));
    step=str2num(get(handles.Step_Ax2_edit,'String'));
    if lo>=hi
        disp('ERROR: integration low limit > high limit, axis 2');
        set(handles.Working_text,'BackgroundColor','r');
        set(handles.Working_text,'String',{'Status :';'Error'});
        guidata(gcbo,handles);
        return;
    end
    range2=[lo,step,hi];
    p2=['[',num2str(range2(1)),',',num2str(range2(2)),',',num2str(range2(3)),']'];
elseif int2==1 && (isempty(get(handles.LoLim_Ax2_edit,'String')) || ...
        isempty(get(handles.HiLim_Ax2_edit,'String')))
    disp('ERROR: integration selected for axis 2 but lower and upper limits not given');
    set(handles.Working_text,'BackgroundColor','r');
    set(handles.Working_text,'String',{'Status :';'Error'});
    guidata(gcbo,handles);
    return;
elseif ~isempty(get(handles.Step_Ax2_edit,'String'))
    range2=(get(handles.Step_Ax2_edit,'String'));
    p2=range2;
else
    p2='[]';
end
%=====
if int3==1
    lo=str2num(get(handles.LoLim_Ax3_edit,'String'));
    hi=str2num(get(handles.HiLim_Ax3_edit,'String'));
    if lo>=hi
        disp('ERROR: integration low limit > high limit, axis 3');
        set(handles.Working_text,'BackgroundColor','r');
        set(handles.Working_text,'String',{'Status :';'Error'});
        guidata(gcbo,handles);
        return;
    end
    range3=[lo,hi];
    p3=['[',num2str(range3(1)),',',num2str(range3(2)),']'];
elseif ~isempty(get(handles.LoLim_Ax3_edit,'String')) && ...
        ~isempty(get(handles.HiLim_Ax3_edit,'String')) && ...
        ~isempty(get(handles.Step_Ax3_edit,'String')) && int3==0
    lo=str2num(get(handles.LoLim_Ax3_edit,'String'));
    hi=str2num(get(handles.HiLim_Ax3_edit,'String'));
    step=str2num(get(handles.Step_Ax3_edit,'String'));
    if lo>=hi
        disp('ERROR: integration low limit > high limit, axis 3');
        set(handles.Working_text,'BackgroundColor','r');
        set(handles.Working_text,'String',{'Status :';'Error'});
        guidata(gcbo,handles);
        return;
    end
    range3=[lo,step,hi];
    p3=['[',num2str(range3(1)),',',num2str(range3(2)),',',num2str(range3(3)),']'];
elseif int3==1 && (isempty(get(handles.LoLim_Ax3_edit,'String')) || ...
        isempty(get(handles.HiLim_Ax3_edit,'String')))
    disp('ERROR: integration selected for axis 3 but lower and upper limits not given');
    set(handles.Working_text,'BackgroundColor','r');
    set(handles.Working_text,'String',{'Status :';'Error'});
    guidata(gcbo,handles);
    return;
elseif ~isempty(get(handles.Step_Ax3_edit,'String'))
    range3=(get(handles.Step_Ax3_edit,'String'));
    p3=range3;
else
    p3='[]';
end
if int4==1
    lo=str2num(get(handles.LoLim_Ax4_edit,'String'));
    hi=str2num(get(handles.HiLim_Ax4_edit,'String'));
    if lo>=hi
        disp('ERROR: integration low limit > high limit, axis 4'); 
        set(handles.Working_text,'BackgroundColor','r');
        set(handles.Working_text,'String',{'Status :';'Error'});
        guidata(gcbo,handles);
        return;
    end
    range4=[lo,hi];
    p4=['[',num2str(range4(1)),',',num2str(range4(2)),']'];
elseif ~isempty(get(handles.LoLim_Ax4_edit,'String')) && ...
        ~isempty(get(handles.HiLim_Ax4_edit,'String')) && ...
        ~isempty(get(handles.Step_Ax4_edit,'String')) && int4==0
    lo=str2num(get(handles.LoLim_Ax4_edit,'String'));
    hi=str2num(get(handles.HiLim_Ax4_edit,'String'));
    step=str2num(get(handles.Step_Ax4_edit,'String'));
    if lo>=hi
        disp('ERROR: integration low limit > high limit, axis 4'); 
        set(handles.Working_text,'BackgroundColor','r');
        set(handles.Working_text,'String',{'Status :';'Error'});
        guidata(gcbo,handles);
        return; 
    end
    range4=[lo,step,hi];
    p4=['[',num2str(range4(1)),',',num2str(range4(2)),',',num2str(range4(3)),']'];
elseif int4==1 && (isempty(get(handles.LoLim_Ax4_edit,'String')) || ...
        isempty(get(handles.HiLim_Ax4_edit,'String')))
    disp('ERROR: integration selected for axis 4 but lower and upper limits not given');
    set(handles.Working_text,'BackgroundColor','r');
    set(handles.Working_text,'String',{'Status :';'Error'});
    guidata(gcbo,handles);
    return;
elseif ~isempty(get(handles.Step_Ax4_edit,'String'))
    range4=(get(handles.Step_Ax4_edit,'String'));
    p4=range4;
else
    p4='[]';
end
%
%=============
%
%check that if data is to be saved to a workspace/file/both a name for the
%object and/or output file is provided:
if get(handles.SaveAsType_menu,'Value')==1 && isempty(get(handles.SaveAsObject_edit,'String'))
    disp('ERROR: You must provide a name for your cut data');
    set(handles.Working_text,'BackgroundColor','r');
    set(handles.Working_text,'String',{'Status :';'Error'});
    guidata(gcbo,handles);
    return;
end
if get(handles.SaveAsType_menu,'Value')==2 && ...
        (isempty(get(handles.SaveAsFileName_edit,'String')) || ...
        isempty(get(handles.SaveAsFilePath_edit,'String')))
    disp('ERROR: You must provide a filename and path for your cut data');
    set(handles.Working_text,'BackgroundColor','r');
    set(handles.Working_text,'String',{'Status :';'Error'});
    guidata(gcbo,handles);
    return;
end
if get(handles.SaveAsType_menu,'Value')==3 && ...
        (isempty(get(handles.SaveAsFileName_edit,'String')) || ...
        isempty(get(handles.SaveAsFilePath_edit,'String')) || ...
        isempty(get(handles.SaveAsObject_edit,'String')))
    disp('ERROR: You must provide a filename, path, and object name for your cut data');
    set(handles.Working_text,'BackgroundColor','r');
    set(handles.Working_text,'String',{'Status :';'Error'});
    guidata(gcbo,handles);
    return;
end
%====


if handles.data_file_flag==1%cutting a file
    handles=hor_cutfile(handles,p1,p2,p3,p4);
elseif handles.data_nd_file_flag==1%cutting nd data from file
    %do nothing - you do not cut from an nd datafile directly. When it is
    %loaded it is sent direct to the workspace. It can then be cut.
elseif handles.data_workspace_flag==1
    handles=hor_cutworkspace(handles,p1,p2,p3,p4);
else
    disp('ERROR: data were not from either SQW file, nd grid file or from workspace');
    disp('This is an error with the Horace GUI - please report so that we can fix it!');
    set(handles.Working_text,'BackgroundColor','r');
    set(handles.Working_text,'String',{'Status :';'Error'});
    guidata(gcbo,handles);
    return
end

guidata(gcbo,handles);
