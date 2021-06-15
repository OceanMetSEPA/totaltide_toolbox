function [ station ] = closestStation(a,b,format)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   closestStation.m  $
% $Revision:   1.2  $
% $Author:   ted.schlicke  $
% $Date:   May 28 2014 12:22:52  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Returns the nearest tide monitoring station to a given location based on 
    % Admirality TotalTide. The target location can be specified in either decimal 
    % degrees (lat,lng) or as an easting/northing pair. The query is scoped to 
    % the northern part of the UK only (sectors "H" and "N" in the OS grid) in 
    % order to minimize the search space.
    %
    % Distances are calculated along great circles rather than with reference to 
    % any particluar water body, so care must be taken to ensure that the result is
    % appropriate to the context under consideration.
    %
    % Usage:
    % closestStation(x, y) 
    %   where x,y are long/lats
    %
    % closestStation(x, y, 'EN')
    %   where x,y are easting/northing
    %
    % OUTPUT:
    %    An instance of TotalTide::IPort. See http://www.chersoft.co.uk/totaltidesdk/reference/interface_total_tide_1_1_i_port.html
    %
    % EXAMPLES:
    %
    %    sta = closestStation(56.223399966767325, -5795766414163874) % assumes decimal degree lat/lng pair
    %    sta = closestStation(56.223399966767325, -5795766414163874, 'LL') % same results as above but explicitly
    %    declares decimal degree, lat/lng format using 'LL'
    %    sta = closestStation(164789, 709911, 'EN') % declare easting/northing
    %    format using 'EN'
    %
    % DEPENDENCIES:
    % This function requires a working, authorised installation of Admiralty
    % TotalTide.
    %
    % The function also calls 
    %  - catCoordinates.m
    %  - TotalTide.northUKPorts.m
    %  - greatCircleDistance.m
    
    if nargin==0
      help TotalTide.closestStation
      return
    end


    % Set the default input format. At present, this just allows us to omit the
    % third argument if we like.
    if nargin < 3
      format = 'LL';
    end

    % If easting/northing format declared in third argument, convert to
    % decimal degrees
    if strcmpi(format, 'EN')
       [lng,lat] = OS.catCoordinates(a, b);
    else
       % Otherwise, just assign the passed in lat/lng to the appropriate vars
       lat = a;
       lng = b;
    end

    % Get the candidate stations from TotalTide
    search_domain = TotalTide.northUKPorts();

    min_distance = 99999999999;
    closestStationIndex = 0;

    % Iterate through the northern UK stations and identify the closest one to
    % the target location
    for p = 1:search_domain.Count

       distance = TotalTide.greatCircleDistance([lat,lng],[search_domain.Item(p).Latitude, search_domain.Item(p).Longitude]);

       if distance < min_distance
           min_distance = distance;
           closestStationIndex = p;
       end

    end

    % Return the winner!
    station = search_domain.Item(closestStationIndex);
    
    get(station)
end

