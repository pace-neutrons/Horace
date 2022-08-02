function [cut1, cutN] = gen_bm_combine_data(nDims,dataSource, dataSize,dataSet)

pths = horace_paths;
common_data = pths.bm_common;
proj.u=[1,0,0]; proj.v=[0,1,0]; proj.type='rrr';

switch dataSize
  case 'small'
      if isfile(dataSource)
      else
          gen_fake_sqw_data(6)
          dataSource = fullfile(common_data,'NumData6.sqw');
      end
  case 'medium'
      if isfile(dataSource)
      else
          gen_fake_sqw_data(7)
          dataSource = fullfile(common_data,'NumData7.sqw');
      end
    case 'large'
      if isfile(dataSource)
      else
          gen_fake_sqw_data(8)
          dataSource = fullfile(common_data,'NumData8.sqw');
      end
    otherwise
        try
            gen_fake_sqw_data(dataSize)
            filenameStr= "Numdata" + num2str(dataSize) + ".sqw";
            filenameChar = char(filenameStr);
            dataSource=fullfile(common_data,filenameChar);
        catch
            error("HORACE:gen_bm_data:invalid_argument"...
                ,"dataSize is the size of the sqw object : must be small, " + ...
                "medium, large (char type) or numeric (from 1 to 9)")
        end
end

switch nDims
    case 1
        p1_bin=[-3,0.05,3];p2_bin=[1.9,2.1];p3_bin=[-0.1,0.1];p4_bin=[0,175];
    case 2
        p1_bin=[-3,0.05,3];p2_bin=[-2.1,-1.9];p3_bin=[-0.1,0.1];p4_bin=[0,16,350];
    otherwise
        error("HORACE:test_combine_sqw_smallData:gen_bm_data:invalid_argument"...
            ,"nDims is the dimensions of the cuts to combine: must be 1 or 2 ")
end

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
