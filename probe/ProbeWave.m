function [] = ProbeWave(Signal, SeparateDisplay, Title)
    figure('units','normalized','outerposition',[0 0 1 1]);
    TiledFigure = tiledlayout(Signal.ChannelNum,1);
    if (~exist('SeparateDisplay', 'var'))
        SeparateDisplay = false;
    end
    %Horizon = linspace(Signal.TimeStart,Signal.TimeStart + Signal.TimeEndurance, Signal.TimeEndurance / 10);
    Horizon = [0 : 1 / Signal.SampleRate : Signal.TimeEndurance - 1 / Signal.SampleRate];
    [HorizonUnit, HorizonFactor] = UnitConvert(Signal.TimeEndurance, 's');
    Horizon = HorizonFactor * Horizon;
    MaxVoltage = max(abs(Signal.Signal),[],"all") * Signal.ReferenceVoltage;
    [VoltageUnit, VoltageFactor] = UnitConvert(MaxVoltage, 'V');
    [StartTimeUnit, StartTimeFactor] = UnitConvert(Signal.TimeStart, 's');
    for index = 1 : Signal.ChannelNum;
        if (SeparateDisplay)
            nexttile;
        else
            hold on;
        end
        plot(Horizon, Signal.Signal(index, :) * Signal.ReferenceVoltage * VoltageFactor);
        xlim([0 (Signal.TimeEndurance * HorizonFactor)]);
        ylim([-(MaxVoltage * VoltageFactor) (MaxVoltage * VoltageFactor)]);
        %xticks([Signal.TimeStart : Signal.TimeEndurance / 10 : Signal.TimeEndurance - 1 / Signal.SampleRate])
    end
    xlabel(TiledFigure, [HorizonUnit ' (Start@' num2str(Signal.TimeStart * StartTimeFactor) ' ' StartTimeUnit ')']);
    ylabel(TiledFigure, VoltageUnit);
    if (exist('Title', 'var'))
        title(TiledFigure, Title);
    end
    hold off;
    drawnow;
end

