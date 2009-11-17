function handles_out=hor_cutworkspace(handles,p1,p2,p3,p4)
%
% function to do a cut on an objet in the workspace.
%
% R.A. Ewings, 17/11/2008
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
if handles.data_workspace_flag==1;%cutting a workspace object
    %
    if strcmp(get(handles.proj_panel,'Visible'),'on')
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
        assignin('base','proj',proj);
    end
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
    assignin('base','p1',p1);
    assignin('base','p2',p2);
    assignin('base','p3',p3);
    assignin('base','p4',p4);
    objname=handles.object_name;
    w_in=handles.w_in;
    if strcmp(class(w_in),'d0d')
        ndims=0;
    elseif strcmp(class(w_in),'d1d')
        ndims=1;
    elseif strcmp(class(w_in),'d2d')
        ndims=2;
    elseif strcmp(class(w_in),'d3d')
        ndims=3;
    elseif strcmp(class(w_in),'sqw');
        [handles,ndims]=hor_sqwdims(handles);
    else
        ndims=4;
    end
    %
    if SaveAs_opt==1
        % save into the workspace
        outname=get(handles.SaveAsObject_edit,'String');
        if KeepPixels==1
            if length(u1)==3 && length(u2)==3 && length(uoff)==4
                evalstring=[outname,'=cut(',objname,',proj,',p1,',',p2,',',p3,',',p4,');'];
            elseif ndims==4
                evalstring=[outname,'=cut(',objname,',',p1,',',p2,',',p3,',',p4,');'];
            elseif ndims==3
                evalstring=[outname,'=cut(',objname,',',p1,',',p2,',',p3,');'];
            elseif ndims==2
                evalstring=[outname,'=cut(',objname,',',p1,',',p2,');'];
            elseif ndims==1
                evalstring=[outname,'=cut(',objname,',',p1,');'];
            else
                evalstring='';
            end
        elseif KeepPixels==0 && (strcmp(get(handles.proj_panel,'Visible'),'on'))
            %this is the case where we cut an sqw object but do not retain
            %pixel information (so resulting cut is a dnd)
            if length(u1)==3 && length(u2)==3 && length(uoff)==4
                evalstring=[outname,'=cut(',objname,',proj,',p1,',',p2,',',p3,',',p4,',''-nopix'');'];
            elseif ndims==4
                evalstring=[outname,'=cut(',objname,',',p1,',',p2,',',p3,',',p4,',''-nopix'');'];
            elseif ndims==3
                evalstring=[outname,'=cut(',objname,',',p1,',',p2,',',p3,',''-nopix'');'];
            elseif ndims==2
                evalstring=[outname,'=cut(',objname,',',p1,',',p2,',''-nopix'');'];
            elseif ndims==1
                evalstring=[outname,'=cut(',objname,',',p1,',''-nopix'');'];
            else
                evalstring='';
            end
        else
            %evalstring=[outname,'=cut(',objname,',',p1,',',p2,',',p3,',',p4,',''-nopix'');'];
            if ndims==4
                evalstring=[outname,'=cut(',objname,',',p1,',',p2,',',p3,',',p4,');'];
            elseif ndims==3
                evalstring=[outname,'=cut(',objname,',',p1,',',p2,',',p3,');'];
            elseif ndims==2
                evalstring=[outname,'=cut(',objname,',',p1,',',p2,');'];
            elseif ndims==1
                evalstring=[outname,'=cut(',objname,',',p1,');'];
            else
                evalstring='';
            end
        end
        evalin('base',evalstring);%this works
        %
        %Now we change the axes labels, as requested:
        handles=hor_cutlabels(handles,outname,ndims,lab1,lab2,lab3,lab4);
        %
    elseif SaveAs_opt==2
        %save to a file only:
        if isempty(get(handles.SaveAsFilePath_edit,'String')) ||...
                isempty(get(handles.SaveAsFileName_edit,'String'))
            disp('ERROR: path and/or name of output file not given');
            set(handles.Working_text,'BackgroundColor','r');
            set(handles.Working_text,'String',{'Status :';'Error'});
            guidata(gcbo,handles);
            return;
        else
            savefilename=[get(handles.SaveAsFilePath_edit,'String'),...
                '\',get(handles.SaveAsFileName_edit,'String')];
        end
        assignin('base','savefilename',savefilename);
        if KeepPixels==1
            if length(u1)==3 && length(u2)==3 && length(uoff)==4
                evalstring=['pilchardus=cut(',objname,',proj,',p1,',',p2,',',p3,',',p4,');'];
            elseif ndims==4
                evalstring=['pilchardus=cut(',objname,',',p1,',',p2,',',p3,',',p4,');'];
            elseif ndims==3
                evalstring=['pilchardus=cut(',objname,',',p1,',',p2,',',p3,');'];
            elseif ndims==2
                evalstring=['pilchardus=cut(',objname,',',p1,',',p2,');'];
            elseif ndims==1
                evalstring=['pilchardus=cut(',objname,',',p1,');'];
            else
                evalstring='';
            end
        elseif KeepPixels==0 && (strcmp(get(handles.proj_panel,'Visible'),'on'))
            %this is the case where we cut an sqw object but do not retain
            %pixel information (so resulting cut is a dnd)
            if length(u1)==3 && length(u2)==3 && length(uoff)==4
                evalstring=['pilchardus=cut(',objname,',proj,',p1,',',p2,',',p3,',',p4,',''-nopix'');'];
            elseif ndims==4
                evalstring=['pilchardus=cut(',objname,',',p1,',',p2,',',p3,',',p4,',''-nopix'');'];
            elseif ndims==3
                evalstring=['pilchardus=cut(',objname,',',p1,',',p2,',',p3,',''-nopix'');'];
            elseif ndims==2
                evalstring=['pilchardus=cut(',objname,',',p1,',',p2,',''-nopix'');'];
            elseif ndims==1
                evalstring=['pilchardus=cut(',objname,',',p1,',''-nopix'');'];
            else
                evalstring='';
            end
        else
            %evalstring=[outname,'=cut(',objname,',',p1,',',p2,',',p3,',',p4,',''-nopix'');'];
            if ndims==4
                evalstring=['pilchardus=cut(',objname,',',p1,',',p2,',',p3,',',p4,');'];
            elseif ndims==3
                evalstring=['pilchardus=cut(',objname,',',p1,',',p2,',',p3,');'];
            elseif ndims==2
                evalstring=['pilchardus=cut(',objname,',',p1,',',p2,');'];
            elseif ndims==1
                evalstring=['pilchardus=cut(',objname,',',p1,');'];
            else
                evalstring='';
            end
        end
        evalin('base',evalstring);  
        handles=hor_cutlabels(handles,'pilchardus',ndims,lab1,lab2,lab3,lab4);
        if isempty(savefilename)
            %should have already caught this
            disp('ERROR: path and/or name of output file not given');
            set(handles.Working_text,'BackgroundColor','r');
            set(handles.Working_text,'String',{'Status :';'Error'});
            guidata(gcbo,handles);
            return;
        else
            evalin('base',['save(pilchardus,''',savefilename,''');']);
        end
        evalin('base','clear pilchardus');%get rid of the temporary "pilchardus" object from 
        %the workspace.
        %
    elseif SaveAs_opt==3
        %Save to file and workspace:
        outname=get(handles.SaveAsObject_edit,'String');
        if isempty(get(handles.SaveAsFilePath_edit,'String')) ||...
                isempty(get(handles.SaveAsFileName_edit,'String'))
            savefilename='';
        else
            savefilename=[get(handles.SaveAsFilePath_edit,'String'),...
                '\',get(handles.SaveAsFileName_edit,'String')];
        end
        assignin('base','savefilename',savefilename);
        if KeepPixels==1
            if length(u1)==3 && length(u2)==3 && length(uoff)==4
                evalstring=[outname,'=cut(',objname,',proj,',p1,',',p2,',',p3,',',p4,');'];
            elseif ndims==4
                evalstring=[outname,'=cut(',objname,',',p1,',',p2,',',p3,',',p4,');'];
            elseif ndims==3
                evalstring=[outname,'=cut(',objname,',',p1,',',p2,',',p3,');'];
            elseif ndims==2
                evalstring=[outname,'=cut(',objname,',',p1,',',p2,');'];
            elseif ndims==1
                evalstring=[outname,'=cut(',objname,',',p1,');'];
            else
                evalstring='';
            end
        elseif KeepPixels==0 && (strcmp(get(handles.proj_panel,'Visible'),'on'))
            %this is the case where we cut an sqw object but do not retain
            %pixel information (so resulting cut is a dnd)
            if length(u1)==3 && length(u2)==3 && length(uoff)==4
                evalstring=[outname,'=cut(',objname,',proj,',p1,',',p2,',',p3,',',p4,',''-nopix'');'];
            elseif ndims==4
                evalstring=[outname,'=cut(',objname,',',p1,',',p2,',',p3,',',p4,',''-nopix'');'];
            elseif ndims==3
                evalstring=[outname,'=cut(',objname,',',p1,',',p2,',',p3,',''-nopix'');'];
            elseif ndims==2
                evalstring=[outname,'=cut(',objname,',',p1,',',p2,',''-nopix'');'];
            elseif ndims==1
                evalstring=[outname,'=cut(',objname,',',p1,',''-nopix'');'];
            else
                evalstring='';
            end
        else
            %evalstring=[outname,'=cut(',objname,',',p1,',',p2,',',p3,',',p4,',''-nopix'');'];
            if ndims==4
                evalstring=[outname,'=cut(',objname,',',p1,',',p2,',',p3,',',p4,');'];
            elseif ndims==3
                evalstring=[outname,'=cut(',objname,',',p1,',',p2,',',p3,');'];
            elseif ndims==2
                evalstring=[outname,'=cut(',objname,',',p1,',',p2,');'];
            elseif ndims==1
                evalstring=[outname,'=cut(',objname,',',p1,');'];
            else
                evalstring='';
            end
        end
        evalin('base',evalstring);  
        handles=hor_cutlabels(handles,outname,ndims,lab1,lab2,lab3,lab4);
        if isempty(savefilename)
            evalin('base',['save(',outname,');']);
        else
            evalin('base',['save(',outname,',''',savefilename,''');']);
        end
        %
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