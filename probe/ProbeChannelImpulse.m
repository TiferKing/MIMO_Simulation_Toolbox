function [] = ProbeChannelImpulse(ChannelImpulseResponse, SeparateDisplay, Title)
    figure;
    TiledFigure = tiledlayout("flow");
    if (~exist('SeparateDisplay', 'var'))
        SeparateDisplay = false;
    end
    Horizon = [0 : 1 / ChannelImpulseResponse.SampleRate : ChannelImpulseResponse.TimeEndurance - 1 / ChannelImpulseResponse.SampleRate];
    [HorizonUnit, HorizonFactor] = UnitConvert(ChannelImpulseResponse.TimeEndurance, 's');
    [StartTimeUnit, StartTimeFactor] = UnitConvert(ChannelImpulseResponse.TimeStart, 's');
    Horizon = HorizonFactor * Horizon;
    if (~SeparateDisplay)
        nexttile;
    end
    for indexRx = 1 : ChannelImpulseResponse.ChannelOutputNum;
        if (SeparateDisplay)
            nexttile;
        end
        for indexTx = 1 : ChannelImpulseResponse.ChannelInputNum;
            ChannelImpulseFig = reshape(ChannelImpulseResponse.Signal(indexRx,indexTx,:),1,[]);
            plot(Horizon, ChannelImpulseFig);
            xlim([0 (ChannelImpulseResponse.TimeEndurance * HorizonFactor)]);
            hold on;
        end
    end
    xlabel(TiledFigure, [HorizonUnit ' (Start@' num2str(ChannelImpulseResponse.TimeStart * StartTimeFactor) ' ' StartTimeUnit ')']);
    if (exist('Title', 'var'))
        title(TiledFigure, Title);
    end
    hold off;
    drawnow;
end

