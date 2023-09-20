function [] = ProbeConstellation(Signal, SeparateDisplay, ConstellationMap, Title)
    figure;
    TiledFigure = tiledlayout("flow");
    if (~exist('SeparateDisplay', 'var'))
        SeparateDisplay = false;
    end
    if (exist('ConstellationMap', 'var'))
        if (isstring(ConstellationMap) || ischar(ConstellationMap))
            % Some preset configuration
            if (strcmp(ConstellationMap, 'ASK'))
                ConstellationMap = [(0 + 0i) (1 + 0i)];
            elseif (strcmp(ConstellationMap, 'BPSK'))
                ConstellationMap = [(-1 + 0i) (1 + 0i)];
            elseif (strcmp(ConstellationMap, 'QPSK'))
                ConstellationMap = [(1 + 1i) (1 + -1i) (-1 + 1i) (-1 + -1i)];
            elseif (strcmp(ConstellationMap, '16QAM'))
                ConstellationMap = [];
                for indexI = 0 : 3
                    for indexQ = 0 : 3
                        ConstellationMap = [ConstellationMap ((indexI / 1.5 - 1) + (indexQ / 1.5 - 1) * 1i)];
                    end
                end
            elseif (strcmp(ConstellationMap, '64QAM'))
                ConstellationMap = [];
                for indexI = 0 : 7
                    for indexQ = 0 : 7
                        ConstellationMap = [ConstellationMap ((indexI / 3.5 - 1) + (indexQ / 3.5 - 1) * 1i)];
                    end
                end
            elseif (strcmp(ConstellationMap, '256QAM'))
                ConstellationMap = [];
                for indexI = 0 : 15
                    for indexQ = 0 : 15
                        ConstellationMap = [ConstellationMap ((indexI / 7.5 - 1) + (indexQ / 7.5 - 1) * 1i)];
                    end
                end
            elseif (strcmp(ConstellationMap, '1024QAM'))
                ConstellationMap = [];
                for indexI = 0 : 31
                    for indexQ = 0 : 31
                        ConstellationMap = [ConstellationMap ((indexI / 15.5 - 1) + (indexQ / 15.5 - 1) * 1i)];
                    end
                end
            else
                ConstellationMap = [];
            end
            ConstellationMap = ConstellationMap * Signal.ReferenceVoltage;
        end
    else
        ConstellationMap = [];
    end
    MaxReal = max(abs(real(Signal.Signal)),[],'All');
    MaxImaginary = max(abs(imag(Signal.Signal)),[],'All');
    MaxScale = max([MaxReal MaxImaginary]) * Signal.ReferenceVoltage;
    [VoltageUnit, VoltageFactor] = UnitConvert(MaxScale, 'V');
    if (~SeparateDisplay)
        nexttile;
        plot(ConstellationMap,'+','Markersize',30,'color','red','LineWidth',3);
    end
    for index = 1 : Signal.ChannelNum
        if (SeparateDisplay)
            nexttile;
            plot(ConstellationMap,'+','Markersize',30,'color','red','LineWidth',3);
            hold on;
        else
            hold on;
        end
        plot(Signal.Signal(index, :) * Signal.ReferenceVoltage,'.');
        xlim([-(MaxScale * 1.1 * VoltageFactor) (MaxScale * 1.1 * VoltageFactor)]);
        ylim([-(MaxScale * 1.1 * VoltageFactor) (MaxScale * 1.1 * VoltageFactor)]);
    end
    hold off;
    xlabel(TiledFigure, VoltageUnit);
    ylabel(TiledFigure, VoltageUnit);
    if (exist('Title', 'var'))
        title(TiledFigure, Title);
    end

    drawnow;
end
