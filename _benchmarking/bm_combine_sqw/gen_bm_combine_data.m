function [cut1, cutN] = gen_bm_combine_data(nDims,dataFile,dataSize,dataSet)
%GEN_BM_COMBINE_SQW This funciton generates the data needed to run
%benchmarks of combine_sqw()
% Using either a saved sqw object or generating an sqw using
% gen_fake_sqw_data(), this funciton generates N cuts of sqw objects to
% combine.
% Inputs:
%
%   nDims       dimensions of the sqw objects to combine: [1,2 or 3]
%   dataFile    filepath to a saved sqw object or empty string
%   dataSize    size of the original sqw objects to combine:
%               [char: 'small','medium' or 'large' (10^7,10^6 and 10^9
%               pixels) or an integer from 6-10]
%   dataSet     the amount of sqw objects to combine:
%               [char: 'small', 'medium' or 'large' (2, 4 and 8 files 
%               respectively) or a numeric amount]
%
% Output:
%   cut1        initial sqw obj to combine
%   cutN        array of N sqw objects

if is_file(dataFile)
          dataSource=dataFile;
else
    switch dataSize
        case 'small'
            dataSource = gen_fake_sqw_data(7);
        case 'medium'
            dataSource = gen_fake_sqw_data(8);
        case 'large'
            dataSource = gen_fake_sqw_data(9);
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
        p1_bin=[-3,0.05,3];p2_bin=[-2.1,-1.9];p3_bin=[-0.5,0.5];p4_bin=[0,175];
    case 2
        p1_bin=[-3,0.05,3];p2_bin=[-3,0];p3_bin=[-0.5,0.5];p4_bin=[0,16,350];
    case 3
        p1_bin=[-3,0.05,3];p2_bin=[-3,0.05,3];p3_bin=[-1,1];p4_bin=[0,16,700];
    otherwise
        error("HORACE:test_combine_sqw_smallData:gen_bm_data:invalid_argument"...
            ,"nDims is the dimensions of the cuts to combine: must be 1, 2 or 3 ")
end

proj.u=[1,0,0]; proj.v=[0,1,0]; proj.type='rrr';
% Generate inital cut of sqw object
cut1=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
disp("Cut has: " + cut1.npixels + " pixels")
% Generate additional cuts to combine, doubling number of pixels of the
% additonal cuts
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