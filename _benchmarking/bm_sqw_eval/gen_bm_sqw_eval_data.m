function sqw_obj = gen_bm_sqw_eval_data(nDims,dataInfo,dataSet,objType)
%GEN_BM_SQW_EVAL_DATA This funciton generates the data needed to run
%benchmarks of sqw_eval()
% Using either a saved sqw object or generating an sqw using
% gen_fake_sqw_data(), this funciton generates N cuts of sqw objects.
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
%   objType     type of object [string: "sqw" or "dnd"], case insensitive
%
% Output:
%   sqw_obj     array of sqw objects

% Check if there is alredy an exisiting sqw object to use, otherwise
% generate it
    dataSource = gen_fake_sqw_data(dataInfo);
    
    % Generate cuts of the given sqw or dnd objects
    proj.u=[1,0,0]; proj.v=[0,1,0]; proj.type='rrr';
    
    % using lower() to make objType input case insensitive
    objType=lower(objType);
    
    switch objType
        case "sqw"
            switch nDims
                case 1
                    p1_bin=[-3,0.05,3];p2_bin=[-2.1,-1.9];p3_bin=[-0.5,0.5];p4_bin=[0,175];
                    sqw_dnd=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
                case 2
                    p1_bin=[-3,0.05,3];p2_bin=[-3,0];p3_bin=[-0.5,0.5];p4_bin=[0,16,350];
                    sqw_dnd=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
                case 3
                    p1_bin=[-3,0.05,3];p2_bin=[-3,0.05,3];p3_bin=[-1,1];p4_bin=[0,16,700];
                    sqw_dnd=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
                case 4
                    sqw_dnd=sqw(dataSource);
                otherwise
                    error("HORACE:gen_bm_sqw_eval_data:invalid_argument"...
                        ,"nDims is the dimensions of the cuts : must be 1, 2, 3 or 4")
            end
        case "dnd"
            switch nDims
                case 1
                    p1_bin=[-3,0.05,3];p2_bin=[1.9,2.1];p3_bin=[-0.1,0.1];p4_bin=[0,175];
                    sqw_dnd=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin,'-nopix');
                case 2
                    p1_bin=[-3,0.05,3];p2_bin=[-2.1,-1.9];p3_bin=[-0.1,0.1];p4_bin=[0,16,350];
                    sqw_dnd=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin,'-nopix');
                case 3
                    p1_bin=[-3,0.05,3];p2_bin=[-3,0.05,3];p3_bin=[-0.1,0.1];p4_bin=[0,16,700];
                    sqw_dnd=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin,'-nopix');
                case 4
                    sqw_dnd=d4d(dataSource);
                otherwise
                    error("HORACE:gen_bm_sqw_eval_data:invalid_argument"...
                        ,"nDims is the dimensions of the cuts : must be 1, 2, 3 or 4")
            end
    
        otherwise
            error("HORACE:gen_bm_sqw_eval_data:invalid_argument", ...
                "objType must be either sqw or dnd (string type)")
    end
    
    % Build array of sqw/dnd objects
    switch dataSet
        case 'small'
            sqw_obj=sqw_dnd;
        case 'medium'
            sqw_obj = repmat(sqw_dnd,1,4);
        case 'large'
            sqw_obj = repmat(sqw_dnd,1,8);
        otherwise
            try
                sqw_obj = repmat(sqw_dnd, 1, dataSet);
            catch
                error("HORACE:gen_bm_data:invalid_argument"...
                    ,"dataSet is the number of sets : must be small, medium, " + ...
                    "large (char) or numeric")
            end
    end
end