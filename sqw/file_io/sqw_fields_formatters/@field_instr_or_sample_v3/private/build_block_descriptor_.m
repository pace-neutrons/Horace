function [block_descriptor,nf_2process] = build_block_descriptor_(obj,input)
% Build block descriptor for the information, present in the instrument or
% sample
%
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

block_descriptor = struct('nfiles',nfiles,'all_same',all_same);
