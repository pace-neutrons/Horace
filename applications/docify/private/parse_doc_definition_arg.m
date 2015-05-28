function [val_out,changed,ok,mess]=parse_doc_definition_arg(val,args)
% Check if arg has form '#n', where n=1,2,...numel(args).
% If value is '\#n' then replace by '#n' i.e. '\#' is a control
% character. Only applies if leading '\' only with a positive integer after
% EXAMPLE
%       '\\\#3' => '\\#3'
%       'k#3', 'k\#3' are not changed

val_out=val;
ok=true;
changed=false;
mess='';
ind=strfind(val,'#');
if numel(ind)==1 && ind<numel(val) && isposchint(val(ind+1:end))
    if ind==1
        n=str2double(val(ind+1:end));
        if n>=1 && n<=numel(args)
            val_out=args{n};
            changed=true;
        else
            val_out=[];
            ok=false;
            if numel(args)>0
                mess=['Invalid argument number: must be in range 1 to ',num2str(numel(args))];
            else
                mess='No arguments allowed';
            end
        end
    elseif strcmp(val(1:ind-1),repmat('\',1,ind-1))
        val_out=val(2:end);
        changed=true;
    end
end

%------------------------------------------------------------------------------
function ok=isposchint(str)
% Check if a character string is a positive integer
ok=false;
if ~isempty(str)
    for i=1:numel(str)
        if isempty(strfind('0123456789',str(i)))
            return
        end
    end
    if ~(str(1)=='0')
        ok=true;
    end
end
