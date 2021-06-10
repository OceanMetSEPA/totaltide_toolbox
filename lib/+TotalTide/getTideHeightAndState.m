function tideInfo=getTideHeightAndState(port,t,numericDateTime)
% Get tide heights /state for TotalTide port at specified times (rounded to nearest minute)
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
% Optional Input:
% numericDateTime [false] - return dates as datenums (as opposed to strings)
%
% OUTPUT:
% struct with fields:
%   Port - name of TotalTide port
%   DateTime - input time (to nearest minute)
%   Height - tide height (m)
%   Flooding - logical value (1 = flooding; 0 = ebbing)
%   Previous - time of previous slack tide
%   Next - time of next slack tide
%   Frac - fraction through tidal cycle (from previous to next slack tides)
%   Springiness - value between 0 and 1 estimating tidal range based on
%   moon phase (0 = neaps, 1 = springs)
%
% EXAMPLE:
% port=TotalTide.portFinder('Glasgow')
% h=TotalTide.getTideHeight(port,now) % tide height now
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   getTideHeightAndState.m  $
% $Revision:   1.0  $
% $Author:   Ted.Schlicke  $
% $Date:   Jul 02 2020 15:14:22  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin<2
    help TotalTide.getTideHeightAndState
    return
end
if nargin<3
    numericDateTime=false;
end
ndp=3; % round height / frac / springiness to this number of decimal places

minutesPerDay=24*60;
%portName=capitaliseWords(lower(get(port,'Name')));
portName=get(port,'Name');
% Round input times to nearest minute
dv=datevec(t);
secs=dv(:,6); % seconds column
secs=60*round(secs/60); % round to nearest minute
dv(:,end)=secs; % update seconds column
tMinutes=datenum(dv); % generate datenums rounded to nearest minute
[tUniqueMinutes,~,~]=unique(tMinutes); % Only need to get heights for unique values

% Extract unique days (we'll extract tide data a day at a time)
tDays=floor(tUniqueMinutes);
tUniqueDays=unique(tDays,'stable'); % Don't reorder unique values if times aren't sequential
NDays=length(tUniqueDays);

% Allocate space for storing tide heights
tideInfo=cell(NDays,1);
% Loop through unique days
for dayIndex=1:NDays
    iday=tUniqueDays(dayIndex);
    tstr=datestr(iday,'dd/mm/yyyy');
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
    ttData=TotalTide.getStationHeights(port,tstr,1,ttTimeStep);
    % Map TotalTide times to times for this day:
    %    [k,ind]=ismember(ti,ttData.time);
    %    if ~all(k)
    %        error('Unmatched times!') % hopefully won't get here!
    %    end
    k=ismember(ttData.time,ti);
    ttData=structFilter(ttData,k,'value');
    % Store heights for this day in cell array
    %    tideHeights{dayIndex}=reshape(ttData.height,[],1); %
    % FLOOD / EBB. Need to find slack heights from previous day for times
    % shortly after midnight...
    tstr=datestr(iday-1,'dd/mm/yyyy');
    hl=TotalTide.getStationSlackHeights(port,tstr,3);
    k=arrayfun(@(i)find(ttData.time(i)>hl.time,1,'last'),1:length(ttData.time)); % previous tidal extreme index
    flooding=hl.highWater(k)==0; % true if previous tidal extreme was low water
    prev=hl.time(k);
    next=hl.time(k+1);
    frac=roundn((ttData.time-prev)./(next-prev),-ndp);
    si=struct('Port',cellstr(repmat(portName,length(ttData.time),1)),'DateTime',num2cell(ttData.time)','Height',num2cell(roundn(ttData.height,-ndp))','Flooding',num2cell(flooding)','Previous',num2cell(prev)','Next',num2cell(next)','Frac',num2cell(frac)');
    tideInfo{dayIndex}=si;
end
% Convert cell array to numeric:
tideInfo=vertcat(tideInfo{:});
tideInfo=struct2struct(tideInfo);
mp=moonPhase(tideInfo.DateTime,'image',0);
tideInfo.Springiness=roundn([mp.Springiness]',-ndp);
if ~numericDateTime
    fields2Convert={'DateTime','Previous','Next'};
    dateFormat='dd/mm/yyyy HH:MM';
    for i=1:length(fields2Convert)
        fni=fields2Convert{i};
        tideInfo.(fni)=datestr(tideInfo.(fni),dateFormat);
        if length(tideInfo.Height)>1
            tideInfo.(fni)=cellstr(tideInfo.(fni));
        end
    end
end
% and we're done!
end