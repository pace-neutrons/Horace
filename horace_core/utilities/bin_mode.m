classdef bin_mode < uint32
    % Enumeration class describes various bin modes AxesBlockBase.bin_pixels
    % algorithm. The numbering and names selected to coinside with C++ mex
    % routine
    enumeration
        npix_only    (0) % calculate npix array binning input coordinates over range provided
        invalid_mode (1) % this mode is not supported by binning routine
        sig_err      (2) % calculate npix, signal and error
        sigerr_cell  (3) % signal and error for binning are presented in cellarrays of data rather then pixel data array
        sort_pix     (4) % in additional to binning pixels coordinates, return pixels sorted by bins
        sort_and_uid (5) % in additional to binning and sorting, return unique pixels id
        nosort       (6) % do binning but do not sort pixels but return array which defines pixels position
        %                %  within the image grid
        nosort_sel   (7) % like nosort, but return ?logical? array which specifies what pixels have been selected
        %                  and what were rejected by binning operations
        sigerr_sel   (8) % like sig_err but also return logical array of selected pixels
        N_OP_Modes   (9) % total number of modes code operates in. Provided for checks
    end
    methods(Static)
        function mode = from_narg(num_arguments,test_inputs,sigerr_and_selected,varargin)
            % retrieve binning mode from number of arguments, requested to
            % process

            if test_inputs
                num_arguments = num_arguments-1; % test inputs adds one output artument to requested inputs
            end
            if sigerr_and_selected
                if num_arguments == 3 % one argument have been removed when calling this funtion
                    mode = bin_mode.sigerr_sel;
                    return
                else
                    if test_inputs
                        num_arguments = num_arguments+1;
                    end
                    error('HORACE:bin_mode:invalid_argument',...
                        'mode requesting to return "selectied" arguments needs 4 output arguments. Provided %d arguments', ...
                        num_arguments+1);
                end
            end
            if num_arguments == 1 && numel(varargin)<2 %  mode.npix_only may request 2 outputs and may contain second input (accumulator)
                num_arguments = 0; % assume 0 as an exception for npix_only mode
            end
            mode = bin_mode(num_arguments);
            if mode >= bin_mode.sigerr_cell % mode 4 and mode 3 both have 3 outputs and differ
                % by input arguments. All higher modes are defined by nargout+1 formula
                mode = bin_mode(num_arguments+1);
            end
            if mode == bin_mode.sig_err && ~isempty(varargin) && iscell(varargin{end}) % mode sig_err and sigerr_cell have equal number of outputs
                mode = bin_mode.sigerr_cell; % and differ by type of input
            end
            if ~ismember(uint32(mode),[0,2,3,4,5,6,7])
                error('HORACE:bin_mode:invalid_argument',...
                    'Binning modes return 1,3,4,5,6 or 7 output arguments. Provided: %d ', ...
                    num_arguments+1);
            end
        end
    end
end