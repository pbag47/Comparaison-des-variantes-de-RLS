function [Error, t] = Alg_8_algorithm(Input, Expected_result, ANC_start_sample, filter_length, variables)
    %% Initialization
    lambda = variables(1) ;
    t = NaN ;
    Error = zeros(length(Input), 1) ;
    X = zeros(1, filter_length) ;
    H = zeros(filter_length, 1) ;
    energy = 2*filter_length ;

    %% Proposed NLMS algorithm, unique forgetting factor
    tic()
    for i = ANC_start_sample:length(Input)
        X = [Input(i) X(1:filter_length-1)] ;
        energy = (1-lambda) * filter_length * Input(i)^2 + lambda * energy ;
        Error(i) = Expected_result(i) - X*H ;
        H = H + (1-lambda)/energy * Error(i) * X' ;
        if isnan(Error(i)) || isinf(Error(i))
            disp('    Algorithm execution aborted: NaN or Inf value found in error signal')
            return
        end
    end
    t = toc() ;
    disp(['    Algorithm running time : ', num2str(t), ' s'])
end