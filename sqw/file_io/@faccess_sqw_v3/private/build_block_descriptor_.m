function [block_descriptor,nf_2process] = build_block_descriptor_(obj,input,type)
% Build block descriptor for the information, present in the instrument or
% sample block
%
%type = class(input);
nfiles = numel(input);
if nfiles == 1
    all_same = true;
    nf_2process = 1;
else
    nf_2process = nfiles;
    if isstruct(input)
        trahsf_obj=input(1).(obj.field_name);
        all_same=true;
        for i=2:nfiles
            if ~isequal(trahsf_obj,input(i).(obj.field_name))
                all_same=false;
                break
            end
        end
    else % cellarray
        trahsf_obj=input{1}.(obj.field_name);
        all_same=true;
        for i=2:nfiles
            if ~isequal(trahsf_obj,input{i}.(obj.field_name))
                all_same=false;
                break
            end
        end
        
    end
end
if all_same; nf_2process = 1; end;


block_descriptor = obj.get_si_head_form(type);
block_descriptor.nfiles = nfiles;
block_descriptor.all_same= uint8(all_same);
