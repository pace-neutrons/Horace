function combine_test_cuts()
% The routine cuts number of chunks and combines them together into full 4D
% sqw file
%
% source data file to make cuts from:
fln = 'test_sym_op.sqw';
% define the range of your 2D cuts common for all cuts
% Modify if your particular cuts are different and add another range to
% another direction if necessary.
com_range = [-0.55,0.01,0.15];
% define range of the cuts to be combined through:
cut_range = -0.15:0.2:0.55;

% find number of chunks to process
n_chunks = numel(cut_range)-1;
% storace for chunk filenames.
subfiles = cell(1,n_chunks);
%
% define the projection, applicable to all cuts to process.
proj = struct('u',[1,0,0],'v',[0,1,0]);

for i= 1:n_chunks
    w2 = cut_sqw(fln,proj ,com_range,com_range,[cut_range(i),cut_range(i+1)],[-3,3]);
    % do something with the cut here
    % ......
    % finish custom cut processing
    %
    % convert cut into 4D in the whole range of the sequence of cuts.
    w2_4 = cut_sqw(w2,proj ,com_range,com_range,[cut_range(1),0.01,cut_range(end)],[-3,0.1,3]);
    %
    if i>1 % mark all headers from not the first cut as a subzone headers.
        % may it be easier just to delete headers, but this have not been
        % tested.
        w2_4 = trahsform_headers(w2_4,i,[com_range(1),com_range(1),cut_range(i)],...
            2,n_chunks);
    end
    % define chunk filename. 
    subfiles{i} = sprintf('cut_N%d.tmp',i);
    % write cut to disk
    save(w2_4,subfiles{i});
end
% combine chunks together into the final file
write_nsqw_to_sqw(subfiles,'cut_combined.sqw','drop_subzones_headers');
end


function  cut_part = trahsform_headers(cut_part,zone_id,zone_center,...
    n_cur_chunk,num_chunks)
% transform headers to store information about zone the header has been cut
% out and the chunk the zone has been divided into

headers = cut_part.header;
file_id = sprintf('_zoneID#%d_center[%d,%d,%d]',zone_id,zone_center(1),...
    zone_center(2),zone_center(3));
n_headers = numel(headers);
chunk_id = sprintf('pixBase%dZoneID%dchunk%d#%d',n_headers,zone_id,...
    n_cur_chunk,num_chunks);


    function hd = change_header(hd)
        hd.filename = [hd.filename,file_id];
        hd.filepath = chunk_id;
    end
if numel(headers) > 1
    headers = cellfun(@(x)change_header(x),headers,'UniformOutput',false);
else
    headers = change_header(headers);
end
cut_part.header = headers;
end
