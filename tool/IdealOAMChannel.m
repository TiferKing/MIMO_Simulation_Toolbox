function [ChannelImpulseResponse] = IdealOAMChannel(TxChannelNum, RxChannelNum, TxAntennaRadius, RxAntennaRadius, RxPosition, RxEulerianAngle, MaximumFrequency, SampleRate, AntennaDisplay)
    TxAntennaPos = zeros(4, TxChannelNum);
    TxAntennaPos(1,:) = cos([0 : 1 / TxChannelNum : 1 - (1 / TxChannelNum)] * 2 * pi) * TxAntennaRadius;
    TxAntennaPos(2,:) = sin([0 : 1 / TxChannelNum : 1 - (1 / TxChannelNum)] * 2 * pi) * TxAntennaRadius;
    TxAntennaPos(4,:) = ones(1, TxChannelNum);
    
    RxAntennaPos = zeros(4, RxChannelNum);
    RxAntennaPos(1,:) = cos([0 : 1 / RxChannelNum : 1 - (1 / RxChannelNum)] * 2 * pi) * RxAntennaRadius;
    RxAntennaPos(2,:) = sin([0 : 1 / RxChannelNum : 1 - (1 / RxChannelNum)] * 2 * pi) * RxAntennaRadius;
    RxAntennaPos(4,:) = ones(1, RxChannelNum);
    Roll = [1 0 0; 0 cos(RxEulerianAngle(1)) -sin(RxEulerianAngle(1)); 0 sin(RxEulerianAngle(1)) cos(RxEulerianAngle(1))];
    Pitch = [cos(RxEulerianAngle(2)) 0 sin(RxEulerianAngle(2)); 0 1 0; -sin(RxEulerianAngle(2)) 0 cos(RxEulerianAngle(2))];
    Yaw = [cos(RxEulerianAngle(3)) -sin(RxEulerianAngle(3)) 0; sin(RxEulerianAngle(3)) cos(RxEulerianAngle(3)) 0; 0 0 1];
    TransformEulerian = Roll * Pitch * Yaw;
    TransformMatrixAngle = [TransformEulerian RxPosition; 0 0 0 1];
    RxAntennaPos = TransformMatrixAngle * RxAntennaPos;
    
    if(exist('AntennaDisplay','var') && AntennaDisplay)
        figure;
        plot3([TxAntennaPos(1,:) TxAntennaPos(1,1)],[TxAntennaPos(2,:) TxAntennaPos(2,1)],[TxAntennaPos(3,:) TxAntennaPos(3,1)],'-o');
        hold on;
        plot3([RxAntennaPos(1,:) RxAntennaPos(1,1)],[RxAntennaPos(2,:) RxAntennaPos(2,1)],[RxAntennaPos(3,:) RxAntennaPos(3,1)],'-o');
        hold off;
        drawnow;
    end
    
    Distance = zeros(RxChannelNum, TxChannelNum);
    for index = 1 : RxChannelNum
        Distance(index,:) = sqrt(sum((TxAntennaPos - RxAntennaPos(:, index)) .^ 2));
    end
    
    MinDistance = min(Distance, [], 'all');
    MaxDistance = max(Distance, [], 'all');
    GaussianTau = 1 / (pi * MaximumFrequency);
    if (GaussianTau < 10 * (1 / SampleRate))
        warning("The Gaussian impulse sample may not have the precision needed. Please increase the channel sample rate.");
    end
    Delay = Distance / physconst('LightSpeed');
    MinDelay = MinDistance / physconst('LightSpeed');
    MaxDelay = MaxDistance / physconst('LightSpeed');
    
    TimeStart = MinDelay - 6 * GaussianTau;
    TimeEndurance = MaxDelay - MinDelay + 12 * GaussianTau;
    MinimumLambada = physconst('LightSpeed') * (1 / MaximumFrequency);
    if (MinDistance < MinimumLambada)
        warning("The minimum distance between two antennas is shorter than the minimum wavelength (lambda), which may lead to incorrect channel characteristics.");
    end
    AttenuationdB = -pow2db((MinimumLambada / 4 * pi * MinDistance) ^ 2 / 8);
    
    
    ChannelImpulseResponse = InitChannelImpulseResponse(TxChannelNum, RxChannelNum, TimeStart, TimeEndurance, SampleRate, AttenuationdB, MaximumFrequency, 'Custom');
    ChannelLength = size(ChannelImpulseResponse.Signal,3);
    
    for indexRx = 1 : RxChannelNum
        for indexTx = 1 : TxChannelNum
            GaussianImpulse = exp(-(([1 : ChannelLength] .* (1 / SampleRate) - (6 * GaussianTau) - (Delay(indexRx, indexTx) - MinDelay)) .^ 2) ./ (GaussianTau .^ 2));
            GaussianImpulse = ((MinDistance / Distance(indexRx, indexTx)) ^ 2) * (GaussianImpulse ./ sum(GaussianImpulse));
            ChannelImpulseResponse.Signal(indexRx, indexTx, :) = GaussianImpulse;
        end
    end
    
end

