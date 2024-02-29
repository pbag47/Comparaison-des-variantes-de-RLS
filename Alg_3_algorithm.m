function [Error, t] = Alg_3_algorithm(Input, Expected_result, ANC_start_sample, filter_length, variables)
    %% Initialization
    lambda = variables(1) ;
    phi = variables(2) ;
    theta = deg2rad(variables(3)) ;
    t = NaN ;
    Error = zeros(length(Input), 1) ;
    X = zeros(1, filter_length) ;
    H = zeros(filter_length, 1) ;
    biased_energy = 2*filter_length ;
    Bias_correction_factor = 0 ;
    
    energy = zeros(length(Input), 1) ;

    %% "Bias-corrected NLMS" algorithm
    % Correction of the bias induced by the recursive estimate of the
    % energy
    tic()
    for i = ANC_start_sample:length(Input)
        X = [Input(i) X(1:filter_length-1)] ;
        Bias_correction_factor = phi * Bias_correction_factor + 1 ;
        biased_energy = filter_length * Input(i)^2 + phi * biased_energy ;
        unbiased_energy = biased_energy / Bias_correction_factor ;
        energy(i) = unbiased_energy ;
        Error(i) = Expected_result(i) - X*H ;
        H = H + (1-lambda)/(unbiased_energy*cos(theta)) * Error(i) * X' ;
        if isnan(Error(i)) || isinf(Error(i))
            disp('    Algorithm execution aborted: NaN or Inf value found in error signal')
            return
        end
    end
    t = toc() ;
    disp(['    Algorithm running time : ', num2str(t), ' s'])
    figure(2000)
    plot(energy)
end