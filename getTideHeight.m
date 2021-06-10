function tideHeights=getTideHeight(port,t)
% Get tide heights for TotalTide port at specified times (rounded to nearest minute)
%
% This function is a wrapper for TotalTide.getStationHeights, which
% yields regularly-spaced time-series data. It loops through each unique
% day of the specified times, determines the relevant time spacing for that day, and then
% calls TotalTide.getStationHeights.
%
% As such, it is useful for obtaining tide heights for irregular time-series. By
% calling getStationHeights for each day, we can avoid getting dates for
% gaps in the time period, and adapt to changes in sample frequency. 
%
% INPUTS:
% port - TotalTide port interface
% t    - datenums for which to obtain tide heights
%
% OUTPUTS:
% tideHeights - column vector of tide heights for port at specified times, in metres
%
% EXAMPLE:
% port=TotalTide.portFinder('Glasgow')
% h=TotalTide.getTideHeight(port,now) % tide height now
% h=TotalTide.getTideHeight(port,ceil(now)+rand(100,1)) % 100 random times tomorrow
%
% For regularly spaced data, getStationHeights is of course a bit faster than this function,
% but not hugely: 83s vs 90s to get a year's worth of 15 minute-spaced data
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   getTideHeight.m  $
% $Revision:   1.0  $
% $Author:   ted.schlicke  $
% $Date:   Apr 29 2016 15:42:02  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin<2
    help TotalTide.getTideHeight
    return
end

minutesPerDay=24*60;

% Round input times to nearest minute
dv=datevec(t);
secs=dv(:,6); % seconds column
secs=60*round(secs/60); % round to nearest minute
dv(:,end)=secs; % update seconds column
tMinutes=datenum(dv); % generate datenums rounded to nearest minute
[tUniqueMinutes,~,ic]=unique(tMinutes); % Only need to get heights for unique values

% Extract unique days (we'll extract tide data a day at a time)
tDays=floor(tUniqueMinutes);
tUniqueDays=unique(tDays,'stable'); % Don't reorder unique values if times aren't sequential
NDays=length(tUniqueDays);

% Allocate space for storing tide heights
tideHeights=cell(NDays,1);
% Loop through unique days
for dayIndex=1:NDays
    iday=tUniqueDays(dayIndex);
    % Extract rounded times from this day:
    k=iday==tDays;
    ti=tUniqueMinutes(k);
    % Find minutes since midnight- use this to determine time-spacing for
    % Total Tide
    frac=round(minutesPerDay*rem(ti,1));
    if length(frac)>1
        ttTimeStep=gcds(frac); % greatest common divisor
    elseif frac>0
        ttTimeStep=frac;
    else
        ttTimeStep=minutesPerDay; % midnight- so only need one value
    end
    ttData=TotalTide.getStationHeights(port,datestr(iday,'dd/mm/yyyy)'),1,ttTimeStep);
    % Map TotalTide times to times for this day:
    [k,ind]=ismember(ti,ttData.time);
    if ~all(k)
        error('Unmatched times!') % hopefully won't get here!
    end
    % Store heights for this day in cell array
    tideHeights{dayIndex}=reshape(ttData.height(ind),[],1); %
end
% Convert cell array to numeric:
tideHeights=vertcat(tideHeights{:});
% Map to original times:
tideHeights=tideHeights(ic);
% and we're done!
end