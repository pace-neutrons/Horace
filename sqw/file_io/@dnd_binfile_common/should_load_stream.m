function [should,objinit,mess]= should_load_stream(obj,head_struc,fid)
% Check if this loader should load input data.
%
% The default implementation returns true if class version corresponds to
% the version provided by the structure and the type of the loader
% (sqw_type or not sqw_type) contains the same value as the value stored in
% the input header structure.
%
% Some child classes overload this method, to expand || shrink the type ot
% files the class should deal with.
%
%Usage:
%
%>> [should,objinit,mess] = obj.should_load_stream(head_struc,fid)
% where:
% head_struc:: structure returned by dnd_file_interface.get_file_header
%              static method and containing sqw/dnd file info, stored in
%              the file header.
% fid       :: file identifier of already opened binary sqw/dnd file where
%              head_struct has been read from
%
% Returns:
% should  :: boolean equal to true if the loader can load these data,
%            or false if not.
% objinit :: initialized helper obj_init class, containing information, necessary
%            to initialize the loader.
% message :: if false, contains detailed information on the reason why this
%            file should not be loaded by this loader. Empty, if should ==
%            true.
%
% The method is the main method used by sqw_file_formats factory to
% identify if particular accessor's class should be used to load the data
% as common dnd_file_interface.get_file_header method which opens file and
% reads the file header is slow so is deployed by sqw_format_factory only once.
%
% $Revision:: 1752 ($Date:: 2019-08-11 23:26:06 +0100 (Sun, 11 Aug 2019) $)
%
mess = '';
if isstruct(head_struc) && all(isfield(head_struc,{'sqw_type','version'}))
    if head_struc.sqw_type == obj.sqw_type && head_struc.version == obj.file_ver_
        objinit = obj_init(fid,head_struc.num_dim);
        should = true;
    else
        should = false;
        if obj.sqw_type
            type = 'sqw';
        else
            type = 'dnd';
        end
        mess = ['not Horace ',type,' ',obj.file_version,' file'];
        objinit = obj_init();
    end
else
    error('DND_FILE_INTERFACE:invalid_argument',...
        'the input structure for should_load_stream function does not have correct format');
end

