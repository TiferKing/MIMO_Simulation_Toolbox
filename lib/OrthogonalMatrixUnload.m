function [OrthogonalSignal] = OrthogonalMatrixUnload(IQSignal, varargin)
%OrthogonalMatrixUnload Unload orthogonal matrix for multi-channel.
%Introduction:
%   In some special scenarios, the channel does not have enough
%   orthogonality. The orthogonal matrix can add more orthogonality to the
%   signal in order to increase the communication capacity.
%Syntax:
%   OrthogonalSignal = OrthogonalMatrixUnload(IQSignal, MatrixPreset)
%   OrthogonalSignal = OrthogonalMatrixUnload(IQSignal, 'Custom', OrthogonalMatrix)
%Description:
%   OrthogonalSignal = OrthogonalMatrixUnload(IQSignal, MatrixPreset)
%       returns the base signal decoded by preset orthogonal matrix.
%   OrthogonalSignal = OrthogonalMatrixUnload(IQSignal, 'Custom', OrthogonalMatrix)
%       returns the base signal decoded by custom orthogonal matrix.
%Input Arguments:
%   IQSignal: (AnalogSignal)
%       Orthogonal signals.
%   MatrixPreset: (string)
%       Type of matrix, it is one of blow:
%       'OAM': DFT matrix.
%   OrthogonalMatrix: (matrix)
%       User defined orthogonal matrix.
%Output Arguments:
%   OrthogonalSignal: (AnalogSignal)
%       Baseband signals.
%Author:
%   Tifer King
%License:
%   Please refer to the 'LICENSE' file included in the root directory 
%   of the project.

    OrthogonalSignal = IQSignal;
    DefaultOrthogonalMatrix = eye(IQSignal.ChannelNum);
    ExpectedMatrixPreset = {'OAM','Custom'};
    InPar = inputParser;
    addRequired(InPar,'MatrixPreset',@(x) any(validatestring(x,ExpectedMatrixPreset)));
    addOptional(InPar,'OrthogonalMatrix', DefaultOrthogonalMatrix,@ismatrix);
    parse(InPar,varargin{:});
    
    if(strcmp(InPar.Results.MatrixPreset, "OAM"))
        OrthogonalMatrix = dftmtx(IQSignal.ChannelNum);
    elseif(strcmp(InPar.Results.MatrixPreset, "Custom"))
        OrthogonalMatrix = InPar.Results.OrthogonalMatrix;
    end
    OrthogonalSignal.Signal = OrthogonalMatrix * IQSignal.Signal;
end