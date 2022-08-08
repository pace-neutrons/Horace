function [cut1, cutN] = gen_bm_combine_data(nDims,dataFile,dataSize,dataSet)
%GEN_BM_COMBINE_SQW Summary of this function goes here
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
                error("HORACE:gen_bm_data:invalid_argument"...
                    ,"dataSize is the size of the sqw object : must be small, " + ...
                    "medium, large (char type) or numeric (from 1 to 9)")
            end
    end
end

switch nDims
    case 1
        p1_bin=[-3,0.05,3];p2_bin=[1.9,2.1];p3_bin=[-0.1,0.1];p4_bin=[0,175];
    case 2
        p1_bin=[-3,0.05,3];p2_bin=[-2.1,-1.9];p3_bin=[-0.1,0.1];p4_bin=[0,16,350];
    case 3
        p1_bin=[-3,0.05,3];p2_bin=[-3,0.05,3];p3_bin=[-0.1,0.1];p4_bin=[0,16,700];
    otherwise
        error("HORACE:test_combine_sqw_smallData:gen_bm_data:invalid_argument"...
            ,"nDims is the dimensions of the cuts to combine: must be 1, 2 or 3 ")
end

proj.u=[1,0,0]; proj.v=[0,1,0]; proj.type='rrr';
cut1=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);

switch dataSet
    case 'small'
        cutN=copy(cut1);
        cutN.data.pix.signal = 2*cut1.data.pix.signal;
    case 'medium'
        cut2 = cut1;
        cut2.data.pix.signal = 2*cut1.data.pix.signal;
        cutN=repmat(cut2,1,3);
    case 'large'
        cut2 = cut1;
        cut2.data.pix.signal = 2*cut1.data.pix.signal;
        cutN=repmat(cut2,1,7);
    otherwise
        try
            cut2 = cut1;
            cut2.data.pix.signal = 2*cut1.data.pix.signal;
            cutN=repmat(cut2,1,dataSet);
        catch
            error("HORACE:gen_bm_data:invalid_argument"...
                ,"dataSet is the number of sets : must be small, medium, " + ...
                "large (char) or numeric")
        end
end
end