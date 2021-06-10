function [ results ] = northUKPorts()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   northUKPorts.m  $
% $Revision:   1.1  $
% $Author:   ted.schlicke  $
% $Date:   May 28 2014 12:23:06  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Returns all of the "port" stations represented within TotalTide which
    % lie within the northern part of the UK. This function is intended to 
    % increase the efficiency of searching for Scottish ports. The search
    % domain corresponds roughly with the "N" and "H" sectors of the OS
    % Grid.
    %
    % We should probably generalize this to be a MATLAB wrapper for the
    % more generic TotalTide .StationsInExtent method.
    %
    % Usage:
    % TotalTide.northUKPorts()
    %
    % OUTPUT:
    %    An instance of TotalTide::IStations. See http://www.chersoft.co.uk/totaltidesdk/reference/interface_total_tide_1_1_i_stations.html
    %
    % EXAMPLES:
    %
    %    list = TotalTide.northUKPorts()
    %    portName = list.Item(1).Name     #=> Scarborough
    %
    % DEPENDENCIES:
    % This function requires a working, authorised installation of Admiralty
    % TotalTide.
    %
    % The function also calls 
    %  - TotalTide.connection.m

    % These roughly correspond to the "N" and "H" sectors in the OS grid
    ne = [61.161414,  1.718092];
    sw = [54.238270, -7.555904];
    
    searchType = 0; % Ports only
    
    tt      = TotalTide.connection;
    results = tt.StationsInExtent(ne(1), sw(1), ne(2), sw(2), searchType);
end

