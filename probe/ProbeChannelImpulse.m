function [] = ProbeChannelImpulse(ChannelImpulseResponse, SeparateDisplay, Title)
    figure;
    TiledFigure = tiledlayout(ChannelImpulseResponse.ChannelOutputNum,1);
    if (~exist('SeparateDisplay', 'var'))
        SeparateDisplay = false;
    end
    for indexRx = 1 : ChannelImpulseResponse.ChannelOutputNum;
        if (SeparateDisplay)
            nexttile;
        end
        for indexTx = 1 : ChannelImpulseResponse.ChannelInputNum;
            ChannelImpulseFig = reshape(ChannelImpulseResponse.Signal(indexRx,indexTx,:),1,[]);
            plot(ChannelImpulseFig);
            hold on;
        end
    end
    hold off;
    if (exist('Title', 'var'))
        title(TiledFigure, Title);
    end
    drawnow;
end

