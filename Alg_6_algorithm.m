function [Error, t] = Alg_6_algorithm(Input, Expected_result, ANC_start_sample, filter_length, variables)
    %% Initialization
    lambda = variables(1) ;
    t = NaN ;
    Error = zeros(length(Input), 1) ;
    X = zeros(1, filter_length) ;
    Omega = 2*ones(filter_length, 1) ;
    H_transform = zeros(filter_length, 1) ;
    
    %% Proposed DFTLMS algorithm, unique forgetting factor
    tic()
    for i = ANC_start_sample:length(Input)
        X = [Input(i) X(1:filter_length-1)] ;
        X_transform = fft(X) ;
        Omega = (1-lambda) * real(X_transform.*conj(X_transform))' + lambda*Omega ;
        Error(i) = Expected_result(i) - 1/filter_length * real(X_transform*H_transform) ;
        H_transform = H_transform + (1-lambda) * Error(i) * Omega.^(-1) .* X_transform' ;
        if isnan(Error(i)) || isinf(Error(i))
            disp('    Algorithm execution aborted: NaN or Inf value found in error signal')
            return
        end
    end
    t = toc() ;
    disp(['    Algorithm running time : ', num2str(t), ' s'])
end