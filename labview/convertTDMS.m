function [ConvertedData,ConvertVer,ChanNames,GroupNames,ci]=convertTDMS(varargin)
%Function to load LabView TDMS data file(s) into variables in the MATLAB workspace.
%An *.MAT file can also be created.  If called with one input, the user selects
%a data file.
%
%   TDMS format is based on information provided by National Instruments at:
%   http://zone.ni.com/devzone/cda/tut/p/id/5696
%
% [ConvertedData,ConvertVer,ChanNames]=convertTDMS(SaveConvertedFile,filename)
%
%       Inputs:
%               SaveConvertedFile (required) - Logical flag (true/false) that
%                 determines whether a MAT file is created.  The MAT file's name
%                 is the same as 'filename' except that the 'TDMS' file extension is
%                 replaced with 'MAT'.  The MAT file is saved in the same folder
%                 and will overwrite an existing file without warning.  The
%                 MAT file contains all the output variables.
%
%               filename (optional) - Filename (fully defined) to be converted.
%                 If not supplied, the user is provided a 'File Open' dialog box
%                 to navigate to a file.  Can be a cell array of files for bulk
%                 conversion.
%
%       Outputs:
%               ConvertedData (required) - Structure of all of the data objects.
%               ConvertVer (optional) - Version number of this function.
%               ChanNames (optional) - Cell array of channel names
%               GroupNames (optional) - Cell array of group names
%
%
%'ConvertedData' is a structure with 'FileName', 'FileFolder', 'SegTDMSVerNum',
%'NumOfSegments' and 'Data' fields'. The 'Data' field is a structure.
%
%'ConvertedData.SegTDMSVerNum' is a vector of the TDMS version number for each
%segment.
%
%'ConvertedData.Data' is a structure with 'Root' and 'MeasuredData' fields.
%
%'ConvertedData.Data.Root' is a structure with 'Name' and 'Property' fields.
%The 'Property' field is also a structure; it contains all the specified properties
%(1 entry for each 'Property) for the 'Root' group. For each 'Property' there are
%'Name' and 'Value' fields. To display a list of all the property names, input
%'{ConvertedData.Data.Root.Property.Name}'' in the Command Window.
%
%'ConvertedData.Data.MeasuredData' is a structure containing all the channel/group
%information. For each index (for example, 'ConvertedData.Data.MeasuredData(1)'),
%there are 'Name', 'Data' and 'Property' fields.  The list of channel names can
%be displayed by typing 'ChanNames' in the Command Window.  Similarly, the list
%of group names can be displayed by typing 'GroupNames' in the Command Window.
%The 'Property' field is also a structure; it contains all the specified properties
%for that index (1 entry in the structure for each 'Property'). Any LabView waveform
%attributes ('wf_start_time', 'wf_start_offset', 'wf_increment' and 'wf_samples') that
%may exist are also included in the properties. For each 'Property' there are 'Name'
%and 'Value' fields.  To display a list of all the property names, input
%'{ConvertedData.Data.MeasuredData(#).Property.Name}'' in the Command Window
%where '#' is the index of interest.
%

%-------------------------------------------------------------------------
%Brad Humphreys - v1.0 2008-04-23
%ZIN Technologies
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
%Brad Humphreys - v1.1 2008-07-03
%ZIN Technologies
%-Added abilty for timestamp to be a raw data type, not just meta data.
%-Addressed an issue with having a default nsmaples entry for new objects.
%-Added Error trap if file name not found.
%-Corrected significant problem where it was assumed that once an object
%    existsed, it would in in every subsequent segement.  This is not true.
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
%Grant Lohsen - v1.2 2009-11-15
%Georgia Tech Research Institute
%-Converts TDMS v2 files
%Folks, it's not pretty but I don't have time to make it pretty. Enjoy.
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
%Jeff Sitterle - v1.3 2010-01-10
%Georgia Tech Research Institute
%Modified to return all information stored in the TDMS file to inlcude
%name, start time, start time offset, samples per read, total samples, unit
%description, and unit string.  Also provides event time and event
%description in text form
%Vast speed improvement as save was the previous longest task
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
%Grant Lohsen - v1.4 2009-04-15
%Georgia Tech Research Institute
%Reads file header info and stores in the Root Structure.
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
%Robert Seltzer - v1.5 2010-07-14
%BorgWarner Morse TEC
%-Tested in MATLAB 2007b and 2010a.
%-APPEARS to now be compatible with TDMS version 1.1 (a.k.a 4712) files;
%	although, this has not been extensively tested.  For some unknown
%	reason, the version 1.2 (4713) files process noticeably faster. I think
%	that it may be related to the 'TDSm' tag.
%-"Time Stamp" data type was not tested.
%-"Waveform" fields was not tested.
%-Fixed an error in the 'LV2MatlabDataType' function where LabView data type
%	'tdsTypeSingleFloat' was defined as MATLAB data type 'float64' .  Changed
%	to 'float32'.
%-Added error trapping.
%-Added feature to count the number of segments for pre-allocation as
%	opposed to estimating the number of segments.
%-Added option to save the data in a MAT file.
%-Fixed "invalid field name" error caused by excessive string lengths.
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
%Robert Seltzer - v1.6 2010-09-01
%BorgWarner Morse TEC
%-Tested in MATLAB 2010a.
%-Fixed the "Coversion to cell from char is not possible" error found
%  by Francisco Botero in version 1.5.
%-Added capability to process both fragmented or defragmented data.
%-Fixed the "field" error found by Lawrence.
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
%Christian Buxel - V1.7 2010-09-17
%RWTH Aachen
%-Tested in Matlab2007b.
%-Added support for german umlauts (Ä,ä,Ö,ö,Ü,ü,ß) in 'propsName'
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
%André Rüegg - V1.7 2010-09-29
%Supercomputing Systems AG
%-Tested in MATLAB 2006a & 2010b
%-Make sure that data can be loaded correctly independently of character
% encoding set in matlab.
%-Fixed error if object consists of several segments with identical segment
% information (if rawdataindex==0, not all segments were loaded)
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
%Robert Seltzer - v1.7 2010-09-30
%BorgWarner Morse TEC
%-Tested in MATLAB 2010b.
%-Added 'error trapping' to the 'fixcharformatlab' function for group and
% channel names that contain characters that are not 'A' through 'Z',
% 'a' through 'z', 0 through 9 or underscore. The characters are replaced
% with an underscore and a message is written to the Command Window
% explaining to the user what has happened and how to fix it. Only tested
% with a very limited number of "special" characters.
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
%Robert Seltzer - v1.8 2010-10-12
%BorgWarner Morse TEC
%-As a result of an error found by Peter Sulcs when loading data with very
% long channel names, I have re-written the sections of the function that
% creates the channel and property names that are used within the body of
% the function to make them robust against long strings and strings
% containing non-UTF8 characters.  The original channel and property
% names (no truncation or character replacement) are now retained and
% included in the output structure.  In order to implement this improvement,
% I added a 'Property' field as a structure to the 'ConvertedData' output
% structure.
%-Added a more detailed 'help' description ('doc convertTDMS') of the
% returned structure.
%-List of channel names added as an output parameter of the function.
%-Corrected an error in the time stamp converion. It was off by exactly
% 1 hour.
%-Tested in MATLAB 2010b with a limited number of diverse TDMS files.
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
%Robert Seltzer - v1.8 2010-10-19
%BorgWarner Morse TEC
%-Fixed an error found by Terenzio Girotto with the 'save' routine.
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
%Robert Seltzer - v1.8 2010-10-25
%BorgWarner Morse TEC
%-Fixed an error with channels that contain no data.  Previously, if a
% channel contained no data, then it was not passed to the output structure
% even if it did contain properties.
%-Added 'GroupNames' as an optional output variable.
%-Fixed an error with capturing the properties of the Root object
%-------------------------------------------------------------------------


%-------------------------------------------------------------------------
%Philip Top - v1.9 2010-11-09
%John Breneman
%-restructured code as function calls
%-seperated metadata reads from data reads
%-preallocated space for SegInfo with two pass file read
%-preallocated index information and defined segdataoffset for each segment
%-preallocate space for data for speedup in case of fragmented files
%-used matlab input parser instead of nargin switch
%-vectorized timestamp reads for substantial speedup
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
%Robert Seltzer - v1.9 2010-11-10
%BorgWarner Morse TEC
%-Fixed an error error in the 'offset' calculation for strings
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
%Philip Top - v1.95 2011-5-10
%Fix Bug with out of order file segments
%Fix some issues with string array reads for newer version files, 
%-------------------------------------------------------------------------

%Initialize outputs
ConvertVer='1.95';    %Version number of this conversion function
ConvertedData=[];

p=inputParser();

p.addRequired('SaveConvertedFile',@(x) islogical(x)||(ismember(x,[0,1])));
p.addOptional('filename','',@(x) iscell(x)||exist(x,'file'));
p.parse(varargin{:});

filename=p.Results.filename;
SaveConvertedFile=p.Results.SaveConvertedFile;

if isempty(filename)
    
    %Prompt the user for the file
    [filename,pathname]=uigetfile({'*.tdms','All Files (*.tdms)'},'Choose a TDMS File');
    if filename==0
        return
    end
    filename=fullfile(pathname,filename);
end


if iscell(filename)
    %For a list of files
    infilename=filename;
else
    infilename=cellstr(filename);
end

for fnum=1:numel(infilename)
    
    if ~exist(infilename{fnum},'file')
        e=errordlg(sprintf('File ''%s'' not found.',infilename{fnum}),'File Not Found');
        uiwait(e)
        return
    end
    
    FileNameLong=infilename{fnum};
    [pathstr,name,ext]=fileparts(FileNameLong);
    FileNameShort=sprintf('%s%s',name,ext);
    FileNameNoExt=name;
    FileFolder=pathstr;
    
    if fnum==1
        fprintf('\n\n')
    end
    fprintf('Converting ''%s''...',FileNameShort)
    
    fid=fopen(FileNameLong);
    
    if fid==-1
        e=errordlg(sprintf('Could not open ''%s''.',FileNameLong),'File Cannot Be Opened');
        uiwait(e)
        fprintf('\n\n')
        return
    end
   
    [SegInfo,NumOfSeg]=getSegInfo(fid);
    channelinfo=getChannelInfo(fid,SegInfo,NumOfSeg);
    ob=getData(fid,channelinfo);
    fclose(fid);
    
    %Assign the outputs
    ConvertedData(fnum).FileName=FileNameShort;
    ConvertedData(fnum).FileFolder=FileFolder;
    
    ConvertedData(fnum).SegTDMSVerNum=SegInfo.vernum;
    ConvertedData(fnum).NumOfSegments=NumOfSeg;
    [ConvertedData(fnum).Data,CurrGroupNames]=postProcess(ob,channelinfo);
    
    GroupNames(fnum)={CurrGroupNames};
    
    TempChanNames={ConvertedData(fnum).Data.MeasuredData.Name};
    TempChanNames(strcmpi(TempChanNames,'Root'))=[];
    ChanNames(fnum)={sort(setdiff(TempChanNames',CurrGroupNames))};
    if SaveConvertedFile
        MATFileNameShort=sprintf('%s.mat',FileNameNoExt);
        MATFileNameLong=fullfile(FileFolder,MATFileNameShort);
        try
            save(MATFileNameLong,'ConvertedData','ConvertVer','ChanNames')
            fprintf('\n\nConversion complete (saved in ''%s'').\n\n',MATFileNameShort)
        catch exception
            fprintf('\n\nConversion complete (could not save ''%s'').\n\t%s: %s\n\n',MATFileNameShort,exception.identifier,...
                exception.message)
        end
    else
        fprintf('\n\nConversion complete.\n\n')
    end
end
ci=channelinfo;
end



function [SegInfo,NumOfSeg]=getSegInfo(fid)
%Count the number of segments.  While doing the count, also include error trapping.

%Find the end of the file
fseek(fid,0,'eof');
eoff=ftell(fid);
frewind(fid);

segCnt=0;
CurrPosn=0;
LeadInByteCount=28;	%From the National Instruments web page (http://zone.ni.com/devzone/cda/tut/p/id/5696) under
%the 'Lead In' description on page 2: Counted the bytes shown in the table.
while (ftell(fid) ~= eoff)
    
    Ttag=fread(fid,1,'uint8');
    Dtag=fread(fid,1,'uint8');
    Stag=fread(fid,1,'uint8');
    mtag=fread(fid,1,'uint8');
    
    if Ttag==84 && Dtag==68 && Stag==83 && mtag==109
        %Apparently, this sequence of numbers identifies the start of a new segment.
        
        segCnt=segCnt+1;
        
        %ToC Field
        ToC=fread(fid,1,'uint32');
        
        %TDMS format version number
        vernum=fread(fid,1,'uint32');
        
        %From the National Instruments web page (http://zone.ni.com/devzone/cda/tut/p/id/5696) under the 'Lead In'
        %description on page 2:
        %The next eight bytes (64-bit unsigned integer) describe the length of the remaining segment (overall length of the
        %segment minus length of the lead in). If further segments are appended to the file, this number can be used to
        %locate the starting point of the following segment. If an application encountered a severe problem while writing
        %to a TDMS file (crash, power outage), all bytes of this integer can be 0xFF. This can only happen to the last
        %segment in a file.
        nlen=fread(fid,1,'uint64');
        if (nlen>2^63)
            break;
        else
            
            segLength=nlen;
        end
        TotalLength=segLength+LeadInByteCount;
        CurrPosn=CurrPosn+TotalLength;
        
        status=fseek(fid,CurrPosn,'bof');		%Move to the beginning position of the next segment
        if (status<0)
            warning('file glitch');
            break;
        end
    end
    
end

frewind(fid);

CurrPosn=0;
SegInfo.SegStartPosn=zeros(segCnt,1);
SegInfo.MetaStartPosn=zeros(segCnt,1);
SegInfo.DataStartPosn=zeros(segCnt,1);
SegInfo.vernum=zeros(segCnt,1);
SegInfo.DataLength=zeros(segCnt,1);
segCnt=0;
while (ftell(fid) ~= eoff)
    
    Ttag=fread(fid,1,'uint8');
    Dtag=fread(fid,1,'uint8');
    Stag=fread(fid,1,'uint8');
    mtag=fread(fid,1,'uint8');
    
    if Ttag==84 && Dtag==68 && Stag==83 && mtag==109
        %Apparently, this sequence of numbers identifies the start of a new segment.
        
        segCnt=segCnt+1;
        
        if segCnt==1
            StartPosn=0;
        else
            StartPosn=CurrPosn;
        end
        
        %ToC Field
        ToC=fread(fid,1,'uint32');
        kTocMetaData=bitget(ToC,2);
        kTocNewObject=bitget(ToC,3);
        kTocRawData=bitget(ToC,4);
        kTocInterleavedData=bitget(ToC,6);
        kTocBigEndian=bitget(ToC,7);
        
        if kTocInterleavedData
            e=errordlg(sprintf(['Seqment %.0f within ''%s'' has interleaved data which is not supported with this '...
                'function (%s.m).'],segCnt,TDMSFileNameShort,mfilename),'Interleaved Data Not Supported');
            fclose(fid);
            uiwait(e)
        end
        
        if kTocBigEndian
            e=errordlg(sprintf(['Seqment %.0f within ''%s'' uses the big-endian data format which is not supported '...
                'with this function (%s.m).'],segCnt,TDMSFileNameShort,mfilename),'Big-Endian Data Format Not Supported');
            fclose(fid);
            uiwait(e)
        end
        
        %TDMS format version number
        vernum=fread(fid,1,'uint32');
        if ~ismember(vernum,[4712,4713])
            e=errordlg(sprintf(['Seqment %.0f within ''%s'' used LabView TDMS file format version %.0f which is not '...
                'supported with this function (%s.m).'],segCnt,TDMSFileNameShort,vernum,mfilename),...
                'TDMS File Format Not Supported');
            fclose(fid);
            uiwait(e)
        end
        
        %From the National Instruments web page (http://zone.ni.com/devzone/cda/tut/p/id/5696) under the 'Lead In'
        %description on page 2:
        %The next eight bytes (64-bit unsigned integer) describe the length of the remaining segment (overall length of the
        %segment minus length of the lead in). If further segments are appended to the file, this number can be used to
        %locate the starting point of the following segment. If an application encountered a severe problem while writing
        %to a TDMS file (crash, power outage), all bytes of this integer can be 0xFF. This can only happen to the last
        %segment in a file.
        segLength=fread(fid,1,'uint64');
        metaLength=fread(fid,1,'uint64');
        if (segLength>2^63)
            fseek(fid,0,'eof');
            flen=ftell(fid);
            segLength=flen-LeadInByteCount-TotalLength;
            TotalLength=segLength+LeadInByteCount;
        else
            TotalLength=segLength+LeadInByteCount;
            CurrPosn=CurrPosn+TotalLength;
            fseek(fid,CurrPosn,'bof');		%Move to the beginning position of the next segment
        end
        
        
        SegInfo.SegStartPosn(segCnt)=StartPosn;
        SegInfo.MetaStartPosn(segCnt)=StartPosn+LeadInByteCount;
        SegInfo.DataStartPosn(segCnt)=SegInfo.MetaStartPosn(segCnt)+metaLength;
        SegInfo.DataLength(segCnt)=segLength-metaLength;
        SegInfo.vernum(segCnt)=vernum;
        
    end
    
end
NumOfSeg=segCnt;
end



function index=getChannelInfo(fid,SegInfo,NumOfSeg)
%Initialize variables for the file conversion
index=struct();
objOrderList={};
for segCnt=1:NumOfSeg
    
    fseek(fid,SegInfo.SegStartPosn(segCnt)+4,'bof');
    
    %Ttag=fread(fid,1,'uint8');
    %Dtag=fread(fid,1,'uint8');
    %Stag=fread(fid,1,'uint8');
    %mtag=fread(fid,1,'uint8');
    
    %ToC Field
    ToC=fread(fid,1,'uint32');
    kTocMetaData=bitget(ToC,2);
    kTocNewObjectList=bitget(ToC,3);
    kTocRawData=bitget(ToC,4);
    %kTocInterleavedData=bitget(ToC,6);
    %kTocBigEndian=bitget(ToC,7);
    
    segVersionNum=fread(fid,1,'uint32');							%TDMS format version number for this segment
    
    segLength=fread(fid,1,'uint64');
    
    metaLength=fread(fid,1,'uint64');
    offset=0;
    %Process Meta Data
    if (kTocNewObjectList==0) %use the object list from the previous segment
        fnm=fieldnames(index);
        for kk=1:length(fnm)
            ccnt=index.(fnm{kk}).rawdatacount;
            if (ccnt>0)
                if (index.(fnm{kk}).index(ccnt)==segCnt-1)
                    ccnt=ccnt+1;
                    index.(fnm{kk}).rawdatacount=ccnt;
                    index.(fnm{kk}).datastartindex(ccnt)=SegInfo.DataStartPosn(segCnt);
                    index.(fnm{kk}).arrayDim(ccnt)=index.(fnm{kk}).arrayDim(ccnt-1);
                    index.(fnm{kk}).nValues(ccnt)=index.(fnm{kk}).nValues(ccnt-1);
                    index.(fnm{kk}).byteSize(ccnt)=index.(fnm{kk}).byteSize(ccnt-1);
                    index.(fnm{kk}).index(ccnt)=segCnt;
                    index.(fnm{kk}).rawdataoffset(ccnt)=index.(fnm{kk}).rawdataoffset(ccnt-1);
                end
            end
        end
    end
    
    if kTocMetaData
        numObjInSeg=fread(fid,1,'uint32');
        if (kTocNewObjectList)
            objOrderList=cell(numObjInSeg,1);
        end
        for q=1:numObjInSeg
            
            obLength=fread(fid,1,'uint32');								%Get the length of the objects name
            ObjName=convertToText(fread(fid,obLength,'uint8'))';	%Get the objects name
            
            if strcmp(ObjName,'/')
                long_obname='Root';
            else
                long_obname=ObjName;
                
                %Delete any apostrophes.  If the first character is a slash (forward or backward), delete it too.
                long_obname(strfind(long_obname,''''))=[];
                if strcmpi(long_obname(1),'/') || strcmpi(long_obname(1),'\')
                    long_obname(1)=[];
                end
            end
            newob=0;
            %Create object's name.  Use a generic field name to avoid issues with strings that are too long and/or
            %characters that cannot be used in MATLAB variable names.  The actual channel name is retained for the final
            %output structure.
            if exist('ObjNameList','var')
                %Check to see if the object already exists
                NameIndex=find(strcmpi({ObjNameList.LongName},long_obname)==1,1,'first');
                if isempty(NameIndex)
                    newob=1;
                    %It does not exist, so create the generic name field name
                    ObjNameList(end+1).FieldName=sprintf('Object%.0f',numel(ObjNameList)+1);
                    ObjNameList(end).LongName=long_obname;
                    NameIndex=numel(ObjNameList);
                end
            else
                %No objects exist, so create the first one using a generic name field name.
                ObjNameList.FieldName='Object1';
                ObjNameList.LongName=long_obname;
                NameIndex=1;
                newob=1;
            end
            %Assign the generic field name
            obname=ObjNameList(NameIndex).FieldName;
            
            %Create the 'index' structure
            if (~isfield(index,obname))
                index.(obname).name=obname;
                index.(obname).long_name=long_obname;
                index.(obname).rawdatacount=0;
                index.(obname).datastartindex=zeros(NumOfSeg,1);
                index.(obname).arrayDim=zeros(NumOfSeg,1);
                index.(obname).nValues=zeros(NumOfSeg,1);
                index.(obname).byteSize=zeros(NumOfSeg,1);
                index.(obname).index=zeros(NumOfSeg,1);
                index.(obname).rawdataoffset=zeros(NumOfSeg,1);
                index.(obname).multiplier=ones(NumOfSeg,1);
                index.(obname).skip=zeros(NumOfSeg,1);
            end
            if (kTocNewObjectList)
                objOrderList{q}=obname;
            else
                if ~ismember(obname,objOrderList)
                    objOrderList{end+1}=obname;
                end
            end
            %Get the raw data Index
            rawdataindex=fread(fid,1,'uint32');
            
            if rawdataindex==0
                if segCnt==0
                    e=errordlg(sprintf('Seqment %.0f within ''%s'' has ''rawdataindex'' value of 0 (%s.m).',segCnt,...
                        TDMSFileNameShort,mfilename),'Incorrect ''rawdataindex''');
                    uiwait(e)
                end
                if kTocRawData
                    if (kTocNewObjectList)
                        ccnt=index.(obname).rawdatacount+1;
                    else
                        ccnt=index.(obname).rawdatacount;
                    end
                    index.(obname).rawdatacount=ccnt;
                    index.(obname).datastartindex(ccnt)=SegInfo.DataStartPosn(segCnt);
                    index.(obname).arrayDim(ccnt)=index.(obname).arrayDim(ccnt-1);
                    index.(obname).nValues(ccnt)=index.(obname).nValues(ccnt-1);
                    index.(obname).byteSize(ccnt)=index.(obname).byteSize(ccnt-1);
                    index.(obname).index(ccnt)=segCnt;
                    
                end
            elseif rawdataindex+1==2^32
                %Objects raw data index matches previous index - no changes.  The root object will always have an
                %'FFFFFFFF' entry
                if strcmpi(index.(obname).long_name,'Root')
                    index.(obname).rawdataindex=0;
                else
                    %Need to account for the case where an object (besides the 'root') is added that has no data but reports
                    %using previous.
                    if newob
                        index.(obname).rawdataindex=0;
                    else
                        if kTocRawData
                            if (kTocNewObjectList)
                                ccnt=index.(obname).rawdatacount+1;
                            else
                                ccnt=index.(obname).rawdatacount;
                            end
                            index.(obname).rawdatacount=ccnt;
                            index.(obname).datastartindex(ccnt)=SegInfo.DataStartPosn(segCnt);
                            index.(obname).arrayDim(ccnt)=index.(obname).arrayDim(ccnt-1);
                            index.(obname).nValues(ccnt)=index.(obname).nValues(ccnt-1);
                            index.(obname).byteSize(ccnt)=index.(obname).byteSize(ccnt-1);
                            index.(obname).index(ccnt)=segCnt;
                            
                        end
                    end
                end
            else
                %Get new object information
                if (kTocNewObjectList)
                    ccnt=index.(obname).rawdatacount+1;
                else
                    ccnt=index.(obname).rawdatacount;
                    if (ccnt==0)
                        ccnt=1;
                    end
                end
                index.(obname).rawdatacount=ccnt;
                index.(obname).datastartindex(ccnt)=SegInfo.DataStartPosn(segCnt);
                %index(end).lenOfIndexInfo=fread(fid,1,'uint32');
                
                index.(obname).dataType=fread(fid,1,'uint32');
                if (index.(obname).dataType~=32)
                    index.(obname).datasize=getDataSize(index.(obname).dataType);
                end
                index.(obname).arrayDim(ccnt)=fread(fid,1,'uint32');
                index.(obname).nValues(ccnt)=fread(fid,1,'uint64');
                index.(obname).index(ccnt)=segCnt;
                if index.(obname).dataType==32
                    %Datatype is a string
                    index.(obname).byteSize(ccnt)=fread(fid,1,'uint64');
                else
                    index.(obname).byteSize(ccnt)=0;
                end
                
            end
            
            %Get the properties
            numProps=fread(fid,1,'uint32');
            if numProps>0
                
                if isfield(index.(obname),'PropertyInfo')
                    PropertyInfo=index.(obname).PropertyInfo;
                else
                    clear PropertyInfo
                end
                for p=1:numProps
                    propNameLength=fread(fid,1,'uint32');
                    switch 1
                        case 1
                            PropName=fread(fid,propNameLength,'*uint8')';
                            PropName=native2unicode(PropName,'UTF-8');
                        case 2
                            PropName=fread(fid,propNameLength,'uint8=>char')';
                        otherwise
                    end
                    propsDataType=fread(fid,1,'uint32');
                    
                    %Create property's name.  Use a generic field name to avoid issues with strings that are too long and/or
                    %characters that cannot be used in MATLAB variable names.  The actual property name is retained for the
                    %final output structure.
                    if exist('PropertyInfo','var')
                        %Check to see if the property already exists for this object.  Need to get the existing 'PropertyInfo'
                        %structure for this object.  The 'PropertyInfo' structure is not necessarily the same for every
                        %object in the data file.
                        PropIndex=find(strcmpi({PropertyInfo.Name},PropName));
                        if isempty(PropIndex)
                            %Is does not exist, so create the generic name field name
                            propExists=false;
                            PropIndex=numel(PropertyInfo)+1;
                            propsName=sprintf('Property%.0f',PropIndex);
                            PropertyInfo(PropIndex).Name=PropName;
                            PropertyInfo(PropIndex).FieldName=propsName;
                        else
                            %Assign the generic field name
                            propExists=true;
                            propsName=PropertyInfo(PropIndex).FieldName;
                        end
                    else
                        %No properties exist for this object, so create the first one using a generic name field name.
                        propExists=false;
                        PropIndex=p;
                        propsName=sprintf('Property%.0f',PropIndex);
                        PropertyInfo(PropIndex).Name=PropName;
                        PropertyInfo(PropIndex).FieldName=propsName;
                    end
                    dataExists=isfield(index.(obname),'data');
                    
                    if dataExists
                        %Get number of data samples for the object in this segment
                        nsamps=index.(obname).nsamples+1;
                    else
                        nsamps=0;
                    end
                    
                    if propsDataType==32
                        %String data type
                        PropertyInfo(PropIndex).DataType='String';
                        propsValueLength=fread(fid,1,'uint32');
                        propsValue=convertToText(fread(fid,propsValueLength,'uint8=>char'))';
                        if propExists
                            if isfield(index.(obname).(propsName),'cnt')
                                cnt=index.(obname).(propsName).cnt+1;
                            else
                                cnt=1;
                            end
                            index.(obname).(propsName).cnt=cnt;
                            index.(obname).(propsName).value{cnt}=propsValue;
                            index.(obname).(propsName).samples(cnt)=nsamps;
                        else
                            if strcmp(index.(obname).long_name,'Root')
                                %Header data
                                index.(obname).(propsName).name=index.(obname).long_name;
                                index.(obname).(propsName).value={propsValue};
                                index.(obname).(propsName).cnt=1;
                            else
                                index.(obname).(propsName).name=PropertyInfo(PropIndex).Name;
                                index.(obname).(propsName).datatype=PropertyInfo(PropIndex).DataType;
                                index.(obname).(propsName).cnt=1;
                                index.(obname).(propsName).value=cell(nsamps,1);		%Pre-allocation
                                index.(obname).(propsName).samples=zeros(nsamps,1);	%Pre-allocation
                                if iscell(propsValue)
                                    index.(obname).(propsName).value(1)=propsValue;
                                else
                                    index.(obname).(propsName).value(1)={propsValue};
                                end
                                index.(obname).(propsName).samples(1)=nsamps;
                            end
                        end
                    else
                        %Numeric data type
                        if propsDataType==68
                            PropertyInfo(PropIndex).DataType='Time';
                            %Timestamp data type
                            tsec=fread(fid,1,'uint64')/2^64+fread(fid,1,'uint64');	%time since Jan-1-1904 in seconds
                            %R. Seltzer: Not sure why '5/24' (5 hours) is subtracted from the time value.  That's how it was
                            %coded in the original function I downloaded from MATLAB Central.  But I found it to be 1 hour too
                            %much.  So, I changed it to '4/24'.
                            %propsValue=tsec/86400+695422-5/24;	%/864000 convert to days; +695422 days from Jan-0-0000 to Jan-1-1904
                            propsValue=tsec/86400+695422-4/24;	%/864000 convert to days; +695422 days from Jan-0-0000 to Jan-1-1904
                        else
                            PropertyInfo(PropIndex).DataType='Numeric';
                            matType=LV2MatlabDataType(propsDataType);
                            if strcmp(matType,'Undefined')
                                e=errordlg(sprintf('No MATLAB data type defined for a ''Property Data Type'' value of ''%.0f''.',...
                                    propsDataType),'Undefined Property Data Type');
                                uiwait(e)
                                fclose(fid);
                                return
                            end
                            if strcmp(matType,'uint8=>char')
                                propsValue=convertToText(fread(fid,1,'uint8'));
                            else
                                propsValue=fread(fid,1,matType);
                            end
                        end
                        if propExists
                            cnt=index.(obname).(propsName).cnt+1;
                            index.(obname).(propsName).cnt=cnt;
                            index.(obname).(propsName).value(cnt)=propsValue;
                            index.(obname).(propsName).samples(cnt)=nsamps;
                        else
                            index.(obname).(propsName).name=PropertyInfo(PropIndex).Name;
                            index.(obname).(propsName).datatype=PropertyInfo(PropIndex).DataType;
                            index.(obname).(propsName).cnt=1;
                            index.(obname).(propsName).value=NaN(nsamps,1);				%Pre-allocation
                            index.(obname).(propsName).samples=zeros(nsamps,1);		%Pre-allocation
                            index.(obname).(propsName).value(1)=propsValue;
                            index.(obname).(propsName).samples(1)=nsamps;
                        end
                    end
                    
                end	%'end' for the 'Property' loop
                index.(obname).PropertyInfo=PropertyInfo;
                
            end
            
        end	%'end' for the 'Objects' loop
    end
    
    %Move the offset calculation to the end to account for added channels and other optimizations
    if (kTocRawData) %only do the check if there was raw data in the segment
        offset=0;
        for kk=1:numel(objOrderList)
            obname=objOrderList{kk};
            ccnt=index.(obname).rawdatacount;
            if (ccnt>0)
                index.(obname).rawdataoffset(ccnt)=offset;
                if index.(obname).dataType==32
                    %Datatype is a string
                    offset=offset+index.(obname).byteSize(ccnt);
                else
                    offset=offset+index.(obname).nValues(ccnt)*index.(obname).datasize;
                end
            end
        end
        
        %Don't know why but sometimes the 'nValues' parameter is sometimes incorrect. Either the documentation was wrong or
        %someone who wrote the drivers was lazy. Seems to happen with waveform files. Check to make sure that the final
        %offset value matches the segment's size.  If it doesn't, then check if the size is a multiple of the offset.  If
        %it is, then multiply all appropriate parameters in the index structure.  If not, then generate a warning.
        if (offset~=SegInfo.DataLength(segCnt))
            %if (mod(SegInfo.DataLength(segCnt),offset)==0)
            multiplier=floor(SegInfo.DataLength(segCnt)/offset);
            for kk=1:numel(objOrderList)
                obname=objOrderList{kk};
                ccnt=index.(obname).rawdatacount;
                if (ccnt>0)&&(index.(obname).index(ccnt)==segCnt);
                    index.(obname).multiplier(ccnt)=multiplier;
                    if index.(obname).dataType==32
                        %Datatype is a string
                        index.(obname).skip(ccnt)=offset-index.(obname).byteSize(ccnt);
                    else
                        index.(obname).skip(ccnt)=offset-index.(obname).nValues(ccnt)*index.(obname).datasize;
                    end
                end
            end
            % else
            %    warning('segment %d error: offset=%d, dataLength=%d\n',segCnt,offset,SegInfo.DataLength(segCnt));
            % end
        end
    end
    
end
%clean up the index if it has to much data
fnm=fieldnames(index);
for kk=1:numel(fnm)
    ccnt=index.(fnm{kk}).rawdatacount+1;
    
    index.(fnm{kk}).datastartindex(ccnt:end)=[];
    index.(fnm{kk}).arrayDim(ccnt:end)=[];
    index.(fnm{kk}).nValues(ccnt:end)=[];
    index.(fnm{kk}).byteSize(ccnt:end)=[];
    index.(fnm{kk}).index(ccnt:end)=[];
    index.(fnm{kk}).rawdataoffset(ccnt:end)=[];
    index.(fnm{kk}).multiplier(ccnt:end)=[];
    index.(fnm{kk}).skip(ccnt:end)=[];
    
end
end



function ob=getData(fid,index)
ob=[];
fnm=fieldnames(index);
for kk=1:length(fnm)
    id=index.(fnm{kk});
    nsamples=sum(id.nValues.*id.multiplier);
    if id.rawdatacount>0
        cname=id.name;
        ob.(cname).nsamples=0;
        if id.dataType==32
            ob.(cname).data=cell(nsamples,1);
        else
            ob.(cname).data=zeros(nsamples,1);
        end
        for rr=1:id.rawdatacount
            %Loop through each of the groups/channels and read the raw data
            fseek(fid,id.datastartindex(rr)+id.rawdataoffset(rr),'bof');
            
            
            nvals=id.nValues(rr);
            
            if nvals>0
                
                switch id.dataType
                    
                    case 32		%String
                        %From the National Instruments web page (http://zone.ni.com/devzone/cda/tut/p/id/5696) under the
                        %'Raw Data' description on page 4:
                        %String type channels are preprocessed for fast random access. All strings are concatenated to a
                        %contiguous piece of memory. The offset of the first character of each string in this contiguous piece
                        %of memory is stored to an array of unsigned 32-bit integers. This array of offset values is stored
                        %first, followed by the concatenated string values. This layout allows client applications to access
                        %any string value from anywhere in the file by repositioning the file pointer a maximum of three times
                        %and without reading any data that is not needed by the client.
                        data=cell(1,nvals*id.multiplier(rr));	%Pre-allocation
                        for mm=1:id.multiplier(rr)
                            StrOffsetArray=fread(fid,nvals,'uint32');
                            for dcnt=1:nvals
                                if dcnt==1
                                    StrLength=StrOffsetArray(dcnt);
                                else
                                    StrLength=StrOffsetArray(dcnt)-StrOffsetArray(dcnt-1);
                                end
                                data{1,dcnt+(mm-1)*nvals}=char(convertToText(fread(fid,StrLength,'uint8=>char'))');
                            end
                            if (id.multiplier(rr)>1)&&(id.skip(rr)>0)
                                fseek(fid,id.skip(rr),'cof');
                            end
                        end
                        cnt=nvals*id.multiplier(rr);
                        
                    case 68		%Timestamp
                        %data=NaN(1,nvals);	%Pre-allocation
                        data=NaN(1,nvals*id.multiplier(rr));
                        for mm=1:id.multiplier(rr)
                            dn=fread(fid,2*nvals,'uint64');
                            tsec=dn(1:2:end)/2^64+dn(2:2:end);
                            data((mm-1)*nvals+1:(mm)*nvals)=tsec/86400+695422-4/24;
                            fseek(fid,id.skip(rr),'cof');
                        end
                        %{
						for dcnt=1:nvals
							tsec=fread(fid,1,'uint64')/2^64+fread(fid,1,'uint64');   %time since Jan-1-1904 in seconds
							%R. Seltzer: Not sure why '5/24' (5 hours) is subtracted from the time value.  That's how it was
							%coded in the original function I downloaded from MATLAB Central.  But I found it to be 1 hour too
							%much.  So, I changed it to '4/24'.
							data(1,dcnt)=tsec/86400+695422-5/24;	%/864000 convert to days; +695422 days from Jan-0-0000 to Jan-1-1904
							data(1,dcnt)=tsec/86400+695422-4/24;	%/864000 convert to days; +695422 days from Jan-0-0000 to Jan-1-1904
						end
                        %}
                        cnt=nvals*id.multiplier(rr);
                        
                    otherwise	%Numeric
                        matType=LV2MatlabDataType(id.dataType);
                        if strcmp(matType,'Undefined')
                            e=errordlg(sprintf('No MATLAB data type defined for a ''Raw Data Type'' value of ''%.0f''.',...
                                id.dataType),'Undefined Raw Data Type');
                            uiwait(e)
                            fclose(fid);
                            return
                        end
                        if (id.skip(rr)>0)
                            ntype=sprintf('%d*%s',nvals,matType);
                            if strcmp(matType,'uint8=>char')
                                [data,cnt]=fread(fid,nvals*id.multiplier(rr),ntype,id.skip(rr));
                                data=convertToText(data);
                            else
                                [data,cnt]=fread(fid,nvals*id.multiplier(rr),ntype,id.skip(rr));
                            end
                        else
                            [data,cnt]=fread(fid,nvals*id.multiplier(rr),matType);
                        end
                end
                
                if isfield(ob.(cname),'nsamples')
                    ssamples=ob.(cname).nsamples;
                else
                    ssamples=0;
                end
                if (cnt>0)
                    ob.(cname).data(ssamples+1:ssamples+cnt,1)=data;
                    ob.(cname).nsamples=ssamples+cnt;
                end
            end
        end
        
    end
    
end
end




function [DataStructure,GroupNames]=postProcess(ob,index)
%Re-organize the 'ob' structure into a more user friendly format for output.


DataStructure.Root=[];
DataStructure.MeasuredData.Name=[];
DataStructure.MeasuredData.Data=[];

obFieldNames=fieldnames(index);

cntData=1;

for i=1:numel(obFieldNames)
    
    cname=obFieldNames{i};
    
    if strcmp(index.(cname).long_name,'Root')
        
        DataStructure.Root.Name=index.(cname).long_name;
        
        %Assign all the 'Property' values
        if isfield(index.(cname),'PropertyInfo')
            for p=1:numel(index.(cname).PropertyInfo)
                cfield=index.(cname).PropertyInfo(p).FieldName;
                if isfield(index.(cname).(cfield),'datatype')
                    DataType=index.(cname).(cfield).datatype;
                else
                    %ASSUME a 'string' data type
                    DataType='String';
                end
                DataStructure.Root.Property(p).Name=index.(cname).PropertyInfo(p).Name;
                
                switch DataType
                    case 'String'
                        if iscell(index.(cname).(cfield).value)
                            Value=index.(cname).(cfield).value';
                        else
                            Value=cellstr(index.(cname).(cfield).value);
                        end
                        
                    case 'Time'
                        clear Value
                        if index.(cname).(cfield).cnt==1
                            if iscell(index.(cname).(cfield).value)
                                Value=datestr(cell2mat(index.(cname).(cfield).value),'dd-mmm-yyyy HH:MM:SS');
                            else
                                Value=datestr(index.(cname).(cfield).value,'dd-mmm-yyyy HH:MM:SS');
                            end
                        else
                            Value=cell(index.(cname).(cfield).cnt,1);
                            for c=1:index.(cname).(cfield).cnt
                                if iscell(index.(cname).(cfield).value)
                                    Value(c)={datestr(cell2mat(index.(cname).(cfield).value),'dd-mmm-yyyy HH:MM:SS')};
                                else
                                    Value(c)={datestr(index.(cname).(cfield).value,'dd-mmm-yyyy HH:MM:SS')};
                                end
                            end
                        end
                        
                    case 'Numeric'
                        if isfield(index.(cname).(cfield),'cnt')
                            Value=NaN(index.(cname).(cfield).cnt,1);
                        else
                            if iscell(index.(cname).(cfield).value)
                                Value=NaN(numel(cell2mat(index.(cname).(cfield).value)),1);
                            else
                                Value=NaN(numel(index.(cname).(cfield).value),1);
                            end
                        end
                        for c=1:numel(Value)
                            if iscell(index.(cname).(cfield).value)
                                Value(c)=index.(cname).(cfield).value{c};
                            else
                                Value(c)=index.(cname).(cfield).value(c);
                            end
                        end
                    otherwise
                        e=errordlg(sprintf(['No format defined for Data Type ''%s'' in the private function ''postProcess'' '...
                            'within %s.m.'],index.(cname).(cfield).datatype,mfilename),'Undefined Property Data Type');
                        uiwait(e)
                        return
                end
                if isempty(Value)
                    DataStructure.Root.Property(p).Value=[];
                else
                    DataStructure.Root.Property(p).Value=Value;
                end
            end
        end
        
        
    end
    
    DataStructure.MeasuredData(cntData).Name=index.(cname).long_name;
    %Should only need the 'ShortName' for debugging the function
    %DataStructure.MeasuredData(cntData).ShortName=cname;
    if (isfield(ob,cname))
        if isfield(ob.(cname),'data')
            DataStructure.MeasuredData(cntData).Data=ob.(cname).data;
            %The following field is redundant because the information can be obtained from the size of the 'Data' field.
            DataStructure.MeasuredData(cntData).Total_Samples=ob.(cname).nsamples;
        else
            DataStructure.MeasuredData(cntData).Data=[];
            DataStructure.MeasuredData(cntData).Total_Samples=0;
        end
    else
        DataStructure.MeasuredData(cntData).Data=[];
        DataStructure.MeasuredData(cntData).Total_Samples=0;
    end
    
    %Assign all the 'Property' values
    if isfield(index.(cname),'PropertyInfo')
        for p=1:numel(index.(cname).PropertyInfo)
            cfield=index.(cname).PropertyInfo(p).FieldName;
            DataStructure.MeasuredData(cntData).Property(p).Name=index.(cname).(cfield).name;
            
            if strcmpi(DataStructure.MeasuredData(cntData).Property(p).Name,'Root')
                Value=index.(cname).(cfield).value;
            else
                
                switch index.(cname).(cfield).datatype
                    case 'String'
                        clear Value
                        if index.(cname).(cfield).cnt==1
                            if iscell(index.(cname).(cfield).value)
                                Value=char(index.(cname).(cfield).value);
                            else
                                Value=index.(cname).(cfield).value;
                            end
                        else
                            Value=cell(index.(cname).(cfield).cnt,1);
                            for c=1:index.(cname).(cfield).cnt
                                if iscell(index.(cname).(cfield).value)
                                    Value(c)=index.(cname).(cfield).value;
                                else
                                    Value(c)={index.(cname).(cfield).value};
                                end
                            end
                        end
                        
                    case 'Time'
                        clear Value
                        if index.(cname).(cfield).cnt==1
                            if iscell(index.(cname).(cfield).value)
                                Value=datestr(cell2mat(index.(cname).(cfield).value),'dd-mmm-yyyy HH:MM:SS');
                            else
                                Value=datestr(index.(cname).(cfield).value,'dd-mmm-yyyy HH:MM:SS');
                            end
                        else
                            Value=cell(index.(cname).(cfield).cnt,1);
                            for c=1:index.(cname).(cfield).cnt
                                if iscell(index.(cname).(cfield).value)
                                    Value(c)={datestr(cell2mat(index.(cname).(cfield).value),'dd-mmm-yyyy HH:MM:SS')};
                                else
                                    Value(c)={datestr(index.(cname).(cfield).value,'dd-mmm-yyyy HH:MM:SS')};
                                end
                            end
                        end
                        
                    case 'Numeric'
                        if isfield(index.(cname).(cfield),'cnt')
                            Value=NaN(index.(cname).(cfield).cnt,1);
                        else
                            if iscell(index.(cname).(cfield).value)
                                Value=NaN(numel(cell2mat(index.(cname).(cfield).value)),1);
                            else
                                Value=NaN(numel(index.(cname).(cfield).value),1);
                            end
                        end
                        for c=1:numel(Value)
                            if iscell(index.(cname).(cfield).value)
                                Value(c)=index.(cname).(cfield).value{c};
                            else
                                Value(c)=index.(cname).(cfield).value(c);
                            end
                        end
                        
                    otherwise
                        e=errordlg(sprintf(['No format defined for Data Type ''%s'' in the private function ''postProcess'' '...
                            'within %s.m.'],index.(cname).(cfield).datatype,mfilename),'Undefined Property Data Type');
                        uiwait(e)
                        return
                end
            end
            if isempty(Value)
                DataStructure.MeasuredData(cntData).Property(p).Value=[];
            else
                DataStructure.MeasuredData(cntData).Property(p).Value=Value;
            end
        end
    else
        DataStructure.MeasuredData(cntData).Property=[];
    end
    
    cntData = cntData + 1;
end %'end' for the 'groups/channels' loop

%Extract the Group names
GroupIndices=false(numel(DataStructure.MeasuredData),1);
for d=1:numel(DataStructure.MeasuredData)
    
    if ~strcmpi(DataStructure.MeasuredData(d).Name,'Root')
        if (DataStructure.MeasuredData(d).Total_Samples==0)
            fs=strfind(DataStructure.MeasuredData(d).Name,'/');
            if (isempty(fs))
                GroupIndices(d)=true;
            end
        end
    end
    
end
if any(GroupIndices)
    GroupNames=sort({DataStructure.MeasuredData(GroupIndices).Name})';
else
    GroupNames=[];
end

end

function sz=getDataSize(LVType)
switch(LVType)
    case 0
        sz=0;
    case {1,5,33}
        sz=1;
    case 68
        sz=16;
    case {8,10}
        sz=8;
    case {3,7,9}
        sz=4;
    case {2,6}
        sz=2;
    case 32
        e=errordlg('Do not call the getDataSize function for strings.  Their size is written in the data file','Error');
        uiwait(e)
        sz=NaN;
    case 11
        sz=10;
end
end




function matType=LV2MatlabDataType(LVType)
%Cross Refernce Labview TDMS Data type to MATLAB
switch LVType
    case 0   %tdsTypeVoid
        matType='';
    case 1   %tdsTypeI8
        matType='int8';
    case 2   %tdsTypeI16
        matType='int16';
    case 3   %tdsTypeI32
        matType='int32';
    case 4   %tdsTypeI64
        matType='int64';
    case 5   %tdsTypeU8
        matType='uint8';
    case 6   %tdsTypeU16
        matType='uint16';
    case 7   %tdsTypeU32
        matType='uint32';
    case 8   %tdsTypeU64
        matType='uint64';
    case 9  %tdsTypeSingleFloat
        matType='single';
    case 10  %tdsTypeDoubleFloat
        matType='double';
    case 11  %tdsTypeExtendedFloat
        matType='10*char';
    case 25 %tdsTypeSingleFloat with units
        matType='Undefined';
    case 26 %tdsTypeDoubleFloat with units
        matType='Undefined';
    case 27 %tdsTypeextendedFloat with units
        matType='Undefined';
    case 32  %tdsTypeString
        matType='uint8=>char';
    case 33  %tdsTypeBoolean
        matType='bit1';
    case 68  %tdsTypeTimeStamp
        matType='2*int64';
    otherwise
        matType='Undefined';
end

end


function text=convertToText(bytes)
%Convert numeric bytes to the character encoding localy set in MATLAB (TDMS uses UTF-8)

text=native2unicode(bytes,'UTF-8');
end