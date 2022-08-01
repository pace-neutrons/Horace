function sqw_obj = gen_bm_sqw_eval_data(nDims,dataSource,dataSize,dataSet,objType)
%GEN_BM_SQW_EVAL_DATA Summary of this function goes here
%   Detailed explanation goes here

pths = horace_paths;
proj.u=[1,0,0]; proj.v=[0,1,0]; proj.type='rrr';

switch dataSize
  case 'small'
      if isfile(dataSource)
      else
          gen_fake_sqw_data(6)
          dataSource = fullfile(pths.bm_common,'NumData6.sqw');
      end
  case 'medium'
      if isfile(dataSource)
      else
          gen_fake_sqw_data(7)
          dataSource = fullfile(pths.bm_common,'NumData7.sqw');
      end
    case 'large'
      if isfile(dataSource)
      else
          gen_fake_sqw_data(8)
          dataSource = fullfile(pths.bm_common,'NumData8.sqw');
      end
    otherwise
        try
            gen_fake_sqw_data(dataSize)
            filenameStr= "Numdata" + num2str(dataSize) + ".sqw";
            filenameChar = char(filenameStr);
            dataSource=fullfile(pths.bm_common,filenameChar);
        catch
            error("HORACE:gen_bm_data:invalid_argument"...
                ,"dataSize is the size of the sqw object : must be small, " + ...
                "medium, large (char type) or numeric (from 1 to 9)")
        end
end

switch true
    case nDims==1 && objType=="sqw"
        p1_bin=[-3,0.05,3];p2_bin=[1.9,2.1];p3_bin=[-0.1,0.1];p4_bin=[0,175];
        sqw_dnd=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
    case nDims==2 && objType=="sqw"
        p1_bin=[-3,0.05,3];p2_bin=[-2.1,-1.9];p3_bin=[-0.1,0.1];p4_bin=[0,16,350];
        sqw_dnd=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
    case nDims==3 && objType=="sqw"
        p1_bin=[-3,0.05,3];p2_bin=[-3,0.05,3];p3_bin=[-0.1,0.1];p4_bin=[0,16,700];
        sqw_dnd=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin);
    case nDims==1 && objType=="dnd"
        p1_bin=[-3,0.05,3];p2_bin=[1.9,2.1];p3_bin=[-0.1,0.1];p4_bin=[0,175];
        sqw_dnd=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin,'-nopix');
    case nDims==2 && objType=="dnd"
        p1_bin=[-3,0.05,3];p2_bin=[-2.1,-1.9];p3_bin=[-0.1,0.1];p4_bin=[0,16,350];
        sqw_dnd=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin,'-nopix');
    case nDims==3 && objType=="dnd"
        p1_bin=[-3,0.05,3];p2_bin=[-3,0.05,3];p3_bin=[-0.1,0.1];p4_bin=[0,16,700];
        sqw_dnd=cut_sqw(dataSource,proj,p1_bin,p2_bin,p3_bin,p4_bin,'-nopix');
    otherwise
        error("HORACE:gen_bm_data:invalid_argument"...
            ,"nDims is the dimensions of the cuts : must be 1, 2 or 3 ")
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
