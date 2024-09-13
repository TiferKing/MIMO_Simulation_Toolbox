function [XZReceiveTotal, IndexMaxRecv] = OAMFocusing(TxChannelNum, TxAntennaRadius, TxBFElementNum, TxBFDistance, TxFocusingAngle, Frequency, Method, MaxMode, DisplayRange)
%OAMFocusingComparison Compare the difference between approximate ideal OAM
% and diverging OAM.
%Introduction:
%   Compare the difference between approximate ideal OAM(A-OAM), H-OAM and 
%   diverging OAM(D-OAM).
%Syntax:
%   OAMFocusing(TxChannelNum, TxAntennaRadius, TxBFElementNum, TxBFDistance,
%   TxFocusingAngle, Frequency, Method, MaxMode, DisplayRange)
%Description:
%   OAMFocusing(TxChannelNum, TxAntennaRadius, TxBFElementNum, TxBFDistance,
%   TxFocusingAngle, Frequency, Method, MaxMode, DisplayRange)
%       no return, will display directly.
%Input Arguments:
%   TxChannelNum: (positive integer scalar)
%       Number of transmitter channels.
%   TxAntennaRadius: (double)
%       Radius of transmitter array in meter.
%   TxBFElementNum: (positive integer scalar)
%       Number of antenna in each line array.
%   TxBFDistance: (double)
%       Distance between two adjacent antenna in line array in meter.
%   TxFocusingAngle: (double)
%       The focusing angle of transmitter in rad.
%   Frequency: (double)
%       Center frequency of OAM beams in Hz.
%   Method: (string)
%       OAM generating method, it is one of blow:
%       'A-OAM': Approximately ideal OAM.
%       'H-OAM': Holographic OAM.
%       'D-OAM': Diverging OAM.
%   MaxMode: (positive integer scalar)
%       The maximum simulation mode order of OAM.
%   DisplayRange: (matrix)
%       Simulation range and precision.
%Output Arguments:
%   XZReceiveTotal: (matrix)
%       The side view of OAM power distribution.
%   IndexMaxRecv: (matrix)
%       The best-receiving radius of each distance.
%Author:
%   Tifer King
%License:
%   Please refer to the 'LICENSE' file included in the root directory 
%   of the project.
    
    % Tx array position initialization
    TxBFLength = (TxBFElementNum - 1) * TxBFDistance;
    TxAntennaNum = TxChannelNum * TxBFElementNum;
    TxAntennaPos = zeros(4, TxAntennaNum);
    TxAntennaRadiusAll = reshape(ones(TxChannelNum, 1) * ([0 : TxBFDistance : TxBFLength] - TxBFLength / 2 + TxAntennaRadius), 1, []);
    TxAntennaThetaAll = reshape([0 : 1 / TxChannelNum : 1 - (1 / TxChannelNum)]' .* 2 .* pi * ones(1, TxBFElementNum), 1, []);
    TxAntennaPos(1,:) = cos(TxAntennaThetaAll) .* TxAntennaRadiusAll;
    TxAntennaPos(2,:) = sin(TxAntennaThetaAll) .* TxAntennaRadiusAll;
    TxAntennaPos(4,:) = ones(1, TxAntennaNum);

    % Wavelength calculation
    Lambda = physconst('LightSpeed') * (1 / Frequency);

    if (~exist('DisplayRange', 'var'))
        DisplayRange = 'Auto';
    end

    if (~exist('Method', 'var'))
        Method = 'Auto';
    end

    if (isstring(Method) || ischar(Method))
        if (strcmp(Method, 'Auto'))
            Method = 'A-OAM';
        end
    end

    if (isstring(TxFocusingAngle) || ischar(TxFocusingAngle))
        if (strcmp(TxFocusingAngle, 'Auto'))
            % The focus is set at ten times the radius of the transmitting 
            % antenna by default. 
            TxFocusingAngle = atan(TxAntennaRadius / 10);
        end
    end
    
    if (isstring(DisplayRange) || ischar(DisplayRange))
        if (strcmp(DisplayRange, 'Auto'))
            TopRange = [(TxAntennaRadius); (TxAntennaRadius); round(TxAntennaRadius ./ tan(TxFocusingAngle) .* 1.4); 0];
            BottomRange = [0; 0; round(TxAntennaRadius ./ tan(TxFocusingAngle) .* 0.6); 0];
            DisplayRange = [TopRange BottomRange (TopRange - BottomRange) ./ [500; 500; 1; 1]];
            DisplayRange(3,3) = 1;
        end
    end

    % XZ Plane calculate
    XSize = round((DisplayRange(1,1) - DisplayRange(1,2)) / DisplayRange(1,3)) + 1;
    ZSize = (DisplayRange(3,1) - DisplayRange(3,2)) / DisplayRange(3,3) + 1;
    XRange = [DisplayRange(1,2) : DisplayRange(1,3) : DisplayRange(1,1)];
    ZRange = [DisplayRange(3,2) : DisplayRange(3,3) : DisplayRange(3,1)];
    XZPlaneDistance = zeros(XSize, ZSize, TxAntennaNum);
    XZPlanePoint = ones(4, XSize, ZSize);
    XZPlanePoint(1,:,:) = reshape(repmat(XRange, ZSize, 1)', [1, XSize, ZSize]);
    XZPlanePoint(2,:,:) = XZPlanePoint(2,:,:) .* 0;
    XZPlanePoint(3,:,:) = reshape(repmat(ZRange', 1, XSize)', [1, XSize, ZSize]);

    for index = 1 : TxAntennaNum
        XZPlaneDistance(:,:,index) = reshape(sqrt(sum((TxAntennaPos(:, index) - XZPlanePoint) .^ 2, 1)), [XSize, ZSize]);
    end


    XZPlaneDistance = ((XZPlaneDistance < Lambda) .* Lambda) + ((XZPlaneDistance >= Lambda) .* XZPlaneDistance);
    XZAttenuation = Lambda ./ (4 .* pi .* XZPlaneDistance) / sqrt(TxBFElementNum) / sqrt(TxChannelNum);
    XZPhase = exp(XZPlaneDistance ./ Lambda .* 2 .* pi .* 1i);
    XZReceive = zeros(XSize, ZSize, TxAntennaNum, MaxMode);

    for i = 1 : MaxMode
        OAMMode = i;
        for indexcircle = 0 : (TxBFElementNum - 1)
            if(strcmp(Method, 'A-OAM'))
                BFPhaseOffset = indexcircle .* sin(TxFocusingAngle) .* TxBFDistance / Lambda .* 2 .* pi;
            elseif(strcmp(Method, 'H-OAM'))
                BFPhaseOffset = sqrt(sum(TxAntennaPos(:, indexcircle * TxChannelNum + 1) .^ 2) - 1 + (TxAntennaRadius ./ tan(TxFocusingAngle)) .^ 2) / Lambda .* 2 .* pi;
            else
                BFPhaseOffset = 0;
            end
            for index = 1 : TxChannelNum
                txi = indexcircle * TxChannelNum + index;
                XZReceive(:, :, txi, OAMMode) = XZAttenuation(:, :, txi) .* XZPhase(:, :, txi) .* exp(2 .* pi .* 1i .* (index - 1) ./ TxChannelNum .* OAMMode - BFPhaseOffset .* 1i);
            end
        end
    end

    XZReceiveTotal = sum(XZReceive,3) .^ 2;

    IndexMaxRecv = zeros(1, ZSize, 1, OAMMode);
    for OAMMode = 1 : MaxMode
        for z = 1 : ZSize
            if(strcmp(Method, 'A-OAM'))
                [~,IndexPeakLoc] = findpeaks(abs(XZReceiveTotal(:, z, 1, OAMMode)));
            elseif(strcmp(Method, 'H-OAM'))
                [~,IndexPeakLoc] = max(abs(XZReceiveTotal(:, z, 1, OAMMode)), [], 1);
            else
                [~,IndexPeakLoc] = findpeaks(abs(XZReceiveTotal(:, z, 1, OAMMode)));
            end
            
            IndexMaxRecv(1, z, 1, OAMMode) = IndexPeakLoc(1);
        end
    end
end

