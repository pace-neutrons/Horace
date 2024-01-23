function check_MATLAB_version()
%CHECK_MATLAB_VERSION verifies if the MATLAB version is sufficient to run
%xml_read/xml_write

v = ver('MATLAB');
vs = regexp(v.Version, '\d\d?.\d','match','once'); 
version = str2double(vs);
if (version<7.1)
    error('HERBERT:xml_io_toold:runtime_error', ...
        'Your MATLAB version is too old. You need version 7.1 or newer.');
end
