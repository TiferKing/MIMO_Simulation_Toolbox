function [] = IdealOAMVisualizer(TxChannelNum, RxChannelNum, TxAntennaRadius, RxAntennaRadius, RxPosition, RxEulerianAngle, Frequency, OAMMode, AntennaDisplay, DisplayRange)
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

    Lambada = physconst('LightSpeed') * (1 / Frequency);
    SpinMode = 0;

    if (~exist('DisplayRange', 'var'))
        DisplayRange = 'Auto';
    end
    if (isstring(DisplayRange) || ischar(DisplayRange))
        if (strcmp(DisplayRange, 'Auto'))
            MaxRange = max([abs(TxAntennaPos) abs(RxAntennaPos)], [], 2);
            MinScale = min(MaxRange, [], "all");
            if (MinScale < Lambada)
                %MinScale = Lambada;
                MaxRange = ((MaxRange >= Lambada) .* MaxRange) + ((MaxRange < Lambada) .* Lambada);
            end
            %DisplayCell = (MinScale / 100);
            DisplayRange = [(MaxRange .* [2; 2; 1; 0]) (MaxRange / 50)];
        end
    end

    % XZ Plane calculate
    XSize = round(DisplayRange(1,1) / DisplayRange(1,2) * 2) + 1;
    YSize = round(DisplayRange(2,1) / DisplayRange(2,2) * 2) + 1;
    ZSize = round(DisplayRange(3,1) / DisplayRange(3,2)) + 1;
    XRange = [-DisplayRange(1,1) : DisplayRange(1,2) : DisplayRange(1,1)];
    YRange = [-DisplayRange(2,1) : DisplayRange(2,2) : DisplayRange(2,1)];
    ZRange = [0 : DisplayRange(3,2) : DisplayRange(3,1)];
    XZPlaneDistance = zeros(XSize, ZSize, TxChannelNum);
    XZPlanePoint = ones(4, XSize, ZSize);
    XZPlanePoint(1,:,:) = reshape(repmat(XRange, ZSize, 1)', [1, XSize, ZSize]);
    XZPlanePoint(2,:,:) = XZPlanePoint(2,:,:) .* 0;
    XZPlanePoint(3,:,:) = reshape(repmat(ZRange', 1, XSize)', [1, XSize, ZSize]);

    for index = 1 : TxChannelNum
        XZPlaneDistance(:,:,index) = reshape(sqrt(sum((TxAntennaPos(:, index) - XZPlanePoint) .^ 2, 1)), [XSize, ZSize]);
    end

    XZPlaneDistance = ((XZPlaneDistance < Lambada) .* Lambada) + ((XZPlaneDistance >= Lambada) .* XZPlaneDistance);
    XZAttenuation = Lambada ./ (4 .* pi .* XZPlaneDistance);
    XZPhase = exp(XZPlaneDistance ./ Lambada .* 2 .* pi .* 1i);
    XZReceiveV = zeros(XSize, ZSize, TxChannelNum);
    XZReceiveH = zeros(XSize, ZSize, TxChannelNum);
    for index = 1 : TxChannelNum
        XZReceiveV(:, :, index) = XZAttenuation(:, :, index) .* XZPhase(:, :, index) .* exp(2 .* pi .* 1i .* (index - 1) ./ TxChannelNum .* OAMMode) .* real(exp(2 .* pi .* 1i .* (index - 1) ./ TxChannelNum .* SpinMode));
        XZReceiveH(:, :, index) = XZAttenuation(:, :, index) .* XZPhase(:, :, index) .* exp(2 .* pi .* 1i .* (index - 1) ./ TxChannelNum .* OAMMode) .* imag(exp(2 .* pi .* 1i .* (index - 1) ./ TxChannelNum .* SpinMode));
    end

    % YZ Plane calculate
    YZPlaneDistance = zeros(YSize, ZSize, TxChannelNum);
    YZPlanePoint = ones(4, YSize, ZSize);
    YZPlanePoint(1,:,:) = YZPlanePoint(1,:,:) .* 0;
    YZPlanePoint(2,:,:) = reshape(repmat(YRange, ZSize, 1)', [1, YSize, ZSize]);
    YZPlanePoint(3,:,:) = reshape(repmat(ZRange', 1, YSize)', [1, YSize, ZSize]);

    for index = 1 : TxChannelNum
        YZPlaneDistance(:,:,index) = reshape(sqrt(sum((TxAntennaPos(:, index) - YZPlanePoint) .^ 2, 1)), [YSize, ZSize]);
    end

    YZPlaneDistance = ((YZPlaneDistance < Lambada) .* Lambada) + ((YZPlaneDistance >= Lambada) .* YZPlaneDistance);
    YZAttenuation = Lambada ./ (4 .* pi .* YZPlaneDistance);
    YZPhase = exp(YZPlaneDistance ./ Lambada .* 2 .* pi .* 1i);
    YZReceiveV = zeros(YSize, ZSize, TxChannelNum);
    YZReceiveH = zeros(YSize, ZSize, TxChannelNum);
    for index = 1 : TxChannelNum
        YZReceiveV(:, :, index) = YZAttenuation(:, :, index) .* YZPhase(:, :, index) .* exp(2 .* pi .* 1i .* (index - 1) ./ TxChannelNum .* OAMMode) .* real(exp(2 .* pi .* 1i .* (index - 1) ./ TxChannelNum .* SpinMode));
        YZReceiveH(:, :, index) = YZAttenuation(:, :, index) .* YZPhase(:, :, index) .* exp(2 .* pi .* 1i .* (index - 1) ./ TxChannelNum .* OAMMode) .* imag(exp(2 .* pi .* 1i .* (index - 1) ./ TxChannelNum .* SpinMode));
    end
    
    % XY Plane calculate
    XYPlaneDistance = zeros(XSize, YSize, TxChannelNum);
    XYPlanePoint = ones(4, XSize, YSize);
    XYPlanePoint(1,:,:) = reshape(repmat(XRange, YSize, 1)', [1, XSize, YSize]);
    XYPlanePoint(2,:,:) = reshape(repmat(YRange', 1, XSize)', [1, XSize, YSize]);
    XYPlanePoint(3,:,:) = XYPlanePoint(3,:,:) .* DisplayRange(3,1);

    for index = 1 : TxChannelNum
        XYPlaneDistance(:,:,index) = reshape(sqrt(sum((TxAntennaPos(:, index) - XYPlanePoint) .^ 2, 1)), [XSize, YSize]);
    end

    XYPlaneDistance = ((XYPlaneDistance < Lambada) .* Lambada) + ((XYPlaneDistance >= Lambada) .* XYPlaneDistance);
    XYAttenuation = Lambada ./ (4 .* pi .* XYPlaneDistance);
    XYPhase = exp(XYPlaneDistance ./ Lambada .* 2 .* pi .* 1i);
    XYReceiveV = zeros(XSize, YSize, TxChannelNum);
    XYReceiveH = zeros(XSize, YSize, TxChannelNum);
    for index = 1 : TxChannelNum
        XYReceiveV(:, :, index) = XYAttenuation(:, :, index) .* XYPhase(:, :, index) .* exp(2 .* pi .* 1i .* (index - 1) ./ TxChannelNum .* OAMMode) .* real(exp(2 .* pi .* 1i .* (index - 1) ./ TxChannelNum .* SpinMode));
        XYReceiveH(:, :, index) = XYAttenuation(:, :, index) .* XYPhase(:, :, index) .* exp(2 .* pi .* 1i .* (index - 1) ./ TxChannelNum .* OAMMode) .* imag(exp(2 .* pi .* 1i .* (index - 1) ./ TxChannelNum .* SpinMode));
    end

    % Recv Plane calculate
    RecvPlaneDistance = zeros(XSize, YSize, TxChannelNum);
    RecvPlanePoint = ones(4, XSize, YSize);
    RecvPlanePoint(1,:,:) = reshape(repmat(XRange, YSize, 1)', [1, XSize, YSize]);
    RecvPlanePoint(2,:,:) = reshape(repmat(YRange', 1, XSize)', [1, XSize, YSize]);
    RecvPlanePoint(3,:,:) = XYPlanePoint(3,:,:) .* 0;

    RecvPlanePoint = pagemtimes(TransformMatrixAngle, RecvPlanePoint);

    for index = 1 : TxChannelNum
        RecvPlaneDistance(:,:,index) = reshape(sqrt(sum((TxAntennaPos(:, index) - RecvPlanePoint) .^ 2, 1)), [XSize, YSize]);
    end

    RecvPlaneDistance = ((RecvPlaneDistance < Lambada) .* Lambada) + ((RecvPlaneDistance >= Lambada) .* RecvPlaneDistance);
    RecvAttenuation = Lambada ./ (4 .* pi .* RecvPlaneDistance);
    RecvPhase = exp(RecvPlaneDistance ./ Lambada .* 2 .* pi .* 1i);
    RecvReceiveV = zeros(XSize, YSize, TxChannelNum);
    RecvReceiveH = zeros(XSize, YSize, TxChannelNum);
    for index = 1 : TxChannelNum
        RecvReceiveV(:, :, index) = RecvAttenuation(:, :, index) .* RecvPhase(:, :, index) .* exp(2 .* pi .* 1i .* (index - 1) ./ TxChannelNum .* OAMMode) .* real(exp(2 .* pi .* 1i .* (index - 1) ./ TxChannelNum .* SpinMode));
        RecvReceiveH(:, :, index) = RecvAttenuation(:, :, index) .* RecvPhase(:, :, index) .* exp(2 .* pi .* 1i .* (index - 1) ./ TxChannelNum .* OAMMode) .* imag(exp(2 .* pi .* 1i .* (index - 1) ./ TxChannelNum .* SpinMode));
    end

    Distance = zeros(RxChannelNum, TxChannelNum);
    for index = 1 : RxChannelNum
        Distance(index,:) = sqrt(sum((TxAntennaPos - RxAntennaPos(:, index)) .^ 2));
    end
    
    MaxDistance = max(Distance, [], 'all');
    DisplayAttenuationRange = pow2db((Lambada / (4 * pi * MaxDistance)) ^ 2) - 10;

    figure('units','normalized','outerposition',[0 0 1 1]);
    TiledFigure = tiledlayout("flow");
    % XZ Plane Display
    nexttile;
    surf(XRange, ZRange, pow2db(abs(sum(XZReceiveV,3) .^ 2))');
    shading interp;
    title('XZ Plane');
    view(0,90);
    colorbar;
    clim([DisplayAttenuationRange -20]);
    daspect([1 1 1]);

    % YZ Plane Display
    nexttile;
    surf(YRange, ZRange, pow2db(abs(sum(YZReceiveV,3) .^ 2))');
    shading interp;
    title('YZ Plane');
    view(0,90);
    colorbar;
    clim([DisplayAttenuationRange -20]);
    daspect([1 1 1]);

    % XY Plane Display
    nexttile;
    surf(XRange, YRange, pow2db(abs(sum(XYReceiveV,3) .^ 2))');
    shading interp;
    title('XY Plane');
    view(0,90);
    colorbar;
    clim([DisplayAttenuationRange -20]);
    if(exist('AntennaDisplay','var') && AntennaDisplay)
        hold on;
        plot3([RxAntennaPos(1,:) RxAntennaPos(1,1)],[RxAntennaPos(2,:) RxAntennaPos(2,1)],[RxAntennaPos(3,:) RxAntennaPos(3,1)],'-o','Color','r','MarkerFaceColor','#D90000');
        hold off;
    end
    daspect([1 1 1]);

    nexttile;
    surf(XRange, YRange, angle(sum(XYReceiveV,3) .^ 2)');
    shading interp;
    title('XY Phase');
    view(0,90);
    colorbar;
    if(exist('AntennaDisplay','var') && AntennaDisplay)
        hold on;
        plot3([RxAntennaPos(1,:) RxAntennaPos(1,1)],[RxAntennaPos(2,:) RxAntennaPos(2,1)],[RxAntennaPos(3,:) RxAntennaPos(3,1)],'-o','Color','r','MarkerFaceColor','#D90000');
        hold off;
    end
    daspect([1 1 1]);

    % Recv Plane Display
    nexttile;
    surf(XRange, YRange, pow2db(abs(sum(RecvReceiveV,3) .^ 2))');
    shading interp;
    title('Receiver Plane');
    view(0,90);
    colorbar;
    clim([DisplayAttenuationRange -20]);
    if(exist('AntennaDisplay','var') && AntennaDisplay)
        RxAntennaPosInit = zeros(4, RxChannelNum);
        RxAntennaPosInit(1,:) = cos([0 : 1 / RxChannelNum : 1 - (1 / RxChannelNum)] * 2 * pi) * RxAntennaRadius;
        RxAntennaPosInit(2,:) = sin([0 : 1 / RxChannelNum : 1 - (1 / RxChannelNum)] * 2 * pi) * RxAntennaRadius;
        RxAntennaPosInit(3,:) = RxAntennaPosInit(3,:) + 4;
        RxAntennaPosInit(4,:) = ones(1, RxChannelNum);
        hold on;
        plot3([RxAntennaPosInit(1,:) RxAntennaPosInit(1,1)],[RxAntennaPosInit(2,:) RxAntennaPosInit(2,1)],[RxAntennaPosInit(3,:) RxAntennaPosInit(3,1)],'-o','Color','r','MarkerFaceColor','#D90000');
        hold off;
    end
    daspect([1 1 1]);

    nexttile;
    surf(XRange, YRange, angle(sum(RecvReceiveV,3) .^ 2)');
    shading interp;
    title('Receiver Phase');
    view(0,90);
    colorbar;
    if(exist('AntennaDisplay','var') && AntennaDisplay)
        hold on;
        plot3([RxAntennaPosInit(1,:) RxAntennaPosInit(1,1)],[RxAntennaPosInit(2,:) RxAntennaPosInit(2,1)],[RxAntennaPosInit(3,:) RxAntennaPosInit(3,1)],'-o','Color','r','MarkerFaceColor','#D90000');
        hold off;
    end
    daspect([1 1 1]);

    xlabel(TiledFigure, 'meter');
    ylabel(TiledFigure, 'dBW');
    title(TiledFigure, 'Ideal OAM Channel Visualizer-V');

    figure('units','normalized','outerposition',[0 0 1 1]);
    TiledFigure = tiledlayout("flow");
    % XZ Plane Display
    nexttile;
    surf(XRange, ZRange, pow2db(abs(sum(XZReceiveH,3) .^ 2))');
    shading interp;
    title('XZ Plane');
    view(0,90);
    colorbar;
    clim([DisplayAttenuationRange -20]);
    daspect([1 1 1]);

    % YZ Plane Display
    nexttile;
    surf(YRange, ZRange, pow2db(abs(sum(YZReceiveH,3) .^ 2))');
    shading interp;
    title('YZ Plane');
    view(0,90);
    colorbar;
    clim([DisplayAttenuationRange -20]);
    daspect([1 1 1]);

    % XY Plane Display
    nexttile;
    surf(XRange, YRange, pow2db(abs(sum(XYReceiveH,3) .^ 2))');
    shading interp;
    title('XY Plane');
    view(0,90);
    colorbar;
    clim([DisplayAttenuationRange -20]);
    if(exist('AntennaDisplay','var') && AntennaDisplay)
        hold on;
        plot3([RxAntennaPos(1,:) RxAntennaPos(1,1)],[RxAntennaPos(2,:) RxAntennaPos(2,1)],[RxAntennaPos(3,:) RxAntennaPos(3,1)],'-o','Color','r','MarkerFaceColor','#D90000');
        hold off;
    end
    daspect([1 1 1]);

    nexttile;
    surf(XRange, YRange, angle(sum(XYReceiveH,3) .^ 2)');
    shading interp;
    title('XY Phase');
    view(0,90);
    colorbar;
    if(exist('AntennaDisplay','var') && AntennaDisplay)
        hold on;
        plot3([RxAntennaPos(1,:) RxAntennaPos(1,1)],[RxAntennaPos(2,:) RxAntennaPos(2,1)],[RxAntennaPos(3,:) RxAntennaPos(3,1)],'-o','Color','r','MarkerFaceColor','#D90000');
        hold off;
    end
    daspect([1 1 1]);

    % Recv Plane Display
    nexttile;
    surf(XRange, YRange, pow2db(abs(sum(RecvReceiveH,3) .^ 2))');
    shading interp;
    title('Receiver Plane');
    view(0,90);
    colorbar;
    clim([DisplayAttenuationRange -20]);
    if(exist('AntennaDisplay','var') && AntennaDisplay)
        RxAntennaPosInit = zeros(4, RxChannelNum);
        RxAntennaPosInit(1,:) = cos([0 : 1 / RxChannelNum : 1 - (1 / RxChannelNum)] * 2 * pi) * RxAntennaRadius;
        RxAntennaPosInit(2,:) = sin([0 : 1 / RxChannelNum : 1 - (1 / RxChannelNum)] * 2 * pi) * RxAntennaRadius;
        RxAntennaPosInit(3,:) = RxAntennaPosInit(3,:) + 4;
        RxAntennaPosInit(4,:) = ones(1, RxChannelNum);
        hold on;
        plot3([RxAntennaPosInit(1,:) RxAntennaPosInit(1,1)],[RxAntennaPosInit(2,:) RxAntennaPosInit(2,1)],[RxAntennaPosInit(3,:) RxAntennaPosInit(3,1)],'-o','Color','r','MarkerFaceColor','#D90000');
        hold off;
    end
    daspect([1 1 1]);

    nexttile;
    surf(XRange, YRange, angle(sum(RecvReceiveH,3) .^ 2)');
    shading interp;
    title('Receiver Phase');
    view(0,90);
    colorbar;
    if(exist('AntennaDisplay','var') && AntennaDisplay)
        hold on;
        plot3([RxAntennaPosInit(1,:) RxAntennaPosInit(1,1)],[RxAntennaPosInit(2,:) RxAntennaPosInit(2,1)],[RxAntennaPosInit(3,:) RxAntennaPosInit(3,1)],'-o','Color','r','MarkerFaceColor','#D90000');
        hold off;
    end
    daspect([1 1 1]);

    xlabel(TiledFigure, 'meter');
    ylabel(TiledFigure, 'dBW');
    title(TiledFigure, 'Ideal OAM Channel Visualizer-H');
    drawnow;
end