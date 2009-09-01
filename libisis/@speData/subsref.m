function varargout = subsref(this,index)
% accessor to the internal data of the speData class
%% $Revision: 259 $ ($Date: 2009-08-18 13:03:04 +0100 (Tue, 18 Aug 2009) $)
switch index(1).type
    case '.'
        switch index(1).subs
            case 'nDetectors'
                varargout={this.nDetectors};
            case 'nEnergyBins'
                varargout={this.nEnergyBins};
            case 'fileDir'
                varargout={this.fileDir};
            case 'fileName'
                varargout={[this.fileName this.fileExt]};
            case 'en'
                varargout={this.en};
            case 'S'
                if(~this.data_loaded)                
                    this=loadSPEdata(this);                   
                end
                varargout={this.S};                
            case 'ERR'
                if(~this.data_loaded)
                    this=loadSPEdata(this);                                      
                end
                varargout={this.ERR};                
            otherwise
                error('speData:Indexing_Error',...
                ['index refers to nonexisitng field or a privat variable'
                 index(1).subs] );
        end
    otherwise
        error('speData:Indexing_Error',['unsupported index type'
                 index(1).type ' for this class'] );
end
    
  if length(varargout)>1 && nargout <=1
      if (iscellstr(vavargout) || any([cellfun('isempty',varargout)]))
          varargout={varargout};
      else
          try
              varargout={[varargout{:}]};
          catch
              varargout={varargout};
          end
      end
  end
end