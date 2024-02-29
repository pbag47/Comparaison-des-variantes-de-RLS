function [Error, t] = DFTLMS_algorithm(Input, Expected_result, ANC_start_sample, filter_length, variables)
    %% Initialization
    lambda = variables(1) ;
    t = NaN ;
    Error = zeros(length(Input), 1) ;
    X = zeros(1, filter_length) ;
    Omega = ones(filter_length, 1) ;
    H_transform = zeros(filter_length, 1) ;
    delta = 0.9 ;

    %% DFTLMS algorithm
    tic()
    for i = ANC_start_sample:length(Input)
        X = [Input(i) X(1:filter_length-1)] ;
        X_transform = fft(X) ;
        Omega = (1-delta) * real(X_transform.*conj(X_transform))' + delta*Omega ;
        Error(i) = Expected_result(i) - real(X_transform*H_transform) ;
        H_transform = H_transform + lambda * Error(i) * Omega.^(-1) .* X_transform' ;
        if isnan(Error(i)) || isinf(Error(i))
            disp('    Algorithm execution aborted: NaN or Inf value found in error signal')
            return
        end
    end
    t = toc() ;
    disp(['    Algorithm running time : ', num2str(t), ' s'])
end