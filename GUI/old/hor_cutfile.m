function handles_out=hor_cutfile(handles,p1,p2,p3,p4)
%
% function to cut data from a file using the GUI.
%
% R.A. Ewings 17/11/2008
%

handles_out=handles;%initialise the output.

%determine how data will be saved:
SaveAs_opt=get(handles.SaveAsType_menu,'Value');%=1 for workspace, 2 for file, 3 for both.

%determine if pixel information is to be retained:
if strcmp(get(handles.RetainPixel_radio,'Visible'),'on') && ...
        get(handles.RetainPixel_radio,'Value')==1
    KeepPixels=1;
else
    KeepPixels=0;
end

%================
%determine whether we are cutting an existing object or data from a file:
if handles.data_file_flag==1%cutting a file
    uoff=[str2num(get(handles.uo_h_edit,'String')),str2num(get(handles.uo_k_edit,'String')),...
        str2num(get(handles.uo_l_edit,'String')),str2num(get(handles.uo_e_edit,'String'))];
    u1=[str2num(get(handles.u1_h_edit,'String')),str2num(get(handles.u1_k_edit,'String')),...
        str2num(get(handles.u1_l_edit,'String'))];
    u2=[str2num(get(handles.u2_h_edit,'String')),str2num(get(handles.u2_k_edit,'String')),...
        str2num(get(handles.u2_l_edit,'String'))];
    radio1=get(handles.u1_rlu_radio,'Value');
    radio2=get(handles.u2_rlu_radio,'Value');
    radio3=get(handles.u3_rlu_radio,'Value');
    if radio1==1
        rlustr='r';
    else
        rlustr='a';
    end
    if radio2==1
        rlustr=[rlustr,'r'];
    else
        rlustr=[rlustr,'a'];
    end
    if radio3==1
        rlustr=[rlustr,'r'];
    else
        rlustr=[rlustr,'a'];
    end
    proj.u=u1;
    proj.v=u2;
    proj.uoffset=uoff;
    proj.type=rlustr;
    %
    %Determine if new labels will be given to any of the axes:
    if ~isempty(get(handles.axislabel_edit1,'String'))
        lab1=get(handles.axislabel_edit1,'String');
    else
        lab1='';
    end
    if ~isempty(get(handles.axislabel_edit2,'String'))
        lab2=get(handles.axislabel_edit2,'String');
    else
        lab2='';
    end
    if ~isempty(get(handles.axislabel_edit3,'String'))
        lab3=get(handles.axislabel_edit3,'String');
    else
        lab3='';
    end
    if ~isempty(get(handles.axislabel_edit4,'String'))
        lab4=get(handles.axislabel_edit4,'String');
    else 
        lab4='';
    end
    %
    %
    filename=get(handles.SQW_filename_edit,'String');
    assignin('base','proj',proj);%send the various parameters needed for the cut to the workspace
    assignin('base','p1',p1);
    assignin('base','p2',p2);
    assignin('base','p3',p3);
    assignin('base','p4',p4);
    if SaveAs_opt==1
        % save into the workspace
%         outname=get(handles.SaveAsObject_edit,'String');
%         evalstring=[outname,'=cut_sqw(''',filename,''',','proj',',',p1,',',p2,',',p3,',',p4,');'];
%         evalin('base',evalstring);%this works
        % save into the workspace
        outname=get(handles.SaveAsObject_edit,'String');
        if KeepPixels==1
            evalstring=[outname,'=cut_sqw(''',filename,''',proj,',p1,',',p2,',',p3,',',p4,');'];
        elseif KeepPixels==0 && (strcmp(get(handles.proj_panel,'Visible'),'on'))
            evalstring=[outname,'=cut_sqw(''',filename,''',proj,',p1,',',p2,',',p3,',',p4,',''-nopix'');'];
        else
            disp('ERROR: Horace logic error. Contact R. Ewings for help');
            set(handles.Working_text,'BackgroundColor','r');
            set(handles.Working_text,'String',{'Status :';'Error'});
            guidata(gcbo,handles);
            return;
        end
        evalin('base',evalstring);%this works
        %
        %Now we save the object created during the cut to the handles
        %structure:
        handles.w_in=evalin('base',['',outname,';']);
        %Now we change the axes labels, as requested:
        ndims=evalin('base',['dimensions(',outname,');']);
        handles=hor_cutlabels_file(handles,outname,ndims,lab1,lab2,lab3,lab4);
        %
    elseif SaveAs_opt==2
        %save to a file only:
        if isempty(get(handles.SaveAsFilePath_edit,'String')) ||...
                isempty(get(handles.SaveAsFileName_edit,'String'))
            savefilename='-save';%this results in Horace prompting for a filename
        else
            savefilename=[get(handles.SaveAsFilePath_edit,'String'),'\',...
                get(handles.SaveAsFileName_edit,'String')];
        end
%         evalstring=['cut_sqw(''',filename,''',','proj',',',...
%             p1,',',p2,',',p3,',',p4,',''',savefilename,''');'];
%         evalin('base',evalstring);  
        assignin('base','savefilename',savefilename);
        if KeepPixels==1
            evalstring=['pilchardus=cut_sqw(''',filename,''',proj,',p1,',',p2,',',p3,',',p4,');'];
        elseif KeepPixels==0 && (strcmp(get(handles.proj_panel,'Visible'),'on'))
            evalstring=['pilchardus=cut_sqw(''',filename,''',proj,',p1,',',p2,',',p3,',',p4,',''-nopix'');'];
        else
            disp('ERROR: Horace logic error. Contact R. Ewings for help');
            set(handles.Working_text,'BackgroundColor','r');
            set(handles.Working_text,'String',{'Status :';'Error'});
            guidata(gcbo,handles);
            return;
        end    
        evalin('base',evalstring);
        %
        ndims=evalin('base',['dimensions(pilchardus);']);
        %put the object into the handles structure:
        handles.w_in=evalin('base','pilchardus');
        handles=hor_cutlabels_file(handles,'pilchardus',ndims,lab1,lab2,lab3,lab4);
        if isempty(savefilename)
            evalin('base','save(pilchardus);');
        else
            evalin('base',['save(pilchardus,''',savefilename,''');']);
        end
        evalin('base','clear pilchardus');%get rid of the temporary "pilchardus" object from 
        %the workspace.
        %
    elseif SaveAs_opt==3
        %save in workspace and to file:
        outname=get(handles.SaveAsObject_edit,'String');
        if isempty(get(handles.SaveAsFilePath_edit,'String')) ||...
                isempty(get(handles.SaveAsFileName_edit,'String'))
            savefilename='-save';%this results in Horace prompting for a filename
        else
            savefilename=[get(handles.SaveAsFilePath_edit,'String'),'\',...
                get(handles.SaveAsFileName_edit,'String')];
        end
%         evalstring=[outname,'=cut_sqw(''',filename,''',','proj',',',...
%             p1,',',p2,',',p3,',',p4,',''',savefilename,''');'];
%         evalin('base',evalstring);  
        assignin('base','savefilename',savefilename);
        if KeepPixels==1
            evalstring=[outname,'=cut_sqw(''',filename,''',proj,',p1,',',p2,',',p3,',',p4,');'];
        elseif KeepPixels==0 && (strcmp(get(handles.proj_panel,'Visible'),'on'))
            evalstring=[outname,'=cut_sqw(''',filename,''',proj,',p1,',',p2,',',p3,',',p4,',''-nopix'');'];
        else
            disp('ERROR: Horace logic error. Contact R. Ewings for help');
            set(handles.Working_text,'BackgroundColor','r');
            set(handles.Working_text,'String',{'Status :';'Error'});
            guidata(gcbo,handles);
            return;
        end    
        evalin('base',evalstring);  
        %
        ndims=evalin('base',['dimensions(',outname,');']);
        %save the object to the handles structure:
        handles.w_in=evalin('base',['',outname,';']);
        handles=hor_cutlabels_file(handles,outname,ndims,lab1,lab2,lab3,lab4);
        if isempty(savefilename)
            evalin('base',['save(',outname,');']);
        else
            evalin('base',['save(',outname,',''',savefilename,''');']);
        end
    else
        disp('ERROR: Horace GUI logic flaw - not saving object in workspace or file or both');
        set(handles.Working_text,'BackgroundColor','r');
        set(handles.Working_text,'String',{'Status :';'Error'});
        guidata(gcbo,handles);
        return;
    end
else
    disp('ERROR: logic problem in Horace GUI at hor_cutprep and hor_cutfile');
    disp('Program thinks it should be cutting a file but data are not read as such');
    set(handles.Working_text,'BackgroundColor','r');
    set(handles.Working_text,'String',{'Status :';'Error'});
    guidata(gcbo,handles);
    return
end

handles_out=handles;