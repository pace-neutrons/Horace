function [wout, wsym] = cut_sqw_sym_main_single (data_source,...
    main_header, header, detpar, data, npixtot, pix_position,...
    proj, pbin, pin, en, sym, opt, hor_log_level)
% Take a cut with symmetry operations from an sqw object by integrating over one or more axes.
%
% Currently a poor man's implementation, in that it performs each cut, holds in
% memory and combines once all symmetry related cuts have been performed.
%
% In the case of '-nopix' option, repeated pixels are not removed either. This
% is a stop-gap until the correct algorithm is implemented, but is provided
% for the case when there is not enough memory to combine the cuts in sqw
% format prior to using dnd to convert.


% Original author: T.G.Perring
%
% $Revision:: 1757 ($Date:: 2019-12-05 14:56:06 +0000 (Thu, 5 Dec 2019) $)


if isempty(sym)
    % -----------------------
    % Only one cut to perform
    % -----------------------
    % If save file is requested, this is dealt with in cut_sqw_main_single
    if nargout==0
        cut_sqw_main_single (data_source,...
            main_header, header, detpar, data, npixtot, pix_position,...
            proj, pbin, pin, en, opt, hor_log_level);
    else
        wout = cut_sqw_main_single (data_source,...
            main_header, header, detpar, data, npixtot, pix_position,...
            proj, pbin, pin, en, opt, hor_log_level);
        if nargout==2
            wsym = wout;
        end
    end
    
else
    % ------------------------
    % Multiple cuts to combine
    % ------------------------
    wtmp = cell(1,numel(sym)+1);
    opt_tmp = opt;
    opt_tmp.outfile = '';   % do not want to save the intermediate cuts
    %
    % Primary cut without symmetry transformation
    proj_trans = proj; pbin_trans = pbin;
    wtmp{1} = cut_sqw_main_single (data_source,...
        main_header, header, detpar, data, npixtot, pix_position,...
        proj_trans, pbin_trans, pin, en, opt_tmp, hor_log_level);
    % Create output wsym array of required length
    % wsym = [wsym;repmat(eval(class(wsym)),numel(sym),1)];
    
    % Reverse engineer the full projection and binning descriptor from the
    % primary cut for reference in later loops
    [proj_ref, pbin_ref] = get_proj_and_pbin (wtmp{1});
    
    % Inefficient wsy of catching if non-orthogonal projection because Alex's
    % projection class does not retain this property of projaxes
    if proj_ref.nonorthogonal
        error('CUT_SQW_SYM:not_implemented',...
            'Symmetrised cuts are not yet implemented for nonorthogonal axes')
    end
    
    % Store some parameters for later loops
    header_ave=header_average(header);
    alatt = header_ave.alatt;
    angdeg = header_ave.angdeg;
    upix_to_rlu = header_ave.u_to_rlu(1:3,1:3);
    upix_offset = header_ave.uoffset;
    
    
    for i=2:numel(sym)+1
        % Transform primary cut binning and projection
        [ok, mess, proj_trans, pbin_trans] = transform_proj (sym{i-1},...
            alatt, angdeg, proj_ref, pbin_ref);
        if ~ok, error(mess), end
        % Get some 'average' quantities for use in calculating transformations and bin boundaries
        % -----------------------------------------------------------------------------------------
        % *** assumes that all the contributing spe files had the same lattice parameters and projection axes
        % This could be generalised later - but with repercussions in many routines
        header_ave=header_average(header);
        
        
        % Because Alex's aProjection class (of which proj is an instance)
        % is a rather odd hybrid object with projection and cut information
        % in its public and private properties, regenerate this class
        % with the information for input cut projection information in the
        % same way that was done by cut_sqw_check_pbins in cut_sqw_sym_main
        proj_trans=projection(proj_trans);
        [proj_trans, ~, ~, pin, en] = proj_trans.update_pbins(header_ave, data,pbin_trans);
        
        %[ok,mess,proj_trans] = cut_sqw_check_pbins (header_ave, data,...
        %   proj_trans, pbin_trans);
        
        
        
        wtmp{i} = cut_sqw_main_single (data_source,...
            main_header, header, detpar, data, npixtot, pix_position,...
            proj_trans, pbin_trans, pin, en, opt_tmp, hor_log_level);
        % Transform pixels
        if isa(wtmp{i},'sqw')
            wtmp{i}.data.pix(1:3,:) = transform_pix (sym{i-1},...
                upix_to_rlu, upix_offset, wtmp{i}.data.pix(1:3,:));
        end
        
    end
    
    % Merge cuts
    % ----------
    % Take account of duplicated pixels if sqw cuts; if dnd cuts, then duplicated
    % pixels cannot be accounted for, although the weighting by number of pixels is correct
    if hor_log_level>0
        disp('Combining symmetry related cuts...')
    end
    
    if isa(wtmp{1},'sqw')
        wout = combine_sqw_same_bins (wtmp{:});
    else
        wout = combine_dnd_same_bins (wtmp{:});
    end
    
    if nargout==2
        wsym = repmat(eval(class(wtmp{1})),numel(wtmp),1);
        for i=1:numel(wtmp)
            wsym(i)=wtmp{i};
        end
    end
    
    if hor_log_level>0
        disp('--------------------------------------------------------------------------------')
    end
    
    % Save to file if requested
    % ---------------------------
    if ~isempty(opt.outfile)
        save (wout, opt.outfile);
    end
    
end


% %=================================================================================================
% function [proj, pbin] = get_proj_and_pbin (w)
% % Reverse engineer the projection and binning of a cut. Works for dnd and sqw
% % objects
%
% if isa(w,'sqw')
%     data = w.data;
% else
%     data = w;
% end
%
% % Get projection
% % --------------------------
% % Projection axes
% proj.u = data.u_to_rlu(1:3,1)';
% proj.v = data.u_to_rlu(1:3,2)';
% proj.w = data.u_to_rlu(1:3,3)';
%
% % Determine if projection is orthogonal or not
% b = bmatrix(data.alatt, data.angdeg);
% ux = b*proj.u';
% vx = b*proj.v';
% nx = cross(ux,vx); nx = nx/norm(nx);
% wx = b*proj.w'; wx = wx/norm(wx);
% if abs(cross(nx,wx))>1e-10
%     proj.nonorthogonal = true;
% else
%     proj.nonorthogonal = false;
% end
%
% proj.type = 'ppp';
%
% proj.uoffset = data.uoffset';
%
% % Get binning
% % -------------------------
% pbin=cell(1,4);
% for i=1:numel(data.pax)
%     pbin{data.pax(i)} = pbin_from_p(data.p{i});
% end
% for i=1:numel(data.iax)
%     pbin{data.iax(i)} = data.iint(:,i)';
% end
%
% %------------------------------------------------------------------------------
% function pbin = pbin_from_p (p)
% % Get 1x3 binning description from equally spaced bin boundaries
% pbin = [(p(1)+p(2))/2, (p(end)-p(1))/(numel(p)-1), (p(end-1)+p(end))/2];

