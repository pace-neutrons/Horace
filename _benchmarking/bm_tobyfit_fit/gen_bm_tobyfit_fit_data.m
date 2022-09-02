function sqw_obj = gen_bm_tobyfit_fit_data(nDims,dataInfo,dataSet)
%GEN_BM_TOBYFIT_FIT_DATA This function generates the data needed to run
%benchmarks of fit()
% Using either a saved sqw object or generating an sqw using
% gen_dummy_sqw_data(), this funciton generates N cuts of sqw objects to
% fit.
% Inputs:
%
%   nDims       dimensions of the sqw objects: [1,2 or 3]
%   dataInfo    info about the original sqw objects to combine:
%               [char: 'small','medium' or 'large' (10^7,10^6 and 10^9
%               pixels), an integer from 6-10] or a filepath to an existing
%               sqw file
%   dataSet     the amount of sqw objects in the array:
%               [char: 'small', 'medium' or 'large' (2, 4 and 8 files 
%               respectively) or a numeric amount]
%
% Output:
%   sqw_obj     array of sqw objects to fit

% Check if there is alredy an exisiting sqw object to use, otherwise
% generate it

    dataSource = gen_dummy_sqw_data(dataInfo);
    
    proj.u=[1,0,0]; proj.v=[0,1,0]; proj.type='rrr';
    switch nDims
        case 1
            p1_bin=[-3,0.05,3];p2_bin=[-2.1,-1.9];p3_bin=[-0.5,0.5];p4_bin=[0,175];
            main_sqw=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
        case 2
            p1_bin=[-3,0.05,3];p2_bin=[-3,0];p3_bin=[-0.5,0.5];p4_bin=[0,16,350];
            main_sqw=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
        case 3
            p1_bin=[-3,0.05,3];p2_bin=[-3,0.05,3];p3_bin=[-1,1];p4_bin=[0,16,700];
            main_sqw=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
        case 4
            main_sqw=sqw(dataSource);
        otherwise
            error("HORACE:gen_bm_tobyfit_fit_data:invalid_argument"...
                ,"nDims is the dimensions of the cuts : must be 1, 2 or 3 ")
    end
    
    % Instrument and sample information
    efix=50;
    instrument = let_instrument_obj_for_tests(efix, 280, 140, 20, 2, 2);
    sample = IX_sample(true,[1,1,0],[0,0,1],'cuboid',[0.012,0.012,0.04]);
    sample.alatt = [2.87 2.87 2.87];
    sample.angdeg = [90 90 90];
    main_sqw = set_instrument(main_sqw, instrument);
    main_sqw = set_sample (main_sqw, sample);
    
    % dataSet for small, medium and large set to 1, 3 and 6 to get a look
    % at effects of scaling linearly (was originally 1, 4 and 8 but was
    % changed due to memory issues
    switch dataSet
        case 'small'
            sqw_obj=repmat(main_sqw,1,1);
        case 'medium'
            sqw_obj = repmat(main_sqw,1,3);
        case 'large'
            sqw_obj = repmat(main_sqw,1,6);
        otherwise
            try
                sqw_obj = repmat(main_sqw, 1, dataSet);
            catch
                error("HORACE:gen_bm_tobyfit_fit_data:invalid_argument"...
                    ,"dataSet is the number of sets : must be small, medium, " + ...
                    "large (char) or numeric")
            end
    end

end