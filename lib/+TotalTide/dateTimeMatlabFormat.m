function [ matlabDateTime ] = dateTimeMatlabFormat( totalTideDateTime )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   dateTimeMatlabFormat.m  $
% $Revision:   1.1  $
% $Author:   ted.schlicke  $
% $Date:   May 28 2014 12:23:00  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This function converts the datetime strings from a format native to
    % TotalTide to the default MATLAB format
    %
    % Usage:
    % TotalTides.dateTimeMatlabFormat(totalTideDateTime) 
    %   where totalTideDateTime is a datetime string in the format 
    %   'DD/MM/YYYY HH:MM:SS' (or 'DD/MM/YYYY' for midnight times).
    %
    % OUTPUT:
    %    A string describing a datetime in the format 'DD-MMM-YYYY'
    %
    % EXAMPLES:
    %
    %    ttDate   = '10/12/2010';
    %    mtlbDate = TotalTide.dateTimeMatlabFormat(ttDate)
    %        -> '10-Dec-2010'
    %
    % DEPENDENCIES:
    % This function requires a working, authorised installation of Admiralty
    % TotalTide.
    %
    % The function also calls 
    %  - TotalTide.datenum.m
    
    if nargin==0
      help TotalTide.dateTimeMatlabFormat
      return
    end


    % Convert to datenum, then back to datestring using the implied
    % MATLAB default format
    matlabDateTime = datestr(TotalTide.datenum(totalTideDateTime));
end

