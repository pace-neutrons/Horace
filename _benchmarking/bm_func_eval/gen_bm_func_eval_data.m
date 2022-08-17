function sqw_obj = gen_bm_func_eval_data(nDims,dataFile,dataSize,dataSet)
%GEN_BM_FUNC_EVAL_DATA This funciton generates the data needed to run
%benchmarks of func_eval()
% Using either a saved sqw object or generating an sqw using
% gen_fake_sqw_data(), this funciton generates N cuts of sqw objects to
% combine.
% Inputs:
%
%   nDims       dimensions of the sqw objects: [1,2 or 3]
%   dataFile    filepath to a saved sqw object or else empty string
%   dataSize    size of the original sqw objects:
%               [char: 'small','medium' or 'large' (10^6,10^7 and 10^8
%               pixels) or an integer from 5-9.]
%   dataSet     the amount of sqw objects in the array:
%               [char: 'small', 'medium' or 'large' (2, 4 and 8 files 
%               respectively) or a numeric amount]
%
% Output:
%   sqw_obj     array of sqw objects

% Check if there is alredy an exisiting sqw object to use, otherwise
% generate it
if is_file(dataFile)
      dataSource=dataFile;
else
    switch dataSize
        case 'small'
            dataSource = gen_fake_sqw_data(6);
        case 'medium'
            dataSource = gen_fake_sqw_data(7);
        case 'large'
            dataSource = gen_fake_sqw_data(8);
        otherwise
            try
                dataSource = gen_fake_sqw_data(dataSize);
            catch
                error("HORACE:gen_bm_data:invalid_argument"...
                    ,"dataSize is the size of the sqw object : must be small, " + ...
                    "medium, large (char type) or numeric (from 1 to 9)")
            end
    end
end

proj.u=[1,0,0]; proj.v=[0,1,0]; proj.type='rrr';
% Generate cuts of the given sqw objects
switch nDims
    case 1
        p1_bin=[-3,0.05,3];p2_bin=[-2.1,-1.9];p3_bin=[-0.1,0.1];p4_bin=[0,175];
        main_sqw = cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
    case 2
        p1_bin=[-3,0.05,3];p2_bin=[-2.1,-1.9];p3_bin=[-0.1,0.1];p4_bin=[0,16,350];
        main_sqw = cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
    case 3
        p1_bin=[-3,0.05,3];p2_bin=[-3,0.05,3];p3_bin=[-0.1,0.1];p4_bin=[0,16,700];
        main_sqw = cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
    case 4
        main_sqw = sqw(dataSource);
    otherwise
        error("HORACE:gen_bm_data:invalid_argument"...
            ,"nDims is the dimensions of the cuts : must be 1, 2, 3 or 4.")
end

% Build array of sqw objects
switch dataSet
    case 'small'
        sqw_obj=main_sqw;
    case 'medium'
        sqw_obj = repmat(main_sqw,1,4);
    case 'large'
        sqw_obj = repmat(main_sqw,1,8);
    otherwise
        try
            sqw_obj = repmat(main_sqw,1,dataSet);
        catch
            error("HORACE:gen_bm_data:invalid_argument"...
                ,"dataSet is the number of sets : must be small, medium, " + ...
                "large (char) or numeric")
        end
end

end
