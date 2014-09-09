function  save_sample_output(output_file,cuts_list,log_level)
% function to save sample output consisting of the list of workspaces
% defined by the cut_list map with the key = name of the workspace and the
% value -- parameterless function handle, which defines this workspace
%
%Usage:
%>>save_sample_output(output_file,cuts_list,log_level)
% where:
% ouput file -- the name of the file to write the data
% cut_list   -- the map in the form of cuts_list(key)=@()f
%               where key is the name of the workspace to save and the
%               f -- the function which calculates this workspace
% log_level  -- integer, which defines the log level of the function
%               if this number is more then -1, the method will report its
%               progress. 
%
%
if log_level>-1
    disp('===========================')
    disp('    Save output')
    disp('===========================')
end

save_sqw=struct();
data_names = cuts_list.keys();
for i=1:numel(data_names)
    fname = data_names{i};
    cut_fun = cuts_list(fname);
    save_sqw.(fname) = cut_fun();
end

save(output_file,'-struct', 'save_sqw');
if log_level>-1
    disp(' ')
    disp(['Output saved to ',output_file])
    disp(' ')
end
