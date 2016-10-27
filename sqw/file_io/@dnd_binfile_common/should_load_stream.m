function [should,obj,mess]= should_load_stream(obj,stream,fid)
% Check if this loader should deal with selected data structure
%Usage:
%
%>> [should,obj] = obj.should_load_stream(datastream,fid)
% structure returned by get_file_header function
% Returns:
% true if the loader can load these data, or false if not
% with message explaining the reason for not loading the data
% of should, object is initiated by appropriate file inentified
mess = '';
if isstruct(stream) && all(isfield(stream,{'sqw_type','version'}))
    if stream.sqw_type == obj.sqw_type && stream.version == obj.file_ver_
        obj.file_id_ = fid;
        obj.num_dim_ = double(stream.num_dim);
        obj.file_closer_ = onCleanup(@()obj.fclose());
        should = true;
    else
        should = false;
        if stream.sqw_type
            type = 'sqw';
        else
            type = 'dnd';
        end
        mess = ['not Horace ',type,' ',obj.file_version,' file'];
    end
else
    error('DND_FILE_INTERFACE:invalid_argument',...
        'the input structure for should_load_stream function does not have correct format');
end

