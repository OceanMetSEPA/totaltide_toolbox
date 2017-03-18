function [ tt ] = connection()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% $Workfile:   connection.m  $
% $Revision:   1.1  $
% $Author:   ted.schlicke  $
% $Date:   May 28 2014 12:22:56  $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Simple wrapper for instantiating a connection to the TotalTide COM
    % API
    %
    % Usage:
    % tt = TotalTide.connection
    %
    % OUTPUT:
    %    An instance of COM.TotalTide_Application
    %
    % EXAMPLES:
    %
    %    tt   = TotalTide.connection;
    %    port = tt.StationByNumber('0345')
    %
    % DEPENDENCIES:
    % This function requires a working, authorised installation of Admiralty
    % TotalTide.
    %

    tt = actxserver('TotalTide.Application');
end

