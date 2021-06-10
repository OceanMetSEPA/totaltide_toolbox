function [port,info,distance]=portFinder(varargin)
% Find the interface of the Total Tide port that best matches the input.
% This port interface can then be passed to other TotalTide functions; see
% examples below.
%
% INPUT:
%       string / number ID of port OR
%       easting,northing - function then locates closest port
%
% OUTPUTS:
%       port (if unique matching name found); otherwise []
%       info (summary of port tide statistics)
%       distance (in metres, between port and easting,northing input)
%
% EXAMPLES:
%
% TotalTide.portFinder('Leith');    % returns port with name ('LEITH')
% TotalTide.portFinder('Loch');     % returns [] after displaying all port names containing 'Loch'
% TotalTide.portFinder('Fishface'); % returns [] after warning that no match found
% TotalTide.portFinder(404);        % returns 'GREENOCK', number '0404'
% [port,info,distance]=TotalTide.portFinder(333000,670000) % find closest port to these coordinates
%
% port=TotalTide.portFinder('Leith'); % as above, get port interface
% TotalTide.getStationSlackHeights(port,datestr(now,'dd/mm/yyyy'),1); % get today's high/low tides
%
% NB- to work, this function needs a list of all TotalTide ports. Finding
% this list takes a wee while (>5s). To speed up subsequent function calls,
% this function assigns the port list to the base workspace. 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   portFinder.m  $
% $Revision:   1.0  $
% $Author:   ted.schlicke  $
% $Date:   Apr 29 2016 11:50:44  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

try
    listOfTotalTidePorts=evalin('base','listOfTotalTidePorts');
    totalTidePortInfo=evalin('base','totalTidePortInfo');
catch
    listOfTotalTidePorts=TotalTide.northUKPorts; % Interface for port names
    numberOfPorts=listOfTotalTidePorts.Count;
    totalTidePortInfo=arrayfun(@(x)get(listOfTotalTidePorts.Item(x)),1:numberOfPorts,'Unif',0)';
    totalTidePortInfo=vertcat(totalTidePortInfo{:});
    assignin('base','listOfTotalTidePorts',listOfTotalTidePorts)
    assignin('base','totalTidePortInfo',totalTidePortInfo)
end

if nargin==0
    help portFinder
    return
end

port=[];
info=[];
distance=NaN;

if nargin==1 % single input? Could be port name or ID number
    if isnumeric(varargin{1})
        varargin{1}=num2str(varargin{1});
    end
    if ~ischar(varargin{1})
        error('Please pass port name (as char) or number')
    end
    testName=varargin{1};
    % Check port names:
    portName=closestStringMatch({totalTidePortInfo.Name},testName);
    if length(portName)==1
        portIndex=find(strcmp(portName,{totalTidePortInfo.Name}));
    else % No unique name
        % Check port numbers:
        portNumber=closestStringMatch({totalTidePortInfo.Number},testName);
        if length(portNumber)~=1 % We've got a problem!
            if isempty(portName)
%                fprintf('No matching port name found\n')
            else
                warning('Ambiguous port name:')
                disp(portName)
            end
            if isempty(portNumber)
%                fprintf('No matching port number found\n')
            else
                warning('Ambiguous port number')
                disp(portNumber)
            end
            % Throw error
            if isempty(portNumber) && isempty(portName)
                warning('No TotalTide port found for input ''%s''',testName)
            else
                warning('No unique TotalTide ports for input ''%s''',testName)
            end
            return
        else
            portName=portNumber;
            portIndex=find(strcmp(portName,{totalTidePortInfo.Number}));
        end
    end
    
elseif nargin==2 % search for ports by location
    if ~all(cellfun(@isnumeric,varargin))
        error('Coordinates should be numeric')
    end
    e=varargin{1};
    n=varargin{2};
    [lon,lat]=OS.catCoordinates(e,n);
    dist=distanceBetweenPoints(lon,lat,[totalTidePortInfo.Longitude],[totalTidePortInfo.Latitude]);
    portIndex=find(dist==min(dist));
    if length(portIndex)>1 % Unlikely but you never know
        warning('%d equally spaced ports found; retaining first one')
        portIndex=portIndex(1);
    end
    [ett,ntt]=OS.catCoordinates(totalTidePortInfo(portIndex).Longitude,totalTidePortInfo(portIndex).Latitude);
    distance=distanceBetweenPoints(e,n,ett,ntt);
else
    error('Too many inputs!')
end

% PREPARE OUTPUT
port=listOfTotalTidePorts.Item(portIndex);
info=get(port);
if nargout==0
    fprintf('Found port = ''%s'', number ''%s''\n',info.Name,info.Number)
end
