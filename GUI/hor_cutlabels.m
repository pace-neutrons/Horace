function handles_out=hor_cutlabels(handles_in,outname,ndims,lab1,lab2,lab3,lab4)
%
% function to sort out the new labels (if necessary) for a cut.
%
% R.A. Ewings 21/11/2008
%

%NOTE : THIS FUNCTION HAS NOT BEEN ADAPTED TO DEAL WITH SQW OBJECTS YET.

w_in=handles_in.w_in;

evalin('base',['getit=get(',outname,');']);

%==========
%Determine if pixel info was to be retained
if strcmp(get(handles_in.RetainPixel_radio,'Visible'),'on') && ...
        get(handles_in.RetainPixel_radio,'Value')==1
    KeepPixels=1;
else
    KeepPixels=0;
end
%============

if ~strcmp(class(w_in),'sqw') || KeepPixels==0
    if ~isempty(lab1)
        evalin('base',['getit.ulabel{1}=''',lab1,''';']);
    end

    if ~isempty(lab2)
        evalin('base',['getit.ulabel{2}=''',lab2,''';']);
    end

    if ~isempty(lab3)
        evalin('base',['getit.ulabel{3}=''',lab3,''';']);
    end

    if ~isempty(lab4)
        evalin('base',['getit.ulabel{4}=''',lab4,''';']);
    end
    
    evalstring=['d',num2str(ndims-1),'d'];
else
    if ~isempty(lab1)
        evalin('base',['getit.header.ulabel{1}=''',lab1,''';']);
        evalin('base',['getit.data.ulabel{1}=''',lab1,''';']);
    end

    if ~isempty(lab2)
        evalin('base',['getit.header.ulabel{2}=''',lab2,''';']);
        evalin('base',['getit.data.ulabel{2}=''',lab2,''';']);
    end

    if ~isempty(lab3)
        evalin('base',['getit.header.ulabel{3}=''',lab3,''';']);
        evalin('base',['getit.data.ulabel{3}=''',lab3,''';']);
    end

    if ~isempty(lab4)
        evalin('base',['getit.header.ulabel{4}=''',lab4,''';']);
        evalin('base',['getit.data.ulabel{4}=''',lab4,''';']);
    end
    
    evalstring='sqw';
end

%Now do the correct conversion back to dnd object:
evalin('base',[outname,'=',evalstring,'(getit);']);

%Pass back any modifications:
handles_out=handles_in;