function compiled_worker(varargin)
    % Entry point function for compiled Matlab worker
    [control_string, logfile] = parse_input_args(varargin);
    % Use evalc to capture output and pipe to logfile if needed
    out = evalc(['worker_v2( ''' control_string ''')']);
    if ~isempty(logfile)
        fid = fopen(logfile, 'w');
        fprintf(fid, '%s\n', out);
        fclose(fid);
    end
end

function [cs, lf] = parse_input_args(args)
    % Parses input arguments to extract the control string if one exists
    %
    % The allow arguments are:
    % -logfile <lf>      : Save output to a logfile
    % -r <CMD>           : CMD is parsed to see if has control string
    % -batch <CMD>       : CMD is parsed to see if has control string
    % -nosplash          : Ignored
    % -nojvm             : Ignored
    % -nodesktop         : Ignored
    % control_string     : The first positional argument is considered the control string
    %
    % The control string returned is extracted from the positional or last keyword argument
    % that matches - e.g. "-r worker_v2(cs1) -batch worker(cs2)" returns cs2
    % and "-r worker(cs1) -batch c(cs2) cs3" returns cs3
    cs = ''; % Default is empty string
    lf = '';
    is_seen = cellfun(@(x) x(1)=='-', args);
    key_idx = find(is_seen);
    for ii = 1:numel(key_idx)
        next_idx = key_idx(ii) + 1;
        switch(args{key_idx(ii)})
            case '-logfile'
                lf = args{next_idx};
                is_seen(next_idx) = 1;
            case {'-r', '-batch'}
                cs = parse_cmd(args{next_idx});
                is_seen(next_idx) = 1;
            case {'-nosplash', '-nojvm', '-nodesktop'}
                % Does nothing
            otherwise
                error(['Unknown option ' args{key_idx(ii)}]);
        end
    end
    idx_not_seen = find(~is_seen);
    if ~isempty(idx_not_seen)
        cs = args{idx_not_seen(1)};
    end
end

function cs = parse_cmd(cmdstr)
    % Parses a command string to extract a control string
    cs = ''; % Default is empty string
    if contains(cmdstr, '(') && contains(cmdstr, ')')
        [token, match] = regexp(cmdstr, "[\w\d\.\\\/:]*\('([\w\d\-]*)'\).*", 'tokens', 'match');
        if ~isempty(token)
            while iscell(token), token = token{1}; end
            cs = char(token);
        end
    end
end
