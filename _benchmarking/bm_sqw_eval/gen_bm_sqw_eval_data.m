function sqw_obj = gen_bm_sqw_eval_data(nDims,dataFile,dataSize,dataSet,objType)
%GEN_BM_SQW_EVAL_DATA Summary of this function goes here
%   Detailed explanation goes here

proj.u=[1,0,0]; proj.v=[0,1,0]; proj.type='rrr';

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
                error("HORACE:gen_bm_sqw_eval_data:invalid_argument"...
                    ,"dataSize is the size of the sqw object : must be small, " + ...
                    "medium, large (char type) or numeric (from 1 to 9)")
            end
    end
end

if objType == "sqw"
    switch nDims
        case 1
            p1_bin=[-3,0.05,3];p2_bin=[1.9,2.1];p3_bin=[-0.1,0.1];p4_bin=[0,175];
            sqw_dnd=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
        case 2
            p1_bin=[-3,0.05,3];p2_bin=[-2.1,-1.9];p3_bin=[-0.1,0.1];p4_bin=[0,16,350];
            sqw_dnd=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
        case 3
            p1_bin=[-3,0.05,3];p2_bin=[-3,0.05,3];p3_bin=[-0.1,0.1];p4_bin=[0,16,700];
            sqw_dnd=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
        case 4
            sqw_dnd=sqw(dataSource);
        otherwise
            error("HORACE:gen_bm_sqw_eval_data:invalid_argument"...
                ,"nDims is the dimensions of the cuts : must be 1, 2, 3 or 4")
    end

elseif objType == "dnd"
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
else
    error("HORACE:gen_bm_sqw_eval_data:invalid_argument", ...
        "objType must be either sqw or dnd (string type)")
end

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