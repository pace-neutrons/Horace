function det = convert_old_det_forms_(detpar,n_instances)
% Method used to convert detector formats written by any previous version
% of Horace into Horace 4.01 data form.
%
% Input:
% detpar      -- an old or new format detector information.
%                Normally obtained from binary sqw file.
% n_instances -- number of run, this
%
% Returns:
% det         -- detector information packed in
%                unique_object_container container and
%                distributed into approriate number of input
%                runs.

if isstruct(detpar) % we do not need do deal with struct array
    % here as this have never been used and stored in
    detpar = IX_detector_array(detpar);
end
if isa(detpar,'IX_detector_array')
    det = unique_objects_container('baseclass','IX_detector_array');
    det = det.add(detpar);
    det = det.replicate_runs(n_instances);
elseif isa(detpar,'unique_objects_container') || isa(detpar,'unique_references_container')
    if detpar.n_objects == 1
        det = detpar.replicate_runs(n_instances);
    elseif ~isempty(n_instances) && detpar.n_objects == n_instances
        det = detpar;
    else
        error('HORACE:horace_binfile_interface:invalid_argument', ...
            ['Number of IX_detector_array objects %d provided in ' ...
            'the input container is not consistent with number of objects, ' ...
            'requested to return (%d).\n' ...
            'Input should be either 1 or equal to the number of requested'], ...
            detpar.n_objects,n_instances)
    end
else
    error('HORACE:horace_binfile_interface:invalid_argument', ...
        ['Unrecognized input class: "%s" provided to the conversion method\n' ...
        'Allowed inputs are: "struc", "ID_detector_array", ' ...
        '"unique_objects_container" or "unique_references_container" '],...
        class(detpar))
end
end
